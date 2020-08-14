import UIKit
import ReSwift

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(rightButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightButton
        self.title = "QiitaAPI"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellReuseIdentifier)
        
        tableView.dataSource = dataSource
        fetchArticle { (array) in
            store.dispatch(QiitaActionEnum.responseQiitaObjects(array))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    private func fetchArticle(completion: @escaping ([QiitaObject]) -> Swift.Void) {
        let url = "https://qiita.com/api/v2/items"
        
        guard var urlComponents = URLComponents(string: url) else {
            return
        }
        
        store.dispatch(QiitaActionEnum.isLoading(true))
        urlComponents.queryItems = [
            URLQueryItem(name: "per_page", value: "50"),
        ]
        
        let task = URLSession.shared.dataTask(with: urlComponents.url!) { data, response, error in
            store.dispatch(QiitaActionEnum.isLoading(false))
            if let error = error {
                store.dispatch(QiitaActionEnum.error(error))
                return
            }
            
            
            guard let jsonData = data, !jsonData.isEmpty else {
                completion([])
                return
            }
            
            do {
                let articles = try JSONDecoder().decode([QiitaObject].self, from: jsonData)
                completion(articles)
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    private func update(with list: [QiitaObject], animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, QiitaObject>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(list)
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
     @objc private func rightButtonTapped(_ sender: Any) {
        fetchArticle { (array) in
            store.dispatch(QiitaActionEnum.responseQiitaObjects(array))
        }
    }
    
    enum Section: CaseIterable {
        case main
    }
    
    private static let cellReuseIdentifier = "cell"
    private lazy var dataSource = makeDataSource()
    private func makeDataSource() -> UITableViewDiffableDataSource<Section, QiitaObject> {
        return UITableViewDiffableDataSource(tableView: tableView,
                                             cellProvider: { tableView, indexPath, article in
                                                let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellReuseIdentifier, for: indexPath)
                                                cell.textLabel?.text = article.title
                                                cell.detailTextLabel?.text = article.user.name
                                                return cell
        })
    }
    
    @IBOutlet private weak var indicator: UIActivityIndicatorView! {
        didSet {
            indicator.hidesWhenStopped = true
        }
    }
    @IBOutlet private weak var tableView: UITableView!
    private var articles: [QiitaObject] = [] {
        didSet {
            update(with: articles)
        }
    }
    private var isLoading = false {
        didSet {
            if isLoading {
                indicator.startAnimating()
            } else {
                indicator.stopAnimating()
            }
        }
    }
    
    private var error: Error? {
        didSet {
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

extension ViewController: StoreSubscriber {
    func newState(state: AppState) {
        articles = state.qiitaState.qiitaObjects
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = state.qiitaState.isLoading
        }
        error = state.qiitaState.error
    }
}

struct QiitaObject: Codable, Equatable, Hashable {
    var title: String
    var user: User
    let id: String
    struct User: Codable, Equatable {
        var name: String
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
