#!/bin/bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo apt install docker-compose -y
sudo groupadd docker
sudo usermod -aG docker ${USER}

# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /tmp/docker-compose
chmod +x /tmp/docker-compose
sudo mv /tmp/docker-compose /usr/local/bin/docker-compose

# setup wordpress app components
mkdir -p /var/opt/wp
mkdir -p /var/opt/wp/nginx
cd /var/opt/wp



echo "${dockercompose}" > docker-compose.yml
echo "${nginx_conf}" > nginx/server.conf

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1


sudo chmod 666 /var/run/docker.sock

docker-compose up
sudo systemctl restart docker

# Intstall gitlab-runner
# Create a GitLab CI user
sudo useradd --create-home gitlab-runner --shell /bin/bash
sudo passwd -d gitlab-runner


# Download the binary for your system
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Give it permissions to execute
sudo chmod +x /usr/local/bin/gitlab-runner

# Install and run as service
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start

# Command to register runner
sudo gitlab-runner register --non-interactive --name ec2 --url https://devops-course-7340241-gitlab.leverx-group.com/ --registration-token DuPLHxewbRJuTjfymB6k --executor shell --tag-list vmn2
sudo usermod -a -G sudo gitlab-runner 

