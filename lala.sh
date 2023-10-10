#!/bin/bash
## Author : Lalatendu Swain | https://github.com/Lalatenduswain
## Website : https://blog.lalatendu.info/
# Function to configure Fail2ban for custom SSH port
configure_fail2ban_custom_ssh() {
    # Custom SSH port to set (e.g., 6594)
    CUSTOM_SSH_PORT=6594

    # Check if the custom jail file exists
    CUSTOM_JAIL_FILE="/etc/fail2ban/jail.d/custom-ssh.conf"

    if [ -f "$CUSTOM_JAIL_FILE" ]; then
        # Custom jail file already exists, update the port configuration
        echo "Updating the custom Fail2ban jail configuration for SSH port $CUSTOM_SSH_PORT."

        # Modify the SSH jail configuration in the custom jail file
        sed -i "s/^port = .*/port = $CUSTOM_SSH_PORT/" "$CUSTOM_JAIL_FILE"
    else
        # Custom jail file does not exist, create a new one
        echo "Creating a custom Fail2ban jail configuration for SSH port $CUSTOM_SSH_PORT."

        # Create the custom jail file with the SSH configuration
        cat <<EOL | sudo tee "$CUSTOM_JAIL_FILE" >/dev/null
[custom-ssh]
enabled = true
port = $CUSTOM_SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOL
    fi

    # Restart Fail2ban to apply the new configuration
    if systemctl is-active --quiet fail2ban; then
        sudo systemctl restart fail2ban
        echo "Fail2ban has been restarted with the custom SSH port configuration."
    else
        # Fail2ban is not running, start it
        sudo systemctl start fail2ban
        echo "Fail2ban is not running. Starting Fail2ban with the custom SSH port configuration."
    fi

    echo "Fail2ban is now configured to monitor SSH on port $CUSTOM_SSH_PORT."
}

# Function to configure SSH port and UFW
configure_ssh_port_and_ufw() {
    # SSH port to set (e.g., 6594)
    NEW_SSH_PORT=6594

    # Disable and stop the ssh.socket service
    systemctl disable --now ssh.socket

    # Enable and start the ssh.service
    systemctl enable --now ssh.service

    # Create a systemd socket configuration for the new port
    mkdir -p /etc/systemd/system/ssh.socket.d
    cat >/etc/systemd/system/ssh.socket.d/listen.conf <<EOF
[Socket]
ListenStream=
ListenStream=$NEW_SSH_PORT
EOF

    # Reload systemd configurations
    systemctl daemon-reload

    # Restart the ssh.socket service
    systemctl restart ssh.socket

    # Allow the new SSH port in UFW
    ufw allow $NEW_SSH_PORT/tcp

    # Enable UFW if not already enabled
    if ! ufw status | grep -q "Status: active"; then
        ufw enable
    fi

    # Display UFW status and added rule
    ufw status
    echo "SSH port has been changed to $NEW_SSH_PORT, and the port is allowed through the UFW firewall."
}

# Check if Fail2ban is installed
if ! command -v fail2ban-client &>/dev/null; then
    echo "Fail2ban is not installed. Do you want to install it? (yes/no)"
    read -r INSTALL_FAIL2BAN
    if [[ "$INSTALL_FAIL2BAN" == "yes" ]]; then
        sudo apt update
        sudo apt install fail2ban
        configure_fail2ban_custom_ssh
    else
        echo "Fail2ban is not installed. Exiting."
        exit 1
    fi
else
    configure_fail2ban_custom_ssh
fi

# Configure SSH port and UFW
configure_ssh_port_and_ufw
