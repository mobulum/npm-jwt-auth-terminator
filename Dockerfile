FROM phusion/baseimage:latest

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes
# Workaround initramfs-tools running on kernel 'upgrade': <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189>
ENV INITRD No

# make sure apt is up to date
RUN \
    sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list && \
    apt-get update -qqy && \
    apt-get install -qqy wget curl

# install nodejs and npm
RUN \
    apt-get install -qqy \
      nodejs \
      npm

# Configure no init scripts to run on package updates.
ADD docker/policy-rc.d /usr/sbin/policy-rc.d
ADD docker/start /usr/local/bin/start

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

WORKDIR /src

# App
ADD . /src

# Install app dependencies
RUN npm install

EXPOSE  3000

CMD ["/sbin/my_init", "--", "bash", "/usr/local/bin/start"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

