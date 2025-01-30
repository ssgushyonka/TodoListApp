
import UIKit

class ViewController: UIViewController {
    
    let searchController = UISearchController()
    
    private var tasks: [TodoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Задачи"
        navigationItem.searchController = searchController
        setupViews()
        setupConstraints()
        
        fetchTodosFromCoreData()
        loadTodosFromAPI()
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.Identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    func setupViews() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    func loadTodosFromAPI() {
        APIService().fetchTodoItems { [weak self] todoItems in
            guard let self = self else { return }
            guard let todoItems = todoItems else { return }
            CoreDataStack.shared.saveTodoItemsToCoreData(todoItems)
            self.fetchTodosFromCoreData()
        }
    }
    
    func fetchTodosFromCoreData() {
        CoreDataStack.shared.fetchTodosFromCoreData { [weak self] tasks in
            guard let self = self else { return }
            self.tasks = tasks
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.Identifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        let task = tasks[indexPath.row]
        cell.configure(with: task.todo ?? "", isCompleted: task.completed)
        
        cell.toggleCompletion = { [weak self] in
            guard let self = self else { return }
            self.tasks[indexPath.row].completed.toggle()
            CoreDataStack.shared.saveContext(context: CoreDataStack.shared.viewContext)
        }
        return cell
    }
}
