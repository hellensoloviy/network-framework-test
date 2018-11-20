//
//  ViewController.swift
//  NetworkTest
//
//  Created by Hellen Soloviy on 11/16/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var server: UDPServer?
    var client: UDPClient?
    var browser: SharedBrowser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        browser = SharedBrowser()
        browser?.searchDomains()
//        print(browser.services)
        
    }
    
    @IBAction func serverButtonTapped(_ sender: UIButton) {
        server = UDPServer()
    }
    
    @IBAction func clientButtonTapped(_ sender: UIButton) {
        client = UDPClient(name: "iPhone Lemberg")
    }

}

