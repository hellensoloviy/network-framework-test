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
            if !isServer {
                let dataToSend = PlayingGameData(boardOrigin: currentUserBoard.frame.origin, boardSize: currentUserBoard.frame.size, gameFieldSize: self.view.frame.size, boardCenter: gestureRecognizer.view!.center)
                if let encodedData = try? JSONEncoder().encode(dataToSend) {
                    client?.send(frames: [encodedData])
                }
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
        guard let opponentGameData = try? JSONDecoder().decode(PlayingGameData.self, from: frame) else {
            print("--ERROR -- NO DATA -- ")
            return
        }

        DispatchQueue.main.async {
            self.opponentUserData = opponentGameData
            let x = (opponentGameData.boardCenter.x * self.view.frame.size.width) / opponentGameData.gameFieldSize.width
            let y = (opponentGameData.boardCenter.y * self.view.frame.size.height) / opponentGameData.gameFieldSize.height
            let opponentCenter = CGPoint(x: self.view.frame.size.width - x, y: self.view.frame.size.height - y)
            
            UIView.animate(withDuration: 0.1) {
                self.opponentUserBoard.center = opponentCenter
            }
        }
            

    }
    
    func serverConnected() {
         print("GAME -- Server Connected!")
        setupConnectedState()
    }
    
}

extension GameFieldVC: ClientDelegate {
    func connected() {
        print("GAME -- Client Connected!")
        setupConnectedState()
    }
}


class PlayingGameData: Codable {
    var boardOrigin: CGPoint
    var boardSize: CGSize
    var gameFieldSize: CGSize
    var boardCenter: CGPoint
    
    init(boardOrigin: CGPoint, boardSize: CGSize, gameFieldSize: CGSize, boardCenter: CGPoint) {
        self.boardOrigin = boardOrigin
        self.boardSize = boardSize
        self.gameFieldSize = gameFieldSize
        self.boardCenter = boardCenter
    }
}
