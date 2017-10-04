//
//  ConnectivityManager.swift
//  TicTac
//
//  Created by Kaushal Deo on 10/3/17.
//  Copyright © 2017 Scorpion Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

let Manager = ConnectivityManager()

class ConnectivityManager : NSObject, MCSessionDelegate {
    
    fileprivate let peerID : MCPeerID
    fileprivate let session : MCSession
    let browserViewController : MCBrowserViewController
    fileprivate let advertiser : MCAdvertiserAssistant
    
    override init() {
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: self.peerID)
        self.browserViewController = MCBrowserViewController(serviceType: "my-game", session: self.session)
        self.advertiser = MCAdvertiserAssistant(serviceType: "my-game", discoveryInfo: nil, session: self.session)
        super.init()
        
        //Set up the delegate
        self.session.delegate = self
    }
    
    
    func advertise(_ start:Bool) {
        if start {
            self.advertiser.start()
            return
        }
        self.advertiser.stop()
    }
    
    
    func send(move: Move) {
        let data = try! JSONEncoder().encode(move)
        do {
           try self.session.send(data, toPeers: self.session.connectedPeers, with: .reliable)
        }
        catch let dataError {
            print("error while sending data",dataError)
        }
       
    }
    
    //MARK: - Session Delegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    
    // Received data from remote peer.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let move = try! JSONDecoder().decode(Move.self, from: data)
        DispatchQueue.main.async {
            print(move)
        }
    }
    
    
    // Received a byte stream from remote peer.
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    
    // Start receiving a resource from remote peer.
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
}
