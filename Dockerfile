FROM nvidia/opengl:1.2-glvnd-devel-ubuntu18.04
ARG uid
ARG ROS_PKG=ros_base

ENV ROS1_DISTRO="melodic"

ENV USER="docker"

#
# Setup environment
#
RUN apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

#
# Install basic packages
#
RUN apt-get update && apt-get install -y \
    apt-utils \
    build-essential \
    ca-certificates \
    curl \
    dirmngr \
    software-properties-common \
    python3-pip \
    python-pip  \
    gnupg2 \
    gpg \
    g++ \
    locales \
    lsb-release \
    sudo \
    tmux \
    unzip \
    vim \
    wget \
    xvfb \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y \
    && apt-get autoclean

#
# Install development packages
#
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libbullet-dev \
    libpython3-dev \
    python3-flake8 \
    python3-numpy \
    python3-pytest-cov \
    python3-rosdep \
    libasio-dev \
    libtinyxml2-dev \
    libcunit1-dev \
    libgazebo9-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y \
    && apt-get autoclean


# Install pip packages for testing
RUN python3 -m pip install -U \
    argcomplete \
    flake8-blind-except \
    flake8-builtins \
    flake8-class-newline \
    flake8-comprehensions \
    flake8-deprecated \
    flake8-docstrings \
    flake8-import-order \
    flake8-quotes \
    pytest-repeat \
    pytest-rerunfailures \
    pytest

#
# Install ROS1
#
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - \
    && apt update && apt install -y ros-${ROS1_DISTRO}-desktop-full

#
# Install ROS packages
#
RUN apt-get update && apt-get install -y \
    libgeographic-dev \
    ros-${ROS1_DISTRO}-desktop-full \
    python-rosdep \
    python3-argcomplete \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y \
    && apt-get autoclean

RUN echo 'source /opt/ros/${ROS1_DISTRO}/setup.bash' >> /root/.bashrc

WORKDIR /home/docker

RUN git clone https://github.com/Livox-SDK/Livox-SDK.git \
    && cd Livox-SDK \
    && cd build && cmake .. \
    && make \
    && make install

RUN git clone https://github.com/Livox-SDK/livox_ros_driver.git ws_livox/src \
    && cd ws_livox \
    && /bin/bash -c '. /opt/ros/${ROS1_DISTRO}/setup.bash; catkin_make' \
    && /bin/bash -c '. devel/setup.bash'

RUN mkdir -p catkin_ws/src \
    && git clone https://github.com/hku-mars/FAST_LIO.git \
    && cd FAST_LIO \
    && git submodule --init \
    && cd ~/catkin_ws \
    && catkin_make

#
# Create a user with passwordless sudo
#
RUN adduser --gecos "Development User" --disabled-password -u 1000 $USER
RUN adduser $USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#
# Setup workspace
#
USER $USER
ENV WS_DIR=/home/${USER}

WORKDIR ${WS_DIR}
