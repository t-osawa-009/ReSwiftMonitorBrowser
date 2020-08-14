import UIKit

final class JSONDetailViewController: UIViewController {
    // MARK: - internal
    class func make() -> JSONDetailViewController {
        let storyboard = UIStoryboard(name: "JSONDetailViewController", bundle: Bundle(for: JSONDetailViewController.self))
        let viewController = storyboard.instantiateInitialViewController() as! JSONDetailViewController
        return viewController
    }
    
    func set(_ object: PeerObject) {
        self.object = object
        title = object.stateStr
        tableView.reloadData()
    }
    
    // MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
    
    // MARK: - private
    private enum Item: CaseIterable {
        case date
        case state
        case json
    }
    private var object: PeerObject?
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = .init()
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
}

extension JSONDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard object != nil else {
            return 0
        }
        return Item.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard object != nil else {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        let item = Item.allCases[indexPath.section]
        switch item {
        case .date:
            cell.textLabel?.text = object?.dateString ?? ""
        case .state:
            let text = (object?.stateStr ?? "")
            cell.textLabel?.text = text.replacingOccurrences(of: ",", with: ",\n")
        case .json:
            let text = (object?.actionStr ?? "")
            cell.textLabel?.text = text.replacingOccurrences(of: ",", with: ",\n")
        }
        return cell
    }
}

extension JSONDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = Item.allCases[indexPath.section]
        switch item {
        case .date:
            break
        case .state:
            let ac = UIAlertController(title:"COPY".localized,
                                       message: "WOULD_YOU_LIKE_A_COPY".localized,
                                       preferredStyle: .alert)
            ac.addAction(.init(title: "CANCEL".localized, style: .cancel, handler: nil))
            ac.addAction(.init(title: "COPY".localized, style: .destructive, handler: { [weak self] _ in
                let text = (self?.object?.stateStr ?? "")
                let board = UIPasteboard.general
                board.string = text
            }))
            present(ac, animated: true, completion: nil)
        case .json:
            let ac = UIAlertController(title:"COPY".localized,
                                       message: "WOULD_YOU_LIKE_A_COPY".localized,
                                       preferredStyle: .alert)
            ac.addAction(.init(title: "CANCEL".localized, style: .cancel, handler: nil))
            ac.addAction(.init(title: "COPY".localized, style: .destructive, handler: { [weak self] _ in
                let text = (self?.object?.actionStr ?? "")
                let board = UIPasteboard.general
                board.string = text
            }))
            present(ac, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item = Item.allCases[section]
        switch item {
        case .date:
            return "Date"
        case .state:
            return "State"
        case .json:
            return "Action"
        }
    }
}
