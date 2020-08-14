import Foundation
import MultipeerConnectivity

private var formatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.formatterBehavior = .behavior10_4
    dateFormatter.dateFormat = "HH:mm:ss.SSS"
    return dateFormatter
}()

struct PeerObject {
    let date: Date
    let json: [String: Any]?
    let peerID: MCPeerID
    var dateString: String
    let actionStr: String
    let stateStr: String
    let data: Data
    init(data: Data, peerID: MCPeerID) {
        self.data = data
        self.peerID = peerID
        let decoder = JSONDecoder()
        if let json = try? decoder.decode([String: AnyDecodable].self, from: data),
            !json.isEmpty {
            let result = json.mapValues({ $0.value })
            let actionResult = result["action"]
            if let dic = actionResult as? [String: Any],
                let _action = dic["type"] as? String {
                self.actionStr = _action
            } else {
                if let _action = actionResult as? String {
                    self.actionStr = _action
                } else {
                    self.actionStr = "No_action"
                }
            }
            if let state = result["state"] {
                self.stateStr = "\(state)"
            } else {
                self.stateStr = "No_state"
            }
            if let time = result["timestamp"] as? TimeInterval {
                let date = Date(timeIntervalSinceReferenceDate: time)
                self.date = date
            } else {
                date = Date()
            }
            
            self.json = result
        } else {
            self.stateStr = ""
            self.json = nil
            self.actionStr = ""
            dateString = ""
            date = Date()
        }
        dateString = formatter.string(from: self.date)
    }
}

