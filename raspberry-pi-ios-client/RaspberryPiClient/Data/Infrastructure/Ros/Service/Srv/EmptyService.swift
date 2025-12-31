//
//  EmptyService.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/29.
//

import Foundation

/// [std_srvs/srv/Empty.srv](https://github.com/ros2/common_interfaces/blob/jazzy/std_srvs/srv/Empty.srv)
struct EmptyService: RosCallServiceArgsProtocol, RosServiceResponseValuesProtocol {}
