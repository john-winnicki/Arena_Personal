#!/usr/bin/env bash
set -euo pipefail

# Install tailscale if missing
if ! command -v tailscale >/dev/null 2>&1; then
  apt-get update
  apt-get install -y curl
  curl -fsSL https://tailscale.com/install.sh | sh
fi

# Ensure OpenSSH server exists + is running (so port 22 has a real SSH banner)
if ! command -v sshd >/dev/null 2>&1; then
  apt-get update
  apt-get install -y openssh-server
fi
mkdir -p /run/sshd
service ssh restart >/dev/null 2>&1 || /usr/sbin/sshd

# Restart tailscaled cleanly
pkill tailscaled >/dev/null 2>&1 || true
mkdir -p /var/run/tailscale

nohup tailscaled --tun=userspace-networking \
  --state=/workspace/persist/tailscale.state \
  --socket=/var/run/tailscale/tailscaled.sock \
  >/tmp/tailscaled.log 2>&1 &

# Bring node up
tailscale up

# Explicitly proxy tailnet TCP:22 -> localhost:22 (reliable in userspace mode)
tailscale serve tcp 22 localhost:22
