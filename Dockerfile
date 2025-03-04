FROM i386/ubuntu

RUN mkdir /protostar

WORKDIR /protostar

# Install requirements 
RUN apt update && apt install build-essential -y && apt-get install manpages-dev openssh-server git gdb python3 python -y

# Configure SSH server
RUN mkdir /var/run/sshd
RUN echo 'root:protostar' | chpasswd
COPY ./sshd_config /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile




EXPOSE 22

# Disable ASLR
CMD ["echo 0 | tee /proc/sys/kernel/randomize_va_space"]

# copy protostar code source
COPY . .

# pwngdb configure
RUN cp /root/.gdbinit /home/proto/

# move protostar bins
RUN mv ./protostar /opt
RUN chmod u+s /opt/protostar/bin/*

# install tools
RUN chmod u+x ./tools/*
RUN ./tools/pwngdb
RUN ./tools/pwntools
RUN ./tools/radare2

# create a user
RUN useradd -ms /bin/bash proto
RUN echo 'proto:proto' | chpasswd

# start sshd
CMD ["/usr/sbin/sshd","-D"]
