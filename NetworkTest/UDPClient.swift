//
//  UDPClient.swift
//  NetworkTest
//
//  Created by Hellen Soloviy on 11/16/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation
import Network
import UIKit

class UDPClient {
    var connection: NWConnection
    var queue: DispatchQueue
    weak var controller: CameraController?
    
    init(name: String) {
        queue = DispatchQueue(label: "UDP Client Queue")
        
        //Create connection
        let endpoint = NWEndpoint.service(name: name, type: "_camera._udp", domain: "local", interface: nil)
        connection =  NWConnection(to: endpoint, using: .udp)
        
        //Set the state update handler
        connection.stateUpdateHandler = { [weak self] (newState) in
            switch newState {
            case .ready:
                print("Ready to send")
                self?.sendInitialFrame()
            case .waiting(let error):
                print("Waiting with \(error)")
            case .failed(let error):
                print("Client failed with \(error)")
            default:
                print("-DEFAULT")
                break
            }
        }
        
        // Start the connection
        connection.start(queue: queue)
    }
    
    //Send the initial "Hello" frame
    func sendInitialFrame() {
        let halloMessage = "hello".data(using: .utf8)
        
        connection.send(content: halloMessage, completion: .contentProcessed({ (error) in
            if let error = error {
                print("HUSTON! - Send error: \(error)")
            }
        }))
        
        connection.receiveMessage { (content, contest, isComplete, error) in
            if content != nil {
                print("Got connected!")
                if let controller = self.controller {
                    controller.connected()
                }
            }
        }
    }
    
    
    //Send framed from the camera to the other device
    func send(frames: [Data]) {
        connection.batch {
            for frame in frames {
                connection.send(content: frame, completion: .contentProcessed({ (error) in
                    if let error = error {
                        print("HUSTON! - Send error: \(error)")
                    }
                }))
            }
        }
    }
}
