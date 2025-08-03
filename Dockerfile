FROM osrf/ros:humble-desktop-full

# Install needed dependencies
RUN apt update && apt install -y \
    git cmake build-essential pkg-config sudo \
    libusb-1.0-0-dev libturbojpeg0-dev libglfw3-dev \
    libopencv-dev libeigen3-dev libpcl-dev \
    libqt5opengl5-dev qtbase5-dev libvtk9-dev \
    ros-humble-rtabmap-ros ros-humble-rviz2 \
    ros-humble-image-transport ros-humble-cv-bridge \
    ros-humble-depth-image-proc ros-humble-tf2-tools && \
    apt clean && rm -rf /var/lib/apt/lists/*

# create non-root user
RUN useradd -ms /bin/bash rosuser && adduser rosuser sudo
USER rosuser
WORKDIR /home/rosuser

# Install libfreenect2 from source
RUN git clone https://github.com/OpenKinect/libfreenect2.git && \
    cd libfreenect2 && mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/freenect2 && \
    make -j$(nproc) && make install && \
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$HOME/freenect2/lib" >> ~/.bashrc && \
    echo "export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:$HOME/freenect2/lib/pkgconfig" >> ~/.bashrc

# Set up ROS 2 workspace
RUN mkdir -p ~/ros2_ws/src
WORKDIR /home/rosuser/ros2_ws/src
RUN git clone https://github.com/YuLiHN/kinect2_ros2.git

WORKDIR /home/rosuser/ros2_ws
RUN bash -c "source /opt/ros/humble/setup.bash && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    colcon build"


# Source environment
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc

CMD ["/bin/bash"]

