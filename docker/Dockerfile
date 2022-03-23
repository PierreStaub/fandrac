FROM ubuntu:20.04

# install git package
RUN apt update
RUN apt install git -y

# install dependencies
RUN apt install automake gcc git libreadline-dev libssl-dev libtool make wget libjson-c4 libjson-c-dev -y
RUN apt install musl-dev -y

# download the ipmitool git repo
WORKDIR /root/
RUN git clone https://github.com/ipmitool/ipmitool

# configure build and install ipmitool
WORKDIR /root/ipmitool/
RUN ./bootstrap
RUN ./configure
RUN make 
RUN make install

RUN apt install rsyslog -y

COPY fandracApi/fandracApi.c /root/fandracApi/fandracApi.c
COPY fandracApi/fandracApi.h /root/fandracApi/fandracApi.h
COPY fandracApi/Makefile /root/fandracApi/Makefile

COPY fandracApi/config/ipmi_config.json /root/fandracApi/config/ipmi_config.json

WORKDIR /root/fandracApi
RUN make all

EXPOSE 8888/tcp

RUN mkdir -p /root/fandracApi/log && touch /root/fandracApi/log/fandracApi.log
# CMD [ "service", "rsyslog", "start" ]
# CMD [ "./fandracApi" ]
# CMD [ "tail", "-f", "/var/log/syslog" ]