
import UIKit

class ViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    private var isFiltering: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    private var tasks: [TodoItem] = []
    private var filteredTasks: [TodoItem] = []
    
    private let toolbar: UIToolbar = {
           let toolbar = UIToolbar()
           toolbar.translatesAutoresizingMaskIntoConstraints = false
           return toolbar
       }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.Identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTaskCount()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = UIColor(red: 0xFE / 255, green: 0xD7 / 255, blue: 0x02 / 255, alpha: 1)
        title = "Задачи"
        
        let backButton = UIBarButtonItem()
        backButton.title = "Назад"
        navigationItem.backBarButtonItem = backButton
        navigationController?.isToolbarHidden = false
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        definesPresentationContext = true
        
        setupViews()
        setupConstraints()
        fetchTodosFromCoreData()
        if tasks.isEmpty {
            loadTodosFromAPI()
        }
    }
    func setupToolbar() {
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(editButtonTapped))
        editButton.tintColor = UIColor(red: 0xFE / 255, green: 0xD7 / 255, blue: 0x02 / 255, alpha: 1)
        let buttonSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let taskCountLabel = UILabel()
        let taskCountItem = UIBarButtonItem(customView: taskCountLabel)
        taskCountLabel.text = "\(tasks.count) задач"
        taskCountLabel.font = UIFont.systemFont(ofSize: 11)
        taskCountLabel.numberOfLines = 0
        taskCountLabel.lineBreakMode = .byWordWrapping
        taskCountLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        toolbar.items = [buttonSpace, taskCountItem, buttonSpace, editButton]
        
        updateTaskCount()
    }
    func updateTaskCount() {
        guard let toolbarItems = toolbar.items,
              let taskCountItem = toolbarItems.first(where: { $0.customView is UILabel }),
              let taskCountLabel = taskCountItem.customView as? UILabel else {
            return
        }
        taskCountLabel.text = "\(tasks.count) задач"
    }
    
    @objc func editButtonTapped() {
        let alertController = UIAlertController(title: "Новая задача", message: "Введите описание задачи", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Описание задачи"
        }
        
        let addAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let textField = alertController.textFields?.first, let todoText = textField.text, !todoText.isEmpty {
                self.addNewTask(todo: todoText)
            }
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func addNewTask(todo: String) {
        let newTaskId = (tasks.last?.id ?? 0) + 1
        let userId = 1
        let viewModel = TodoViewModel()
        viewModel.addItem(id: Int(newTaskId), todo: todo, completed: false, userId: userId)
        fetchTodosFromCoreData()
        tableView.reloadData()
        updateTaskCount()
    }
    //MARK: - Set up UI and constraints
    
    func setupViews() {
        view.addSubview(tableView)
        view.addSubview(toolbar)
        setupToolbar()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    //MARK: - load data from api and fetch from coredata
    
    func loadTodosFromAPI() {
        APIService().fetchTodoItems { [weak self] todoItems in
            guard let self = self else { return }
            guard let todoItems = todoItems else { return }
            CoreDataStack.shared.saveTodoItemsToCoreData(todoItems)
            if self.tasks.isEmpty {
                self.fetchTodosFromCoreData()
                self.updateTaskCount()
            }
        }
    }
    
    func fetchTodosFromCoreData() {
        CoreDataStack.shared.fetchTodosFromCoreData { [weak self] tasks in
            guard let self = self else { return }
            self.tasks = tasks
            print("Loaded from core data:", tasks.map { "\($0.todo ?? "nil") - \($0.completed)" })
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateTaskCount()
            }
        }
    }
}
//MARK: - VC extensions

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredTasks.count : tasks.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.Identifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        
        let task = isFiltering ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        cell.configure(with: task.todo ?? "", isCompleted: task.completed)
        
        cell.toggleCompletion = { [weak self] in
            guard let self = self else { return }
            let indexInTasks = self.tasks.firstIndex(where: { $0.objectID == task.objectID }) ?? indexPath.row
            
            task.completed.toggle()
            CoreDataStack.shared.saveContext(context: CoreDataStack.shared.viewContext)
            
            if isFiltering {
                filteredTasks[indexPath.row] = task
            } else {
                tasks[indexInTasks] = task
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            
            let indexInTasks = self.tasks.firstIndex(where: { $0.objectID == task.objectID }) ?? indexPath.row
            
            if isFiltering {
                filteredTasks.remove(at: indexPath.row)
            }
            tasks.remove(at: indexInTasks)
            
            CoreDataStack.shared.viewContext.delete(task)
            CoreDataStack.shared.saveContext(context: CoreDataStack.shared.viewContext)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateTaskCount()
        }
        
        return cell
    }
    
    // for task detail VC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = isFiltering ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        let taskDetailVC = TaskDetailViewController()
        taskDetailVC.taskText = task.todo
        taskDetailVC.task = task
        taskDetailVC.onSave = { [weak self] updatedText in
            guard let self = self else { return }
        
            task.todo = updatedText
            CoreDataStack.shared.saveContext(context: CoreDataStack.shared.viewContext)
            if isFiltering {
                filteredTasks[indexPath.row] = task
            }
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(taskDetailVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredTasks = tasks
            tableView.reloadData()
            return
        }
        filteredTasks = tasks.filter { $0.todo?.localizedCaseInsensitiveContains(searchText) ?? false }
        tableView.reloadData()
    }
}
