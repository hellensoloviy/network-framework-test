//
//  File.swift
//  NetworkTest
//
//  Created by Hellen Soloviy on 11/16/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation
import UIKit

class ViewerController: UIViewController {
    
    func serverConnected() {
        print("--CONNECTED -- SERVER")
    }
    
    func advertised(name: String) {
        print("--advertised \(name)")
    }
    
    func received(frame: Data) {
        print("--Server got data!")
    }
    
}
