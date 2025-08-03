docker run -it --rm --privileged --net=host \
  -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
  --device=/dev/bus/usb kinect2_ros2_humble