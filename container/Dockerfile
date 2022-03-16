# Use the latest Ubuntu Server LTS image as a base
FROM ubuntu:latest

# Declare the exposed ports
EXPOSE 1514/tcp
EXPOSE 1514/udp
EXPOSE 1515
EXPOSE 1516
EXPOSE 55000

# Change the working directory
USER root
WORKDIR /root

# Select a frontend for debconf
RUN echo "debconf debconf/frontend select Noninteractive" |\
 debconf-set-selections

# Install some tools
RUN apt-get update && apt-get install -y wget gnupg

# Get the unattended installation script, but remove its call to the main()
# and startService(). The latter is due to the lack of services in the set
# container.
RUN wget https://packages.wazuh.com/resources/4.2/open-distro/unattended-installation/unattended-installation.sh\
 -O original_installation.sh
RUN cat original_installation.sh | egrep --invert-match "^main \""\
 > installation.sh
RUN sed -i "s/startService()/hiddenStartService()/g" installation.sh
RUN chmod +x installation.sh

# Change the shell from /bin/sh to /bin/bash
SHELL ["/bin/bash", "-c"]

# Run the required functions from the unattended installation script to install
# the prerequirements, Wazuh manager and Filebeat. The last two calls will
# generate errors as the processes will be created manually (not via services,
# as in the initial setup).
RUN source /root/installation.sh && installPrerequisites
RUN source /root/installation.sh && addWazuhrepo
RUN source /root/installation.sh && (installWazuh || true)
RUN source /root/installation.sh && (installFilebeat || true)

# Copy the template Filebeat configuration file that will be populated by the
# entrypoint.sh script
COPY filebeat.yml /etc/filebeat
RUN chmod 600 /etc/filebeat/filebeat.yml

# Place the start script
RUN rm -rf entrypoint.sh
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Run the start script
ENTRYPOINT /root/entrypoint.sh