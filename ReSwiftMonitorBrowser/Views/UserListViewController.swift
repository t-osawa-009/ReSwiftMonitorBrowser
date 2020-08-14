import Foundation
import UIKit

final class UserListViewController: UIViewController {
    // MARK: - internal
    class func make() -> UserListViewController {
        let storyboard = UIStoryboard(name: "UserListViewController", bundle: Bundle(for: UserListViewController.self))
        let viewController = storyboard.instantiateInitialViewController() as! UserListViewController
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
    
    var didSelectRow: ((String) -> Void)?
    func setPeerIDDic(_ peerIDDic: [String: [PeerObject]]) {
        self.peerIDDic = peerIDDic
        self.keys = peerIDDic.keys.map({$0})
        if keys.count == 1 {
            selectedKey = keys.first
        }
        debounceAction { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - private
    private var peerIDDic: [String: [PeerObject]] = [:]
    private var keys = [String]()
    private var selectedKey: String?
    private let debounceAction = DispatchQueue.global().debounce(delay: .milliseconds(500))
    private let throttleAction = DispatchQueue.global().throttle(delay: .milliseconds(500))
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = .init()
        }
    }
}

extension UserListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .boldSystemFont(ofSize: 11)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        let item = keys[indexPath.row]
        cell.selectionStyle = .none
        cell.backgroundColor = {
            if selectedKey == item {
                return .blue
            } else {
                return .clear
            }
        }()
        cell.textLabel?.text = item
        return cell
    }
}

extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = keys[indexPath.row]
        selectedKey = item
        didSelectRow?(item)
        throttleAction { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}
