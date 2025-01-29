
import Foundation
import UIKit

class ViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return tableView
    }()
    
    private let tasksLabel: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.textColor = .white
        label.font = .systemFont(ofSize: 34, weight: .bold)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    func setupSearchController() {
//        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search"
//        navigationItem.searchController = searchController
//        definesPresentationContext = true
//    }
//    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        setupViews()
        setupConstraints()
    }
    func setupViews() {
        view.addSubview(tableView)
        view.addSubview(tasksLabel)
    }
    
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            tasksLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tasksLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            tasksLabel.widthAnchor.constraint(equalToConstant: 360),
            tasksLabel.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    
}

//extension ViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        <#code#>
//    }
//}
