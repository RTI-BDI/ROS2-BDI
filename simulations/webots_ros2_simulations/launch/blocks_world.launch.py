import os
import pathlib
import launch
from launch_ros.actions import Node
from launch import LaunchDescription
from ament_index_python.packages import get_package_share_directory
from webots_ros2_driver.webots_launcher import WebotsLauncher
from webots_ros2_driver.webots_controller import WebotsController


def generate_launch_description():
    package_dir = get_package_share_directory('webots_ros2_simulations')
    carrier_a_robot_description = pathlib.Path(os.path.join(package_dir, 'resource', 'carrier_a_robot.urdf')).read_text()
    carrier_b_robot_description = pathlib.Path(os.path.join(package_dir, 'resource', 'carrier_b_robot.urdf')).read_text()
    carrier_c_robot_description = pathlib.Path(os.path.join(package_dir, 'resource', 'carrier_c_robot.urdf')).read_text()
    gripper_robot_description = pathlib.Path(os.path.join(package_dir, 'resource', 'gripper_a_robot.urdf')).read_text()
    boxes = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2']
    boxes_descriptions = []
    for box in boxes:
        boxes_descriptions.append(pathlib.Path(os.path.join(package_dir, 'resource', 'box_' + box + '.urdf')).read_text())
    
    webots = WebotsLauncher(
        world=os.path.join(package_dir, 'worlds', 'blocksworld.wbt')
    )

    gripper_robot_driver = WebotsController( # https://github.com/cyberbotics/webots_ros2/wiki/References-Nodes#webotscontroller
        robot_name='gripper_a',
        parameters=[
            {'robot_description': gripper_robot_description},
        ]
    )
    
    carrier_a_robot_driver = WebotsController(
        robot_name='carrier_a',
        parameters=[
            {'robot_description': carrier_a_robot_description},
        ]
    )
    
    carrier_b_robot_driver = WebotsController(
        robot_name='carrier_b',
        parameters=[
            {'robot_description': carrier_b_robot_description},
        ]
    )
    
    carrier_c_robot_driver = WebotsController(
        robot_name='carrier_c',
        parameters=[
            {'robot_description': carrier_c_robot_description},
        ]
    )

    boxes_drivers = []
    for i in range(0, len(boxes)):
        boxes_drivers.append(WebotsController(
            robot_name='box_' + boxes[i],
            parameters=[
                {'robot_description': boxes_descriptions[i]},
            ]
        ))

    return LaunchDescription([
            webots,
            gripper_robot_driver,
            carrier_a_robot_driver,
            carrier_b_robot_driver,
            carrier_c_robot_driver,
            launch.actions.RegisterEventHandler(
                event_handler=launch.event_handlers.OnProcessExit(
                    target_action=webots,
                    on_exit=[launch.actions.EmitEvent(event=launch.events.Shutdown())],
                )
            )
        ] 
        + boxes_drivers
    )