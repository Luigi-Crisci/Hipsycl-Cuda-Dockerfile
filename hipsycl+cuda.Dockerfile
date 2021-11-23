FROM ubuntu:18.04

ENV LLVM_VERSION=11

RUN apt-get -u update \
    && apt-get -qq upgrade \
    # Setup Kitware repo for the latest cmake available:
    && apt-get -qq install \
        apt-transport-https ca-certificates gnupg software-properties-common wget \
    && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
        | gpg --dearmor - \
        | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null \
    && apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' \
    && apt-get -u update \
    && apt-get -qq upgrade \
    && apt-get -qq install cmake \
	ca-certificates \
    build-essential \
	gcc-8 \
	g++-8 \
    python \
    ninja-build \
    ccache \
    xz-utils \
    curl \
    git \
	bzip2 \
	lzma \
	xz-utils \
	apt-utils 

	# Install gcc-9 and g++-9
	RUN apt install -y software-properties-common \
	&& add-apt-repository ppa:ubuntu-toolchain-r/test \
	&& apt update \
	&& apt install -y gcc-9 g++-9
	
	# Install llvm
	RUN apt install -qqy lsb-release wget software-properties-common \
	&& wget https://apt.llvm.org/llvm.sh \
	&& chmod +x llvm.sh \
	&& ./llvm.sh $LLVM_VERSION \
	&& apt-get install -qqy clang-11 clang-tools-11 clang-11-doc libclang-common-11-dev libclang-11-dev libclang1-11 clang-format-11  clangd-11 \
	&& apt-get install -qqy lldb-11 \
	&& apt-get install -qqy llvm-11-dev llvm-11-doc llvm-11-runtime \
	&& apt-get install -qqy libomp-11-dev \
	&& rm llvm.sh

	#Install boost dependecies
	RUN apt install -y autotools-dev libicu-dev libbz2-dev libcurl4-openssl-dev libexpat-dev libgmp-dev libmpfr-dev libssl-dev libxml2-dev libz-dev \
	zlib1g-dev libopenmpi-dev \
	libicu-dev \
	python-dev
	
	# Install boost
	RUN echo "Installing Boost..." \
	&& wget -q https://boostorg.jfrog.io/artifactory/main/release/1.68.0/source/boost_1_68_0.tar.gz  \
	&& tar -xf boost_1_68_0.tar.gz \
	&& cd boost_1_68_0 \
	&& ./bootstrap.sh --with-libraries=all \
	&& ./b2 -j 64 -q install \ 
	&& cd .. && rm -rf boost_1_68_0.tar.gz boost_1_68_0

	# Install Cuda-10.1
	RUN wget -q https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run \
	&& chmod +x cuda_10.1.105_418.39_linux.run \
	&& ./cuda_10.1.105_418.39_linux.run --toolkit --silent --toolkitpath=/usr/local/cuda-10.1 \
	&& rm cuda_10.1.105_418.39_linux.run

	# Install hipSYCL
	RUN git clone https://github.com/illuhad/hipSYCL \
	&& cd hipSYCL \
	&& mkdir build \
	&& cd build \
	&& cmake .. -DCMAKE_CXX_COMPILER=g++-9 \
	&& make -j $(grep -c ^processor /proc/cpuinfo) all \
	&& make install \
	&& cd ../.. && rm -rf hipSYCL

ENV PATH "$PATH:/usr/local/cuda/bin"
ENV LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/usr/local/cuda/lib64"
