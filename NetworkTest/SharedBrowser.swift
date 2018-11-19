//
//  SharedBrowser.swift
//  NetworkTest
//
//  Created by Hellen Soloviy on 11/16/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation

class SharedBrowser: NSObject {
    let type: String = "_camera._udp"
    var browser: NetServiceBrowser
    
    var services: [NetService]
    var sharedPointsList: [SharedPoint]
    
    override init() {
        self.browser = NetServiceBrowser()
        self.services = [NetService]()
        self.sharedPointsList = [SharedPoint]()
        
        super.init()
        self.browser.delegate = self
    }
    
    func start() {
        self.services.removeAll()
        self.browser.delegate = self
        self.browser.searchForBrowsableDomains()
    }
    
    func updateInterface () {
        for service in services {
            if service.port == -1 {
                print("service \(service.name) of type \(service.type)" +
                    " not yet resolved")
                service.delegate = self
                service.resolve(withTimeout:10)
            } else {
                print("service \(service.name) of type \(service.type)," +
                    "port \(service.port), addresses \(service.addresses)")
            }
        }
    }
    
}

extension SharedBrowser: NetServiceBrowserDelegate, NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        self.updateInterface()
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
        print("adding a service")
        self.services.append(aNetService)
        if !moreComing {
            self.updateInterface()
        }
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
        if let ix = self.services.index(of:aNetService) {
            self.services.remove(at:ix)
            print("removing a service")
            if !moreComing {
                self.updateInterface()
            }
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Search was not successful. Error code: \(errorDict[NetService.errorCode]!)")
    }
    
    func netServiceWillPublish(_ sender: NetService) {
        print("netServiceWillPublish:\(sender)");  //This method is called
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]){
        print("didNotPublish:\(sender)");
    }
    
    func netServiceDidPublish(_ sender: NetService) {
        print("netServiceDidPublish:\(sender)");
    }
    func netServiceWillResolve(_ sender: NetService) {
        print("netServiceWillResolve:\(sender)");
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("netServiceDidNotResolve:\(sender)");
    }
    
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        print("netServiceDidUpdateTXTRecordData:\(sender)");
    }
    
    func netServiceDidStop(_ sender: NetService) {
        print("netServiceDidStopService:\(sender)");
    }
    
    func netService(_ sender: NetService,
                    didAcceptConnectionWith inputStream: InputStream,
                    outputStream stream: OutputStream) {
        print("netServiceDidAcceptConnection:\(sender)");
    }
}

