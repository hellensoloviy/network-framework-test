//
//  GameFieldVC.swift
//  NetworkFrameworkTest
//
//  Created by Hellen Soloviy on 11/20/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class BoardView: UIView {
    let size = CGSize(width: 140, height: 25)
    
    @IBOutlet weak var color: UIColor!
    
}

class GameFieldVC: UIViewController {
    @IBOutlet weak var currentUserBoard: UIView!
    @IBOutlet weak var opponentUserBoard: UIView!
    
    var hostName: String = ""
    var server: UDPServer?
    var client: UDPClient?
    
    var isServer: Bool {
        return server != nil
    }
    
    var currentUserData: PlayingGameData? = nil
    var opponentUserData: PlayingGameData? = nil

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

        currentUserData = PlayingGameData(boardOrigin: currentUserBoard.frame.origin, boardSize: currentUserBoard.frame.size, gameFieldSize: view.frame.size, boardCenter: currentUserBoard.center)
    }
    
    //MARK: - Observers
    private func setupConnectedState() {
        DispatchQueue.main.async {
            self.opponentUserBoard.isHidden = false
            print("Server connected!")
        }
    }
    
    //MARK: - Actions
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            sendBoardData(gestureRecognizer.view!)
        }
    }
    
    //MARK: -Private
    private func sendBoardData(_ viewToSend: UIView) {
        let dataToSend = PlayingGameData(boardOrigin: viewToSend.frame.origin, boardSize: viewToSend.frame.size, gameFieldSize: self.view.frame.size, boardCenter: viewToSend.center)
        if let encodedData = try? JSONEncoder().encode(dataToSend) {
            if !isServer {
                client?.send(frames: [encodedData])
            } else {
                server?.send(frames: [encodedData])
            }
        }
    }
    
    private func updateWith(data recaivedData: PlayingGameData) {
        DispatchQueue.main.async {
            self.opponentUserData = recaivedData
            
            let x = (recaivedData.boardCenter.x * self.view.frame.size.width) / recaivedData.gameFieldSize.width
            let y = (recaivedData.boardCenter.y * self.view.frame.size.height) / recaivedData.gameFieldSize.height
            let opponentCenter = CGPoint(x: self.view.frame.size.width - x, y: self.view.frame.size.height - y)
            
            UIView.animate(withDuration: 0.1) {
                self.opponentUserBoard.center = opponentCenter
            }
        }
    }
    
}

extension GameFieldVC: ServerDelegate, ClientDelegate {
    func advertised(name: String) {
        print("GAME -- Advertised \(name)")
    }
    
    func received(frame: Data) {
        guard let opponentGameData = try? JSONDecoder().decode(PlayingGameData.self, from: frame) else {
            print("--ERROR -- NO DATA -- ")
            return
        }
        updateWith(data: opponentGameData)
    }
    
    func serverConnected() {
         print("GAME -- Server Connected!")
        setupConnectedState()
    }
    
    func connected() {
        print("GAME -- Client Connected!")
        setupConnectedState()
    }
    
}

//extension GameFieldVC: ClientDelegate {
//
//    
//}
