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

protocol ClientDelegate: class {
    func connected()
    func received(frame: Data)
}

class UDPClient {
    var connection: NWConnection
    var queue: DispatchQueue
    weak var delegate: ClientDelegate?
    
    init(name: String) {
        queue = DispatchQueue(label: "UDP Client Queue")
        
        //Create connection
        let endpoint = NWEndpoint.service(name: name, type: SharedBrowser.LocalType, domain: SharedBrowser.LocalDomain, interface: nil)
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
        
        connection.receiveMessage { [weak self] (content, contest, isComplete, error) in
            print("recaive ---- 0")
            if let strongSelf = self {
                if content != nil {
                    print("Got connected!")
                    strongSelf.delegate?.connected()
                    strongSelf.receive(on: strongSelf.connection)
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
    
    // Receive packets from the other side and push to screen as video frames
    func receive(on connection: NWConnection) {
        connection.receiveMessage { (content, context, isComplete, error) in
            if let frame = content {
                    self.delegate?.received(frame: frame)
                if error == nil {
                    self.receive(on: connection)
                }
            }
        }
    }
    
}
