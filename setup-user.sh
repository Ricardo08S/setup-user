#!/bin/bash
set -e

USERNAME="ubuntu"
PUBKEY="ISI_PUBLIC_KEY_ANDA_DI_SINI"

ensure_line_in_file() {
  local line="$1"
  local file="$2"
  touch "$file"
  grep -Fqx "$line" "$file" || echo "$line" >> "$file"
}

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

# 6. Tambahkan alias cls (Bash-only, non-redundan)
ensure_line_in_file "alias cls='clear'" /etc/bash.bashrc
ensure_line_in_file "alias cls='clear'" /root/.bashrc
ensure_line_in_file "alias cls='clear'" "/home/$USERNAME/.bashrc"
chown "$USERNAME:$USERNAME" "/home/$USERNAME/.bashrc"
rm -f /etc/profile.d/cls.sh

# 7. Restart SSH service
systemctl restart ssh || systemctl restart sshd

echo "Selesai. Coba login:"
echo "ssh $USERNAME@IP_SERVER"
