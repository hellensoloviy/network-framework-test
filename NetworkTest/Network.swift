//
//  Network.swift
//  NetworkTest
//
//  Created by Hellen Soloviy on 11/16/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation
import Network
import UIKit

class Network {
    static let shared = Network()
    
    let connection = NWConnection(host: "mail.example.com", port: .imaps, using: .tls)
    
    func setupUpdates() {
        connection.stateUpdateHandler = { (newState) in
            switch newState {
            case .ready:
                //handle
                break
            case .waiting(let error):
                //handle
                break
            case .failed(let error):
                //handle
                break
            default:
                print("-DEFAULT")
            }
        }
    }
    
    func start() {
        connection.start(queue: DispatchQueue.global())
    }
}
