import UIKit

final class MainViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        
        title = "ReSwiftMonitorBrowser"
        delegate = self
        preferredDisplayMode = .allVisible
        
        viewControllers = [
            historyViewController,
            jSONDetailViewController
        ]
        
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped(_:)))
        navigationItem.leftBarButtonItem = deleteButton
        let image = UIImage(named: "icons-settings")!
        let buttonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(settingButtonTapped(_:)))
        navigationItem.rightBarButtonItem = buttonItem
        
        historyViewController.didSelectRow = { [weak self] item in
            guard let _self = self else {
                return
            }
            _self.jSONDetailViewController.set(item)
            if _self.isCollapseSecondary == true {
                _self.navigationController?.pushViewController(_self.jSONDetailViewController, animated: true)
            }
        }
    }
    // MARK: - private
    private lazy var historyViewController = HistoryViewController.make()
    private lazy var jSONDetailViewController = JSONDetailViewController.make()
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    @objc private func settingButtonTapped(_ sender: Any) {
        let vc = SettingViewController.make()
        vc.reconnectHandler = { [weak self] in
            self?.historyViewController.reconnect()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    @objc private func deleteButtonTapped(_ sender: Any) {
        let ac = UIAlertController(title: "CLEAR_HISTORY".localized,
                                   message: "ALL_CELAR_HISTORY".localized,
                                   preferredStyle: .alert)
        ac.addAction(.init(title: "CANCEL".localized, style: .cancel, handler: nil))
        ac.addAction(.init(title: "DELETE".localized, style: .destructive, handler: { [weak self] _ in
            self?.historyViewController.removeAll()
        }))
        present(ac, animated: true, completion: nil)
    }
}

extension MainViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return splitViewController.isCollapseSecondary
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        historyViewController.updateSearchText(text)
    }
}

extension UISplitViewController {
    var isCollapseSecondary: Bool {
        return traitCollection.containsTraits(in: UITraitCollection(horizontalSizeClass: .compact))
    }
}
