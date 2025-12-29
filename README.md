# Arena_Personal
A repo to house my personal code for the arena material. 

## Install Arena material and required packages.
```
cd /workspace
python -m venv --system-site-packages arena_ch1
source /workspace/arena_ch1/bin/activate
python -m pip install -U pip

cd /workspace/Arena_Personal   # or wherever your requirements file is
pip install -r requirements_arena_ch1_runpod_modern.txt   # or legacy

python -m ipykernel install --user --name arena_ch1 --display-name "Python (arena_ch1)"

git clone https://github.com/callummcdougall/ARENA_3.0.git
```

# Fixing SSH and Github
After creating your ssh arena_key, do the following. 
## On Local Desktop
```
ssh-add -l || true
ssh-add ~/.ssh/arena_key
ssh-add -l

ssh -A root@213.173.102.5 -p 13270 -i ~/.ssh/arena_key
```
## Once SSH'd in
```
ssh-add -l
ssh -T git@github.com
```

# Fixing the ssh part 2
## Run this once at the creation of the pod
```
cat > /workspace/persist/bootstrap_github_ssh.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SRC=/workspace/persist/.ssh
DST=/root/.ssh

rm -rf "$DST"
mkdir -p "$DST"
chmod 700 "$DST"

# Copy keypair (source perms on /workspace don't matter)
cp -f "$SRC/id_ed25519" "$DST/id_ed25519"
cp -f "$SRC/id_ed25519.pub" "$DST/id_ed25519.pub"

# Write a fresh config that points to the *copied* key
cat > "$DST/config" <<CFG
Host github.com
  HostName github.com
  User git
  IdentityFile $DST/id_ed25519
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
CFG

touch "$DST/known_hosts"

chmod 600 "$DST/id_ed25519" "$DST/config"
chmod 644 "$DST/id_ed25519.pub" "$DST/known_hosts"

ssh-keyscan github.com >> "$DST/known_hosts" 2>/dev/null || true
EOF

chmod +x /workspace/persist/bootstrap_github_ssh.sh
```
## Run this once per pod start
```
/workspace/persist/bootstrap_github_ssh.sh
ssh -T git@github.com
```