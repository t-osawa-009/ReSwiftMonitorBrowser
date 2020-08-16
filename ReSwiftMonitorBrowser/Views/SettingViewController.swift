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
        case serviceType
        
        func toString() -> String {
            switch self {
            case .reconnect:
                return "RECONNECT".localized
            case .serviceType:
                return "serviceType"
            }
        }
    }
    
    @objc private func closeButtonTapped(_ snnder: Any) {
        dismiss(animated: true, completion: nil)
    }
    private var serviceType: String!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = .init()
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
        switch item {
        case .serviceType:
            cell.textLabel?.text = "serviceType: " + UserDefaultsWrapper.default.serviceType
        case .reconnect:
            cell.textLabel?.text = item.toString()
        }
        return cell
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = Item.allCases[indexPath.row]
        switch item {
        case .reconnect:
            reconnectHandler?()
        case .serviceType:
            var uiTextField = UITextField()
            let ac = UIAlertController(title: "EDIT_SERVICETYPE".localized,
                                       message: "MAX_15_CHARACTERS".localized,
                                       preferredStyle: .alert)
            let aa = UIAlertAction(title: "OK".localized, style: .default) { [weak self] (action) in
                let text = (uiTextField.text ?? "").removeSpecialCharacters()
                UserDefaultsWrapper.default.serviceType = String(text.prefix(15))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .removeWhitespace()
                self?.tableView.reloadData()
            }
            let cancel = UIAlertAction(title: "CANCEL".localized, style: .cancel, handler: nil)
            ac.addTextField { (textField) in
                textField.text = UserDefaultsWrapper.default.serviceType
                textField.keyboardType = .emailAddress
                uiTextField = textField
            }
            ac.addAction(aa)
            ac.addAction(cancel)
            present(ac, animated: true, completion: nil)
        }
    }
}
