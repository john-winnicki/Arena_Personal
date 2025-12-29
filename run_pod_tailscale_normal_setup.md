# RunPod + Tailscale: The Normal, Low-Friction Setup

This guide documents the **standard setup most experienced RunPod users converge to** for a smooth development workflow.

**Outcome:**
- Stable SSH address (no changing IPs/ports)
- No SSH keys stored on RunPod
- Git works cleanly via SSH
- VSCode Remote-SSH config never changes
- Pods can be stopped, restarted, or deleted without pain

---

## Mental Model

- **RunPod pods are disposable** (ephemeral compute)
- **Volumes hold code & data** (persistent)
- **Tailscale provides stable identity + networking**
- **SSH agent forwarding keeps private keys on your laptop**

Treat the pod as a temporary machine that joins your private network.

---

## Prerequisites

- A RunPod account with a pod + attached volume
- A GitHub SSH key already set up **on your laptop**
- VSCode (optional, but common)

---

## Part A — One-Time Setup on Your Laptop

> **Note:** Tailscale runs on your laptop as a background app. You install it once and it auto-starts on login by default.

### 1. Install and start Tailscale on your laptop

Download and install Tailscale from:
https://tailscale.com/download

After installation:
- Launch the **Tailscale app**
- Log in once
- Ensure it shows **Connected**

By default, Tailscale starts automatically when you log in to your laptop.
This means you usually do **nothing** day-to-day.

This creates your private network ("tailnet").

---

### 2. Ensure your SSH key is available locally

This guide assumes you are using a **dedicated SSH key** at:

```text
~/.ssh/arena_key
```

Ensure it exists and has correct permissions:

```bash
ls -l ~/.ssh/arena_key ~/.ssh/arena_key.pub
chmod 600 ~/.ssh/arena_key
```

(Optional) Add it to your agent if you plan to use agent forwarding:

```bash
ssh-add ~/.ssh/arena_key
```

> The private key lives **only on your laptop**.

---

### 3. Add a permanent SSH config entry

Edit `~/.ssh/config` on your laptop:

```sshconfig
Host arena
  HostName PLACEHOLDER
  User root
  IdentityFile ~/.ssh/arena_key
  IdentitiesOnly yes
  ForwardAgent yes

  # Ephemeral pod-friendly host key handling
  StrictHostKeyChecking accept-new
  UserKnownHostsFile ~/.ssh/known_hosts_arena

  ServerAliveInterval 60
  ServerAliveCountMax 3
```

Leave `HostName` as `PLACEHOLDER` for now.

You will fill it in **once** after the pod joins Tailscale.

---

## Part B — One-Time Setup Inside the RunPod

Open a terminal **inside the pod**.

---

### 4. Install Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

---

### 5. Start the Tailscale daemon (containers have no systemd)

> **Very important:** The command below is **one single shell command**. The backslashes (`\`) are required. If you paste it line-by-line **without** the backslashes, Bash will treat the flags as separate commands and you will see errors like `command not found`.

Run **exactly** this:

```bash
# Kill any old daemon if present
pkill tailscaled >/dev/null 2>&1 || true

# Create default socket directory
mkdir -p /var/run/tailscale

# Start tailscaled (THIS IS ONE COMMAND)
nohup tailscaled \
  --tun=userspace-networking \
  --state=/workspace/persist/tailscale.state \
  --socket=/var/run/tailscale/tailscaled.sock \
  >/tmp/tailscaled.log 2>&1 &
```

If you prefer a **single-line version** (no backslashes), this is equivalent:

```bash
nohup tailscaled --tun=userspace-networking --state=/workspace/persist/tailscale.state --socket=/var/run/tailscale/tailscaled.sock >/tmp/tailscaled.log 2>&1 &
```

---

### 6. Authenticate the pod

```bash
tailscale login
```

Open the printed URL in your browser and approve the device.

---

### 7. Bring Tailscale up with SSH enabled

```bash
tailscale up --ssh
```

Verify:

```bash
tailscale status
tailscale ip -4
```

You should see an IP like `100.x.y.z` for the pod.

---

## Part C — Final Laptop Configuration

### 8. Update SSH config **once**

Replace `PLACEHOLDER` with the pod’s Tailscale IP (or a `.ts.net` hostname if shown):

```sshconfig
Host arena
  HostName 100.x.y.z
  User root
  IdentityFile ~/.ssh/arena_key
  IdentitiesOnly yes
  ForwardAgent yes

  # Ephemeral pod-friendly host key handling
  StrictHostKeyChecking accept-new
  UserKnownHostsFile ~/.ssh/known_hosts_arena

  ServerAliveInterval 60
  ServerAliveCountMax 3
```

You will **never need to change this again** for this pod.

---

### 9. Test SSH

Before connecting the first time, initialize a dedicated known-hosts file for this ephemeral host:

```bash
touch ~/.ssh/known_hosts_arena
```

Now connect:

```bash
ssh arena
```

You should not be prompted repeatedly on future pod restarts.

---

### 10. Verify SSH agent forwarding

Inside the pod:

```bash
ssh-add -l
```

You should see your **laptop’s SSH key** listed.

---

## Part D — Git Setup (Fork-Friendly)

Inside your repo on the pod:

```bash
cd /workspace/ARENA_3.0

# Push to your fork
git remote set-url origin git@github.com:john-winnicki/ARENA_3.0.git

# Optional: keep upstream for syncing
git remote add upstream git@github.com:callummcdougall/ARENA_3.0.git 2>/dev/null || true

git remote -v
```

Test GitHub auth:

```bash
ssh -T git@github.com
```

Then push:

```bash
git push -u origin HEAD
```

---

## Daily Workflow

**On your laptop:**
1. Turn on your laptop
2. Log in (Tailscale auto-starts in the background)
3. Confirm Tailscale shows *Connected* (tray/menu bar)

**On RunPod:**

4. Start the pod and run on the pod:

```bash
/workspace/start_tailscale.sh
```

In your local machine, run:
```
ssh-keygen -f ~/.ssh/known_hosts_arena -R [IP ADDRESS]
```

**Connect:**
5. `ssh arena` **or** VSCode → Remote-SSH → Connect to `arena`
6. Work normally (Git just works)

**When done:**
7. Stop the pod
8. Shut down your laptop

---

## Notes & Caveats

- The warning about DNS not being supported in containers is normal.
- If you **delete and recreate** a pod, it will appear as a new device in Tailscale (you’ll update the HostName once).
- Tailscale’s free plan is sufficient for this workflow.

---

## Summary

This setup works because it adds the missing layer:

> **Stable identity + networking, ephemeral compute.**

Once in place, RunPod feels like a normal remote dev machine instead of a brittle cloud VM.

