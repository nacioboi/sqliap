# TODO

- [ ] Provide more instructions on how to install docker for debian based systems:
  - for x64 and arm64 separately.

- [ ] Take into consideration, the new `.get_latest_node.sh`. Put instructions of this into the README.

- [ ] Add prerequisites to the README, make might not be on all systems.

- [X] Make sure all docker commands are executed as sudo. Update the README for this.

- [ ] Make a python script with command-line ui to automate the process of building the docker image and running the container.

- [ ] The `http/start.sh` file installs two node.js packages, `mysql` and `express`. Add some code to the bashrc in order to wait until
these packages are installed before showing the prompt.

- [ ] the `http/start.sh` file launches `mysqld` and `node start`, it redirects the stdout+err to their respective log files. Add some code
to the bashrc in order to notify the user when the log files are created. This will notify the user that the server is ready to be used.


## Snipped #1, to be inserted into README, the debian installation instructions

According to [the docker installation guide](https://docs.docker.com/engine/install/debian/), you should execute the following script to
setup the docker apt repository:

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

then use the repository to install docker:

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

To test the installation, run:

```bash
sudo docker run hello-world
```
