FROM ubuntu:17.04
MAINTAINER Boris Posavec <blamemusic@gmail.com>

USER root

# Update the default application repository sources list
RUN apt-get update && apt-get -y upgrade
# Enable sudo with this:
RUN apt-get install -y sudo && rm -rf /var/lib/apt/lists/*
# Must do reupdate after previous sudo install
RUN apt-get update
RUN apt-get install -y gawk wget git-core diffstat unzip texinfo  build-essential chrpath libsdl1.2-dev xterm curl python python-setuptools
RUN apt-get install -y mc htop nano vim
# amiga cross compiler toolchain dependencies
RUN apt-get install -y gperf bison gettext libncurses-dev python-dev gcc-multilib


# -----------------------------------------------
# Setup User (we don't want root here)
# -----------------------------------------------

# Create user 'akiko'
RUN useradd -ms /bin/bash akiko
RUN echo "akiko ALL = NOPASSWD : ALL" >> /etc/sudoers

USER akiko
WORKDIR /home/akiko
RUN mkdir code

# do stuff for cross compilation
RUN git clone git://github.com/cahirwpz/amigaos-cross-toolchain.git
WORKDIR  /home/akiko/amigaos-cross-toolchain
RUN ./toolchain-m68k --prefix=/home/akiko/m68k-amigaos build
RUN echo "PATH=$PATH:/home/akiko/m68k-amigaos/bin" >> /home/akiko/.bashrc

WORKDIR /home/akiko/
WORKDIR /home/akiko/code


# -----------------------------------------------
# End Of Config
# -----------------------------------------------


# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]


