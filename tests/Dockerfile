# Dockerfile
ARG image
FROM $image
# Install Ansible
RUN apt-get update
ARG additional_packages
RUN apt-get install -y software-properties-common git gnupg
RUN echo apt-get install -y wget $additional_packages
RUN apt-get install -y wget $additional_packages
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" > /etc/apt/sources.list.d/ansible.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apt-get update
RUN apt-get install -y ansible
# Install Ansible inventory file
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts
RUN echo "retry_files_enabled = False" >> /etc/ansible/ansible.cfg