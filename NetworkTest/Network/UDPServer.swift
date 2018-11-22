//
//  UDPServer.swift
//  NetworkTest
//
//  Created by Hellen Soloviy on 11/16/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation
import Network
import UIKit

protocol ServerDelegate: class {
    func serverConnected()
    func advertised(name: String)
    func received(frame: Data)
}

class UDPServer {
    var listener: NWListener
    var queue: DispatchQueue
    var connection: NWConnection? = nil

    var isConnected: Bool = false
    weak var controller: GameFieldVC?
    
    weak var delegate: ServerDelegate?
    
    init?(named presettedName: String? = nil) {
        queue = DispatchQueue(label: "UDP Server Queue")
        
        // Create the listener
        listener = try! NWListener(using: .udp)
        
        // Set up the listener with the _camera._udp service
        listener.service =  NWListener.Service(name: presettedName, type: SharedBrowser.LocalType)

        // Listen to changes in the service registration
        listener.serviceRegistrationUpdateHandler = { (serviceChange) in
            switch serviceChange {
            case .add(let endpoint):
                switch endpoint {
                case let .service(name, _, _, _):
                    print("Listening \(name)")
                default:
                    break
                }
            default:
                break
            }
        }
        
        // Handle incoming connections
        listener.newConnectionHandler = { [weak self] (newConnection) in
            if let strongSelf = self {
                strongSelf.connection = newConnection
                newConnection.start(queue: strongSelf.queue)

                strongSelf.delegate?.serverConnected()
                strongSelf.receive(on: newConnection)
            }
            
        }
        
        // Handle listner state changes
        listener.stateUpdateHandler = { [weak self] (newState) in
            switch newState {
            case .ready:
                print("Listener on port \(String(describing: self?.listener.port))")
            case .waiting(let error):
                print("Waiting with \(error)")
            case .failed(let error):
                print("Listener failed with \(error)")
            default:
                print("-DEFAULT")
                break
            }
        }
        
        // Start the listener
        listener.start(queue: queue)
    }
    
    // Receive packets from the other side and push to screen as video frames
    func receive(on connection: NWConnection) {
        connection.receiveMessage { (content, context, isComplete, error) in

            if let frame = content {
                if !self.isConnected {
                    connection.send(content: frame, completion: .idempotent)
                    print("Echoed initial content: \(frame)")
                    self.isConnected = true
                } else {
                    self.delegate?.received(frame: frame)
                }
                
                if error == nil {
                    self.receive(on: connection)
                }
            }
        }
    }
    
    //Send framed from the camera to the other device
    func send(frames: [Data]) {
        guard let connection = self.connection else {
            print("No connection!")
            return
        }
        
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
