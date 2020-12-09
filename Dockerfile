FROM ubuntu:12.04
RUN apt-get update


RUN apt-get install -y fakeroot build-essential expect dialog gawk flex bison gettext libncurses-dev automake autoconf libtool pkg-config git python-dev sudo wget
WORKDIR /tmp/
RUN cd /tmp && wget https://ftp.gnu.org/gnu/texinfo/texinfo-4.13a.tar.gz && mkdir texinfo && tar -xf texinfo-4.13a.tar.gz -C texinfo && \ 
cd texinfo/texinfo-4.13 && \ 
./configure  && make && sudo make install


RUN adduser --disabled-password --gecos '' builduser
RUN adduser builduser sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chmod 777 -R /opt

USER builduser

RUN git config --global user.email "tdt4258@ntnu.no" && \
  git config --global user.name "TDT4258"
RUN sudo mkdir /install && sudo chmod 777 -R /install
WORKDIR /install
RUN cd /install && 	wget http://www.pengutronix.de/oselas/toolchain/download/OSELAS.Toolchain-2012.12.0.tar.bz2 && \
wget http://www.ptxdist.org/software/ptxdist/download/ptxdist-2012.12.0.tar.bz2

RUN cd /install && git clone git://git.pengutronix.de/git/ptxdist.git && cd ptxdist && git checkout ptxdist-2012.12.0 && git cherry-pick 2a89985 && \
./autogen.sh && ./configure  && make && sudo make install

RUN cd /install && tar xf OSELAS.Toolchain-2012.12.0.tar.bz2 \
&& cd OSELAS.Toolchain-2012.12.0 && \
echo "UCLIBC_SUSV3_LEGACY=y \n UCLIBC_SUSV4_LEGACY=y" >> config/uclibc-0.9.33.2-arm-cortexm3-uclinuxeabi.config
RUN cd /install/OSELAS.Toolchain-2012.12.0 && \
ln -sf /usr/local/bin/ptxdist ptxdist && \
find . -name "*.make" -exec sed -i -e 's/http:\/\/www.multiprecision.org\/mpc\/download\//https:\/\/ftp.gnu.org\/gnu\/mpc\//g' {} \; && \
find . -name "*.make" -exec sed -i -e 's/http:\/\/www.mr511.de\/software\//https:\/\/fossies.org\/linux\/misc\/old\//g' {} \; && \
./ptxdist select ptxconfigs/arm-cortexm3-uclinuxeabi_gcc-4.7.2_uclibc-0.9.33.2_binutils-2.22_kernel-3.6-sanitized.ptxconfig && \
./ptxdist --force go

RUN cd /install && wget http://ptxdist.de/software/ptxdist/download/ptxdist-2013.07.1.tar.bz2 && \
tar xjf ptxdist-2013.07.1.tar.bz2 && \
cd ptxdist-2013.07.1 && \
./configure && make && sudo make install

RUN sudo apt-get -y install git curl libncurses5 lib32z1 libqtgui4:i386 libusb-0.1:i386 libelf1:i386 libicu48:i386 vim bc

RUN sudo mkdir -p /tools
WORKDIR /tools

COPY eACommander ./eACommander

RUN sudo ln -s /tools/eACommander/start-eACommander.sh /tools/eACommander/eACommander.sh

COPY JLink ./JLink
COPY libjlink.conf /etc/ld.so.conf.d/

COPY profiler ./profiler
COPY libprofiler.conf /etc/ld.so.conf.d/

RUN sudo ldconfig

RUN sudo rm -rf /install && sudo rm -rf /var/lib/apt/lists/*

WORKDIR /work
ENV PATH "$PATH:/usr/local/bin/ptxdist-2013.07.1:/tools/eACommander:/tools/JLink:/tools/profiler"
CMD ["bash"]