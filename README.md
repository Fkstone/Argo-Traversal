# Argo-Traversal Script

This repository provides two scripts to help you install and manage Cloudflare Argo tunnels on your Linux machine. The scripts automate the installation of `cloudflared`, creation and configuration of tunnels, setup of DNS records, and configuration of the tunnel as a `systemd` service for automatic startup and management.

## Prerequisites

- A Cloudflare account
- Access to a domain managed through Cloudflare

### Script Features

- **Install `cloudflared`**: The `argoinstall.sh` script checks if `cloudflared` is installed and installs it if necessary.
- **Login to Cloudflare**: The script prompts you to login to Cloudflare.
- **Create Tunnel**: The script creates a new tunnel with the specified name.
- **Configure Tunnel**: The script sets up the tunnel configuration and copies the necessary credentials.
- **Setup DNS Records**: The script configures DNS records to route traffic to your local service.
- **Create `systemd` Service**: The script creates a `systemd` service for the tunnel to ensure it starts automatically on boot.

## Usage

### Installation

#### Install Tunnel

To install and configure a new tunnel:

1. Download and run the `argoinstall.sh` script:

    ```sh
    wget https://raw.githubusercontent.com/Fkstone/Argo-Traversal/master/argoinstall.sh -O argoinstall.sh
    chmod +x argoinstall.sh
    ./argoinstall.sh
    ```

2. Follow the prompts to:
    - Enter the tunnel name.
    - Enter the local service address (e.g., `http://localhost:8080`).
    - Enter your domain name (e.g., `example.com`).
    - Enter the subdomain prefix (e.g., `tunnel`).

3. The script will handle the rest, including setting up the DNS records and configuring the tunnel as a `systemd` service.

#### Uninstall Tunnel

To uninstall and remove an existing tunnel:

1. Download and run the `argouninstall.sh` script:

    ```sh
    wget https://raw.githubusercontent.com/Fkstone/Argo-Traversal/master/argouninstall.sh -O argouninstall.sh
    chmod +x argouninstall.sh
    ./argouninstall.sh
    ```

2. Follow the prompt to enter the tunnel name to be removed. The script will stop and disable the `systemd` service, remove the configuration files, and delete the tunnel from Cloudflare.

## Notes

- Ensure you have sudo privileges to install packages and configure `systemd` services.
- The script currently supports Linux systems. Adaptations may be required for other environments.
- The scripts assume that the `cloudflared` binary is installed to `/usr/local/bin`. Adjust the `ExecStart` path in the `systemd` service file if necessary.

## License

This project is licensed under the GNU General Public License v3.0.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements.

## Acknowledgements

- [Cloudflare](https://www.cloudflare.com/) for providing the `cloudflared` tool and Cloudflare Tunnel service.

---
