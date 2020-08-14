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
    
    func updateSearchText(_ text: String) {
        if text.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { $0.actionStr.lowercased().contains(text.lowercased()) || $0.dateString.contains(text.lowercased()) }
        }
        filerWord = text
        debounceAction { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        MultipeerConnectivityWrapper.shared.didReceiveDataHandler = { [weak self] object in
            guard let _self = self else {
                return
            }
            self?.items.append(object)
            self?.items.sort(by: { $0.date > $1.date })
            if let text = self?.filerWord {
                if text.isEmpty {
                    _self.filteredItems = _self.items
                } else {
                    _self.filteredItems = _self.items.filter { $0.actionStr.lowercased().contains(text.lowercased()) || $0.dateString.contains(text.lowercased()) }
                }
            } else {
                _self.filteredItems = _self.items
            }
            self?.debounceAction { [weak self] in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        
        MultipeerConnectivityWrapper.shared.sessionDidChangeHandler = { [weak self] state, peerId in
            self?.title = peerId.displayName
            self?.statusLabel.text = state.rawValue
            switch state {
            case .connected, .connecting:
                self?.indicator.stopAnimating()
            case .notConnected:
                self?.indicator.startAnimating()
            }
        }
        
        MultipeerConnectivityWrapper.shared.start()
        indicator.startAnimating()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        statusLabel.text = MultipeerConnectivityWrapper.shared.state.rawValue
    }
    
    // MARK: - private
    private let debounceAction = DispatchQueue.global().debounce(delay: .milliseconds(500))
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
    @IBOutlet private weak var statusLabel: UILabel!
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
        cell.textLabel?.text = item.dateString + "\n" + item.actionStr
        return cell
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filteredItems[indexPath.row]
        didSelectRow?(item)
    }
}
