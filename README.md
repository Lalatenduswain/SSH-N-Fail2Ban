# Server Security Configuration Script

This script automates the process of configuring server security settings, including Fail2ban and SSH port configuration with UFW (Uncomplicated Firewall) rules.

## Table of Contents

- [Introduction](#introduction)
- [Usage](#usage)
- [Donations](#donations)
- [Disclaimer](#disclaimer)

## Introduction

This script is designed to simplify the process of configuring server security settings on Ubuntu-based systems. It combines two separate tasks:

1. **Configuring Fail2ban for Custom SSH Port**: The script checks if Fail2ban is installed. If not, it can install it for you. It then configures Fail2ban to monitor a custom SSH port, enhancing security by blocking malicious IP addresses.

2. **Changing SSH Port and Configuring UFW Rules**: The script modifies the SSH configuration to change the SSH port to a custom value (e.g., 6594) and configures UFW to allow traffic on the new port while enabling UFW if not already enabled.

**Note:** Make sure to have the necessary permissions and dependencies set up before running this script.

## Usage

To use this script, follow these steps:

1. Clone this repository to your server:

   ```bash
   git clone https://github.com/Lalatenduswain/SSH-N-Fail2Ban.git
   ```

2. Navigate to the repository directory:

   ```bash
   cd SSH-N-Fail2Ban
   ```

3. Make the script executable:

   ```bash
   chmod +x configure_server_security.sh
   ```

4. Run the script:

   ```bash
   ./configure_server_security.sh
   ```

The script will guide you through the installation and configuration process.

## Donations

If you find this script useful and want to show your appreciation, you can donate via [Buy Me a Coffee](https://www.buymeacoffee.com/lalatendu.swain).

## Disclaimer

**Author:** Lalatendu Swain | [GitHub](https://github.com/Lalatenduswain) | [Website](https://blog.lalatendu.info/)

This script is provided as-is and may require modifications or updates based on your specific environment and requirements. Use it at your own risk. The authors of the script are not liable for any damages or issues caused by its usage.

Feel free to modify the README as needed to provide additional context, usage instructions, or any other relevant information.
