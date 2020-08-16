import Foundation
import MultipeerConnectivity

final class MultipeerConnectivityWrapper: NSObject {
    // MARK: - internal
    var sessionDidChangeHandler: ((SessionState, MCPeerID) -> Void)?
    var didReceiveDataHandler: ((PeerObject) -> Void)?
    
    func start() {
        advertiserAssistant.delegate = self
        advertiserAssistant.start()
        
        nearbyServiceBrowser.delegate = self
        nearbyServiceBrowser.startBrowsingForPeers()
        
        session.delegate = self
        restartAdvertising()
    }
    
    func reset() {
        restartAdvertising()
        stop()
        start()
    }
    
    func stop() {
        advertiserAssistant.delegate = nil
        advertiserAssistant.stop()
        
        nearbyServiceBrowser.delegate = nil
        nearbyServiceBrowser.startBrowsingForPeers()
        
        disconnect()
    }
    
    func disconnect() {
        session.delegate = nil
        session.disconnect()
    }
    
    func stopAdvertising() {
        nearbyServiceAdvertiser.delegate = nil
        nearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    func restartAdvertising() {
        stopAdvertising()
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func send(data: Data) {
        _ = try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
    
    // MARK: - initializer
    private override init() {
        peerID = .init(displayName: UIDevice.current.name)
        super.init()
    }
    
    convenience init(serviceType: String) {
        self.init()
        setup(serviceType: serviceType)
    }
    
    func setup(serviceType: String) {
        nearbyServiceBrowser = .init(peer: peerID,
                                     serviceType: serviceType)
        session = .init(peer: peerID)
        advertiserAssistant = .init(serviceType: serviceType,
                                    discoveryInfo: nil,
                                    session: session)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                                            discoveryInfo: nil,
                                                            serviceType: serviceType)
        session.delegate = nil
        session.delegate = self
    }
    
    // MARK: - private
    private var peerID: MCPeerID
    private var nearbyServiceBrowser: MCNearbyServiceBrowser!
    private var session: MCSession!
    private var advertiserAssistant: MCAdvertiserAssistant!
    private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    private(set) var state: SessionState = .notConnected
}

extension MultipeerConnectivityWrapper: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async { [weak self] in
                if self?.state == .connected {
                    self?.restartAdvertising()
                }
                self?.state = .notConnected
                self?.sessionDidChangeHandler?(.notConnected, peerID)
            }
        case .connecting:
            DispatchQueue.main.async { [weak self] in
                self?.state = .connecting
                self?.sessionDidChangeHandler?(.connecting, peerID)
            }
        case .connected:
            DispatchQueue.main.async { [weak self] in
                if self?.state != .connected {
                    self?.stopAdvertising()
                }
                self?.state = .connected
                self?.sessionDidChangeHandler?(.connected, peerID)
            }
        @unknown default:
            fatalError("no support")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            let object = PeerObject(data: data, peerID: peerID)
            self?.didReceiveDataHandler?(object)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        if let error = error {
            logMessage(message: error.localizedDescription)
        }
    }
}

extension MultipeerConnectivityWrapper: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 0)
        self.session = session
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        logMessage(message: "lost peerID: \(peerID.displayName)")
    }
}

extension MultipeerConnectivityWrapper: MCAdvertiserAssistantDelegate {
    
}

extension MultipeerConnectivityWrapper: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
}
