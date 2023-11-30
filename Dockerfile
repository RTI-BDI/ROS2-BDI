FROM webots-plansys2-humble

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y libboost-dev
# libyaml-cpp0.7

WORKDIR /root

RUN git clone --depth 1 --branch yaml-cpp-0.6.0 https://github.com/jbeder/yaml-cpp.git

RUN cd yaml-cpp && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DYAML_BUILD_SHARED_LIBS=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON .. && \
    make && \
    make install

RUN ls /usr/lib/cmake/yaml-cpp

ENV LD_LIBRARY_PATH /usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
ENV CMAKE_PREFIX_PATH /usr/lib/cmake:$CMAKE_PREFIX_PATH

COPY . ros2bdi_ws/src/ROS2-BDI
# VOLUME ros2bdi_ws/src/ROS2-BDI

RUN source /root/plansys2_ws/install/setup.bash && \
    cd ~/ros2bdi_ws && \
    colcon build --packages-select ros2_bdi_interfaces

RUN rm -rf /root/ros2bdi_ws/build/ros2_bdi_interfaces

RUN NUM_CORES=$(nproc) && \
    export MAKEFLAGS="-j$NUM_CORES" && \
    export AMENT_BUILD_GRADLE_ARGS="-j$NUM_CORES" && \
    export AMENT_BUILD_MAKE_ARGS="-j$NUM_CORES" && \
    source /root/plansys2_ws/install/setup.bash && \
    cd ~/ros2bdi_ws && \
    colcon build --packages-select ros2_bdi_utils ros2_bdi_skills ros2_bdi_bringup ros2_bdi_core --packages-skip ros2_bdi_interfaces

RUN NUM_CORES=$(nproc) && \
    export MAKEFLAGS="-j$NUM_CORES" && \
    export AMENT_BUILD_GRADLE_ARGS="-j$NUM_CORES" && \
    export AMENT_BUILD_MAKE_ARGS="-j$NUM_CORES" && \
    source /root/plansys2_ws/install/setup.bash && \
    cd ~/ros2bdi_ws && \
    colcon build --symlink-install --packages-ignore ros2_bdi_tests && \
    source /root/ros2bdi_ws/install/setup.bash && \
    colcon build --packages-select ros2_bdi_tests

RUN NUM_CORES=$(nproc) && \
    export MAKEFLAGS="-j$NUM_CORES" && \
    export AMENT_BUILD_GRADLE_ARGS="-j$NUM_CORES" && \
    export AMENT_BUILD_MAKE_ARGS="-j$NUM_CORES" && \
    source /root/plansys2_ws/install/setup.bash && \
    cd ~/ros2bdi_ws && \
    colcon build --symlink-install --packages-select webots_ros2_simulations_interfaces webots_ros2_simulations ros2_bdi_on_webots

# source entrypoint setup
RUN sed --in-place --expression \
      '$isource "/root/ros2bdi_ws/install/setup.bash"' \
      /ros_entrypoint.sh

CMD ["/bin/bash", "-c", "source /root/ros2bdi_ws/install/setup.bash && source /opt/ros/humble/setup.bash && source /root/plansys2_ws/install/setup.bash"]


# to build
# sudo docker build --platform=linux/amd64 --rm  --tag ros2bdi-humble .

# to run
# sudo docker run --gpus=all -v /tmp/.X11-unix/:/tmp/.X11-unix/ --volume="$HOME/.Xauthority:/root/.Xauthority:rw" --network=host -e DISPLAY --rm -it ros2bdi-humble bash