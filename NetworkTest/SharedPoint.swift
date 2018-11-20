//
//  SharedPoint.swift
//  NetworkTest
//
//  Created by Hellen Soloviy on 11/16/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation

class SharedPoint: Equatable {
    
    // file sharing service on computer
    var netService: NetService
    
    // file sharing protocol (SMB or AFP).
    var type: String
    
    // computer’s IP address in the network.
    var IPAddress: String
    
    init(netService: NetService, type: String, IPAddress: String) {
        self.netService = netService
        self.type = type
        self.IPAddress = IPAddress
    }
    
    static func == (lhs: SharedPoint, rhs: SharedPoint) -> Bool {
        return (lhs.netService == rhs.netService) && (lhs.type == rhs.type) && (lhs.IPAddress == rhs.IPAddress)
    }
}
