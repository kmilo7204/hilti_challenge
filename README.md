
## Buid the container
docker build . --tag hilti:melodic

## Run the container
docker run -it  hilti:melodic

## Docker elements
This docker builds Fast LIO: https://github.com/hku-mars/FAST_LIO

Hence it contains:
- https://github.com/Livox-SDK/Livox-SDK
- https://github.com/Livox-SDK/livox_ros_driver

ROS version:
- Melodic

Ubuntu version:
- 18.04

PCL >= 1.8.x
Egien Library
