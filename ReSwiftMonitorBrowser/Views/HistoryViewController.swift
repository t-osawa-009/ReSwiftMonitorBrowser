import UIKit

final class HistoryViewController: UIViewController {
    // MARK: - internal
    class func make() -> HistoryViewController {
        let storyboard = UIStoryboard(name: "HistoryViewController", bundle: Bundle(for: HistoryViewController.self))
        let viewController = storyboard.instantiateInitialViewController() as! HistoryViewController
        return viewController
    }
    var didSelectRow: ((PeerObject) -> Void)?
    
    func removeAll() {
        items.removeAll(keepingCapacity: true)
        filteredItems.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func reconnect() {
        multipeerConnectivityWrapper.setup(serviceType: settingsServiceType)
        multipeerConnectivityWrapper.start()
    }
    
    func updateSearchText(_ text: String) {
        if text.isEmpty {
            filteredItems = peerIDDic[key] ?? []
        } else {
            filteredItems = peerIDDic[key] ?? [].filter { $0.actionStr.lowercased().contains(text.lowercased()) || $0.dateString.contains(text.lowercased()) }
        }
        filerWord = text
        throttleAction { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(userListViewController)
        view.addSubview(userListViewController.view)
        userListViewController.didMove(toParent: self)
        
        userListViewController.didSelectRow = { [weak self] key in
            guard let _self = self else {
                return
            }
            self?.key = key
            if let text = self?.filerWord {
                if text.isEmpty {
                    _self.filteredItems = _self.peerIDDic[_self.key] ?? []
                } else {
                    _self.filteredItems = _self.peerIDDic[_self.key] ?? [].filter { $0.actionStr.lowercased().contains(text.lowercased()) || $0.dateString.contains(text.lowercased()) }
                }
            } else {
                _self.filteredItems = _self.peerIDDic[_self.key] ?? []
            }
            self?.throttleAction { [weak self] in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        
        multipeerConnectivityWrapper.didReceiveDataHandler = { [weak self] object in
            guard let _self = self else {
                return
            }
            self?.items.append(object)
            self?.items.sort(by: { $0.date > $1.date })
            _self.peerIDDic = Dictionary(grouping: _self.items) { item -> String in
                return item.peerID.displayName
            }.reduce([String: [PeerObject]]()) { dic, tuple in
                var dic = dic
                dic[tuple.key] = tuple.value
                return dic
            }
            
            _self.userListViewController.setPeerIDDic(_self.peerIDDic)
            if _self.peerIDDic.keys.count == 1 {
                _self.key = _self.peerIDDic.keys.first ?? ""
            }
            
            if let text = self?.filerWord {
                if text.isEmpty {
                    _self.filteredItems = _self.peerIDDic[_self.key] ?? []
                } else {
                    _self.filteredItems = _self.peerIDDic[_self.key] ?? [].filter { $0.actionStr.lowercased().contains(text.lowercased()) || $0.dateString.contains(text.lowercased()) }
                }
            } else {
                _self.filteredItems = _self.peerIDDic[_self.key] ?? []
            }
            self?.throttleAction { [weak self] in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        
        multipeerConnectivityWrapper.sessionDidChangeHandler = { [weak self] state, peerId in
            self?.title = peerId.displayName
            self?.statusLabel.text = state.rawValue
            switch state {
            case .connected, .connecting:
                self?.indicator.stopAnimating()
            case .notConnected:
                self?.indicator.startAnimating()
            }
        }
        
        multipeerConnectivityWrapper.start()
        indicator.startAnimating()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        statusLabel.text = multipeerConnectivityWrapper.state.rawValue
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userListViewController.view.frame = containerView.frame
    }
    
    // MARK: - private
    private lazy var multipeerConnectivityWrapper = MultipeerConnectivityWrapper(serviceType: settingsServiceType)
    private var settingsServiceType: String {
        return UserDefaultsWrapper.default.serviceType
    }
    private lazy var userListViewController = UserListViewController.make()
    private var key = ""
    private let throttleAction = DispatchQueue.global().throttle(delay: .microseconds(500))
    @IBOutlet private weak var indicator: UIActivityIndicatorView! {
        didSet {
            indicator.hidesWhenStopped = true
        }
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = .init()
        }
    }
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!
    private var peerIDDic = [String: [PeerObject]]()
    private var items: [PeerObject] = []
    private var filteredItems: [PeerObject] = []
    private var filerWord: String?
}

extension HistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        let item = filteredItems[indexPath.row]
        let text: String = {
            if let index1 = item.actionStr.range(of: "(") {
                return String(item.actionStr.prefix(upTo: index1.lowerBound))
            }
            return item.actionStr
        }()
        cell.textLabel?.text = item.dateString + "\n" + text
        return cell
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filteredItems[indexPath.row]
        didSelectRow?(item)
    }
}

