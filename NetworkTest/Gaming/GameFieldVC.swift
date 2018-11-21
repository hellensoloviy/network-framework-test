//
//  GameFieldVC.swift
//  NetworkFrameworkTest
//
//  Created by Hellen Soloviy on 11/20/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation
import UIKit

class BoardView: UIView {
    let size = CGSize(width: 140, height: 25)
    
    @IBOutlet weak var color: UIColor!
    
}

class GameFieldVC: UIViewController {
    @IBOutlet weak var currentUserBoard: UIView!
    
    var hostName: String = ""
    var server: UDPServer?
    var client: UDPClient?
    
    var isServer: Bool {
        return server != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        currentUserBoard.addGestureRecognizer(gestureRecognizer)
        
        if server != nil {
            print("GAME -- IS SERVER ---")
        } else {
            print("GAME -- IS client ---")
        }
       
        server?.delegate = self
        client?.delegate = self
        
//        NotificationCenter.default.addObserver(self, selector: #selector(serverConnected), name: .serverConnected, object: nil)

    }
    
    //MARK: - Observers
    @objc private func serverConnected(_ notification: Notification) {
        print("Server connected!")
        
    }
    
    //MARK: - Actions
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            if !isServer {
                
//                client?.send(frames: )
            }
            
        }
    }
    
}

extension GameFieldVC: ServerDelegate {
    func advertised(name: String) {
        print("GAME -- Advertised \(name)")
    }
    
    func received(frame: Data) {
        print("GAME -- Server got data!")
    }
    
    func serverConnected() {
         print("GAME -- Server Connected!")
    }
    
}

extension GameFieldVC: ClientDelegate {
    func connected() {
        print("GAME -- Client Connected!")
    }
}
