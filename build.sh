#!/bin/bash

source /root/plansys2_ws/install/setup.bash

NUM_CORES=$(nproc) && \
export MAKEFLAGS="-j$NUM_CORES" && \
export AMENT_BUILD_GRADLE_ARGS="-j$NUM_CORES" && \
export AMENT_BUILD_MAKE_ARGS="-j$NUM_CORES"


cd ~/ros2bdi_ws

colcon build --symlink-install --packages-select ros2_bdi_interfaces
# rm -rf /root/ros2bdi_ws/build/ros2_bdi_interfaces

colcon build --packages-select ros2_bdi_utils ros2_bdi_skills ros2_bdi_bringup ros2_bdi_core --packages-skip ros2_bdi_interfaces

colcon build --symlink-install --packages-ignore ros2_bdi_tests --packages-skip ros2_bdi_interfaces ros2_bdi_utils ros2_bdi_skills ros2_bdi_bringup ros2_bdi_core

source /root/ros2bdi_ws/install/setup.bash

colcon build --symlink-install --packages-select ros2_bdi_tests

# colcon build --symlink-install --packages-select webots_ros2_simulations_interfaces webots_ros2_simulations ros2_bdi_on_webots


# source entrypoint setup
sed --in-place --expression \
'$isource "/root/ros2bdi_ws/install/setup.bash"' \
/ros_entrypoint.sh