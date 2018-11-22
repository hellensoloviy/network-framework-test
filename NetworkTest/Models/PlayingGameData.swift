//
//  PlayingGameData.swift
//  NetworkFrameworkTest
//
//  Created by Hellen Soloviy on 11/22/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation
import UIKit

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

