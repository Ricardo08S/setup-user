#!/bin/bash
set -e

USERNAME="ubuntu"
PUBKEY="ISI_PUBLIC_KEY_ANDA_DI_SINI"

# 1. Buat user ubuntu tanpa password jika belum ada
if id "$USERNAME" &>/dev/null; then
  echo "User $USERNAME sudah ada"
else
  adduser "$USERNAME" --disabled-password --gecos ""
fi

# 2. Masukkan ke group sudo
usermod -aG sudo "$USERNAME"

# 3. Set sudo tanpa password
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USERNAME-nopasswd
chmod 440 /etc/sudoers.d/90-$USERNAME-nopasswd

# 4. Setup SSH authorized_keys
mkdir -p /home/$USERNAME/.ssh
echo "$PUBKEY" > /home/$USERNAME/.ssh/authorized_keys

chmod 700 /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

# 5. Pastikan SSH key login aktif
sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# 6. Restart SSH service
systemctl restart ssh || systemctl restart sshd

echo "Selesai. Coba login:"
echo "ssh $USERNAME@IP_SERVER"
