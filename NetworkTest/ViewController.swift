//
//  ViewController.swift
//  NetworkTest
//
//  Created by Hellen Soloviy on 11/16/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
//        Network.shared.setupUpdates()
//        Network.shared.start()
        
        
        
        let browser = SharedBrowser()
        browser.start()
        print(browser.services)
        
    }

}

