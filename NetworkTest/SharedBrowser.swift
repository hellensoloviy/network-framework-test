//
//  SharedBrowser.swift
//  NetworkTest
//
//  Created by Hellen Soloviy on 11/16/18.
//  Copyright © 2018 Hellen Soloviy. All rights reserved.
//

import Foundation

class SharedBrowser: NSObject {
    static let LocalDomain: String = "local."
    static let LocalType: String = "_camera._udp"

    
    let type: String = SharedBrowser.LocalType
    var browser: NetServiceBrowser
    
    var services: [NetService]
    var domains: [String]
    var sharedPointsList: [SharedPoint]
    
    var isSearching: Bool = false
    
    override init() {
        self.browser = NetServiceBrowser()
        self.services = [NetService]()
        self.domains = []
        self.sharedPointsList = [SharedPoint]()
        
        super.init()
        self.browser.delegate = self
    }
    
    func searchDomains() {
        print("-- domains search start with domains \(domains)")
        self.browser.searchForBrowsableDomains()
    }
    
    func searchServices() {
        self.browser.stop()
        print("-- services search start with domains \(domains)")
        print("-- services search start with services \(services)")
        self.browser.searchForServices(ofType: type, inDomain: domains.first ?? "")
    }
    
    func updateInterface () {
        print("-- updateInterface - services \(services)")

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
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("-- Search started!")
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("-- Search did stop!")
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
        print("adding a service \(aNetService.name)")
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
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        print("-DOMAIN - \(domainString)")
        
        print("adding a domain \(domainString)")
        self.domains.append(domainString)
        if !moreComing {
            searchServices()
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Search was not successful. Error code: \(errorDict[NetService.errorCode]!)")
        print("Error domain: \(errorDict[NetService.errorDomain]!)")
        print("Error: \(errorDict)")
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
        self.services.append(sender)
        self.updateInterface()
    }
    
    func netService(_ sender: NetService,
                    didAcceptConnectionWith inputStream: InputStream,
                    outputStream stream: OutputStream) {
        print("netServiceDidAcceptConnection:\(sender)");
    }
}

