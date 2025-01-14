This script will deploy a Tableau Bridge client within a Docker container. 

## Requirements
1. Make sure Docker is installed and Docker engine is running.
2. Make sure you have access to root privileges on the machine.
3. It is recommended to install Tableau Bridge on RHEL 9. (CentOS is unsupported to be used as a host for bridge)
4. Tableau Cloud username.
5. Tableau Cloud site name.
6. A valid Personal Access Token.

Download the bash script.
```bash
wget https://github.com/99abrarahmed/tableaubridge/blob/dea9fa562ff0879eba50545b371e4ca34409981c/deploycontainer.sh
```

Make the script executable.
```bash
sudo chmod +x ./deploycontainer.sh
```

Run the Script.
```bash
sudo ./deploycontainer.sh
```

**You will now be prompted to enter details to create the bridge client.**
