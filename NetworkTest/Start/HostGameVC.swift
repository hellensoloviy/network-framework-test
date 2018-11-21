//
//  HostGameVC.swift
//  NetworkTest
//
//  Created by Hellen Soloviy on 11/20/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation
import UIKit

class HostGameVC: UIViewController {
    @IBOutlet weak var serverNameTF: UITextField!
    
    var server: UDPServer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameFieldVC {
            vc.server = server
        }
    }
    
    //MARK: - Actions
    @IBAction func hostNewGameTapped(_ sender: UIButton) {
        if let name = serverNameTF.text {
            server = UDPServer(named: name)
        } else {
            server = UDPServer()
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension HostGameVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
}
