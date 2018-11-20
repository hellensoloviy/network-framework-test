//
//  SearchGameVC.swift
//  NetworkTest
//
//  Created by Hellen Soloviy on 11/20/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation
import UIKit

class BrowsingResultTableViewCell: UITableViewCell {
    static let identifier = "BrowsingResultTableViewCell"
    
    @IBOutlet weak var resultLabel: UILabel!
    
    func config(with service: NetService) {
        resultLabel.text = service.name
        print("Find service named \(service.name)")
    }
    
}

class SearchGameVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var browser: SharedBrowser?
    var data: [NetService] = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        browser = SharedBrowser()
        browser?.searchDomains()
        browser?.delegate = self
    }
   
    @IBAction func connectTapped(_ sender: UIButton) {
        print("Ready to host a game")
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SearchGameVC: UITableViewDelegate {
    
}

extension SearchGameVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BrowsingResultTableViewCell.identifier, for: indexPath) as! BrowsingResultTableViewCell
        cell.config(with: data[indexPath.row])
        
        return cell
    }
    
}

extension SearchGameVC: BrowsingDelegate {
    func domainsDidUpdate(_ domains: [String]) {
//        data = domains
        print("-- Domains data did update!")
    }
    
    func servicesListDidUpdate(_ services: [NetService]) {
        data = services
        print("-- Services data did update!")
    }
    
    func browsingStopped() {
        print("Search stopped")
    }
    
    
}
