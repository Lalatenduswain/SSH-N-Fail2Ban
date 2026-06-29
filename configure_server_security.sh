#!/bin/bash

# FIX #7: Single global variable — was two separate locals (CUSTOM_SSH_PORT
#          inside configure_fail2ban_custom_ssh and NEW_SSH_PORT inside
#          configure_ssh_port_and_ufw) that could silently drift out of sync.
#          Change the port here and it propagates everywhere.
# -----------------------------------------------------------------------------
SSH_PORT=6594
CUSTOM_JAIL_FILE="/etc/fail2ban/jail.d/custom-ssh.conf"

configure_fail2ban_custom_ssh() {
    if [ -f "$CUSTOM_JAIL_FILE" ]; then
        echo "Updating Fail2ban jail config for SSH port $SSH_PORT."
        # FIX #2: was missing sudo — /etc/fail2ban/ requires root to modify
        sudo sed -i "s/^port = .*/port = $SSH_PORT/" "$CUSTOM_JAIL_FILE"
    else
        echo "Creating Fail2ban jail config for SSH port $SSH_PORT."
        sudo tee "$CUSTOM_JAIL_FILE" >/dev/null <<EOL
[custom-ssh]
enabled  = true
port     = $SSH_PORT
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 3
bantime  = 3600
EOL
    fi

    if systemctl is-active --quiet fail2ban; then
        sudo systemctl restart fail2ban
        echo "Fail2ban restarted — monitoring SSH on port $SSH_PORT."
    else
        sudo systemctl start fail2ban
        echo "Fail2ban started — monitoring SSH on port $SSH_PORT."
    fi
}

configure_ssh_port_and_ufw() {
    # FIX #3: every command below was missing sudo — all write to protected
    #          paths or control system services and will fail as non-root.
    sudo systemctl disable --now ssh.socket
    sudo systemctl enable --now ssh.service

    sudo mkdir -p /etc/systemd/system/ssh.socket.d
    sudo tee /etc/systemd/system/ssh.socket.d/listen.conf >/dev/null <<EOF
[Socket]
ListenStream=
ListenStream=$SSH_PORT
EOF

    sudo systemctl daemon-reload
    sudo systemctl restart ssh.socket

    sudo ufw allow "$SSH_PORT"/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp

    # FIX #5: plain 'ufw enable' prompts for confirmation and hangs
    #          non-interactive runs (cron, CI, pipe). --force skips the prompt.
    if ! sudo ufw status | grep -q "Status: active"; then
        sudo ufw --force enable
    fi

    echo "UFW Status:"
    sudo ufw status verbose
    echo "SSH port set to $SSH_PORT. Ports 80 and 443 open."
}

# FIX #4: 'yes "$YES" | apt install' is fragile. apt-get -y is the
#          correct non-interactive pattern for scripts.
if ! command -v fail2ban-client &>/dev/null; then
    echo "Fail2ban not found — installing..."
    sudo apt-get update -y
    sudo apt-get install -y fail2ban
fi

configure_fail2ban_custom_ssh
configure_ssh_port_and_ufw

# FIX #1: $NEW_SSH_PORT was declared inside configure_ssh_port_and_ufw()
#          so it was always empty here. Now references the global $SSH_PORT.
echo "SSH Port: $SSH_PORT"

# FIX #6: missing sudo + missing --no-pager caused 'less' to block
#          non-interactive shells.
echo "Fail2ban Status:"
sudo systemctl status fail2ban --no-pager
