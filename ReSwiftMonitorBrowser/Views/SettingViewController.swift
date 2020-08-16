import UIKit

final class SettingViewController: UIViewController {
    // MARK: - internal
    class func make() -> SettingViewController {
        let storyboard = UIStoryboard(name: "SettingViewController", bundle: Bundle(for: SettingViewController.self))
        let viewController = storyboard.instantiateInitialViewController() as! SettingViewController
        return viewController
    }
    var reconnectHandler: (() -> Void)?
    // MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonTapped(_:)))
        navigationItem.rightBarButtonItem = buttonItem
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
    
    // MARK: - private
    private enum Item: String, CaseIterable {
        case reconnect
        
        func toString() -> String {
            switch self {
            case .reconnect:
                return "RECONNECT".localized
            }
        }
    }
    
    @objc private func closeButtonTapped(_ snnder: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
}

extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Item.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        let item = Item.allCases[indexPath.row]
        cell.textLabel?.text = item.toString()
        return cell
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = Item.allCases[indexPath.row]
        switch item {
        case .reconnect:
            reconnectHandler?()
        }
    }
}
