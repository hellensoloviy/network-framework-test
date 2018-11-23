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
    
    var gameFieldView: UIView {
        return self.view
    }
    
    var currentUserData: PlayingGameData? = nil
    var opponentUserData: PlayingGameData? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        server?.delegate = self
        client?.delegate = self
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        currentUserBoard.addGestureRecognizer(gestureRecognizer)

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
            
            //new center point of view
            var newX = gestureRecognizer.view!.center.x + translation.x
            var newY = gestureRecognizer.view!.center.y + translation.y
            
            ///handle distance to X bounds of game field
            let distanceToXBoundFromCenter = gestureRecognizer.view!.frame.size.width / 2
            if (newX - distanceToXBoundFromCenter) < gameFieldView.frame.origin.x || (newX + distanceToXBoundFromCenter) > gameFieldView.frame.size.width {
                newX -= translation.x
            }
            
            ///handle distance to Y bounds of game field
            let distanceToYBoundFromCenter = gestureRecognizer.view!.frame.size.height / 2
            if (newY - distanceToYBoundFromCenter) < gameFieldView.frame.origin.y || (newY + distanceToYBoundFromCenter) > gameFieldView.frame.size.height {
                newY -= translation.y
            }
            
            gestureRecognizer.view!.center = CGPoint(x: newX, y: newY)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            
            sendBoardData(gestureRecognizer.view!)
        }
    }
    
    //MARK: - Private
    private func sendBoardData(_ viewToSend: UIView) {
        let dataToSend = PlayingGameData(boardOrigin: viewToSend.frame.origin, boardSize: viewToSend.frame.size, gameFieldSize: gameFieldView.frame.size, boardCenter: viewToSend.center)
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
            
            let x = (recaivedData.boardCenter.x * self.gameFieldView.frame.size.width) / recaivedData.gameFieldSize.width
            let y = (recaivedData.boardCenter.y * self.gameFieldView.frame.size.height) / recaivedData.gameFieldSize.height
            let opponentCenter = CGPoint(x: self.gameFieldView.frame.size.width - x, y: self.gameFieldView.frame.size.height - y)
            
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
