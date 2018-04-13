# Base image is Tensorflow with CUDA + cuDNN
# https://github.com/tensorflow/tensorflow/tree/master/tensorflow/tools/docker
FROM tensorflow/tensorflow:1.7.0-devel-gpu-py3

LABEL maintainer "Roy Sindre Norangshol"

# Note about this one, defaults to work with root.  Use
# https://github.com/norrs/deeplearning-gpu-box for running as host user ;-)

# Install LLVM dependencies and repo
RUN echo 'deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-4.0 main' \
    >/etc/apt/sources.list.d/llvm.list
RUN echo 'deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-4.0 main' \
    >>/etc/apt/sources.list.d/llvm.list
RUN curl http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN add-apt-repository ppa:hvr/ghc

# Install basic programs and dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    htop \
    byobu \
    git \
    nano \
    vim \
    rsync \
    unzip \
    clang-4.0 \
    locales

# Set correct locale for locale-aware programs or libraries
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


# Setup Numba Env
ENV LLVM_CONFIG=/usr/bin/llvm-config-5.0
ENV NUMBAPRO_LIBDEVICE /usr/local/cuda-8.0/nvvm/libdevice
ENV NUMBAPRO_NVVM /usr/local/cuda-8.0/nvvm/lib64/libnvvm.so

# Install basic packages and miscellaneous dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    liblapack-dev \
    libopenblas-dev \
    python3-tk \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    zlib1g-dev \
    libhdf5-dev \
    cabal-install-2.2 \
    texlive

RUN DEBIAN_FRONTEND=noninteractive apt-get build-dep -y \
    python-opencv 

# Upgrade pip and setuptools
RUN pip3 install --upgrade \
    setuptools \
    pip \
    wheel

# Install basic Python packages (some of these may already be installed)
RUN pip3 install \
    six \
    ipython \
    jupyter \
    jupyterlab \
    ipdb \
    ujson \
    numpy \
    Pillow \
    scipy \
    matplotlib \
    tqdm \
    seaborn \
    statsmodels \
    h5py \
    PyYAML \
    pandas \
    scikit-learn \
    opencv-python 
RUN pip3 install --upgrade \
    scikit-image \
    numba \
    git+git://github.com/Lasagne/Lasagne.git@$master \
    git+git://github.com/fchollet/keras.git@$master \
    git+git://github.com/vicolab/ml-pyxis.git@$master

RUN apt install -y \
    texlive-latex-base \
    texlive-xetex latex-xcolor \
    texlive-math-extra \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-bibtex-extra \
    fontconfig \
    lmodern

# will ease up the update process
# updating this env variable will trigger the automatic build of the Docker image
#ENV PANDOC_VERSION "1.19.2.1"
ENV GHC_VERSION "8.4.1"
RUN apt install -y ghc-${GHC_VERSION} \
  ghc-${GHC_VERSION}-dyn \
  ghc-${GHC_VERSION}-prof 
ENV PATH "/opt/ghc/bin:$PATH"
#RUN cabal update && cabal install --global Cabal
RUN cabal update && cabal install \
 --prefix /usr/local \
 --symlink-bindir /usr/local/bin \
 --extra-prog-path /usr/local/bin \
 pandoc
#RUN git clone --depth 1 https://github.com/jgm/pandoc
#RUN cd pandoc && \
# stack setup && \
# stack install && \
# pandoc --version


# install pandoc
#RUN cabal update && cabal install pandoc-${PANDOC_VERSION}
#RUN DEBIAN_FRONTEND=noninteractive cabal update && cabal install \
#    Cabal 
#RUN DEBIAN_FRONTEND=noninteractive cabal update && cabal install \
#   cabal-install
#RUN stack update && stack upgrade --binary
#
#RUN DEBIAN_FRONTEND=noninteractive cabal update && cabal install \
#    pandoc

# Prepare matplotlib font cache
RUN python3 -c "import matplotlib.pyplot"

# Set up directories in /root
RUN mkdir /root/shared && \
mkdir /root/data && \
mkdir /root/.misc && \
mkdir -p -m 700 /root/.local/share/jupyter

# Add alias to `.bash_aliases` so that `python` runs `python3`
RUN echo "alias python=python3"  >> /root/.bash_aliases
RUN echo "alias run_notebook='jupyter notebook --no-browser --allow-root'"  >> /root/.bash_aliases

# Expose port for IPython (8888)
EXPOSE 8888

# Expose port for TensorBoard (6006)
EXPOSE 6006

# Set default working directory and image startup command
WORKDIR "/root"
CMD ["/bin/bash"]
