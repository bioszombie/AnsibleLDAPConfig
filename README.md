
# Ansible Playbook for System Update and Configuration

## Overview

This playbook is designed to automate the process of updating Debian/Ubuntu systems, checking for and performing necessary reboots, installing and configuring LDAP and SSSD for user authentication, and ensuring the correct configuration of related services and files. It aims to streamline system administration tasks, enhance security, and ensure consistent configurations across all managed nodes.

## Prerequisites

### Required

- Ansible 2.9 or higher installed on the control machine.
- Root access or equivalent permissions for the Ansible user on all target machines.
- Debian or Ubuntu-based target machines.
- SSH access configured for Ansible on all target machines.
- Required Ansible roles and collections installed (if any).
- LDAP Server / Container / Provider

### Preferred LDAP Server
- Latest Authentik SSO and LDAP Provider/Application/Outpost configured
   - Known to work with Authentik version 2023.10.x and above

## How to Run

1. **Prepare Inventory File**: Ensure your Ansible inventory file is up to date with the target machines listed under the appropriate groups.

2. **Configure Variables**: Customize the variables in the playbook or in separate variable files (`files.yml`, `services.yml`, `host_vars/[server].yml`) as needed. Add as many server.yml fiels as you have hosts that require LDAP configured. This includes LDAP configuration details, server URIs, and any specific package versions.

3. **Run the Playbook**:
   ```sh
   ansible-playbook -i ./hosts/hosts.ini playbook.yml
   ```

4. **Check Execution Results**: Review the output of the playbook execution to ensure all tasks have completed successfully. Address any errors or warnings as necessary.

## Playbook Tasks Overview

- **System Updates**: The playbook updates all packages to their latest versions and upgrades the system where applicable.
- **Reboot Handling**: It checks for and performs a system reboot if required, especially after kernel updates.
- **LDAP and SSSD Configuration**: Installs necessary packages for LDAP and SSSD, configures related files for user authentication, and ensures the correct setup of NSS and PAM.
- **Service Management**: Restarts and enables necessary services like `nscd`, `sssd`, and `nslcd` to apply changes and ensure they run on boot.
- **Custom Configuration Files**: Copies custom configuration files for SSH, LDAP, SSSD, and NSS, applying specific customizations through replacements in the playbook.

## Customizing the Playbook

Modify the variables and template paths as needed to fit your environment. Pay close attention to the LDAP configuration details and ensure they match your directory service settings.

## Maintenance and Troubleshooting

Regularly update the playbook with new versions of packages or adjustments in configuration files as your environment evolves. For troubleshooting, refer to the Ansible execution output and check the logs on the target machines for specific service errors.

## Contributing

Contributions to the playbook are welcome. Please ensure to test any changes in a development environment before submitting a pull request.

## License

This project is licensed under the GNU General Public License v3.0.
