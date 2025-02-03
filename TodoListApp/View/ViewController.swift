import Foundation
import CoreData
import UIKit

class ViewController: UIViewController {
    // For loading view
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()

    
    let viewModel = TodoViewModel()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var isFiltering: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    private var tasks: [TodoItem] = []
    private var filteredTasks: [TodoItem] = []
    var taskCountLabel: UILabel?
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.Identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = UIColor(red: 0xFE / 255, green: 0xD7 / 255, blue: 0x02 / 255, alpha: 1)
        title = "Задачи"
        
        let backButton = UIBarButtonItem()
        backButton.title = "Назад"
        navigationItem.backBarButtonItem = backButton
        navigationController?.isToolbarHidden = false
        
        // Setup searchController and mic button
        
        navigationItem.searchController = searchController
        if let microphoneImage = UIImage(systemName: "mic.fill") {
            searchController.searchBar.showsBookmarkButton = true
            searchController.searchBar.setImage(microphoneImage, for: .bookmark, state: .normal)
        }
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        definesPresentationContext = true
        setupViews()
        setupConstraints()
        updateTaskCount()
        
        
        setupLoadingIndicator()
        activityIndicator.startAnimating()
        loadingLabel.isHidden = false
        viewModel.loadInitialDataIfNeeded { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.loadingLabel.isHidden = true
            self.tableView.reloadData()
            self.updateTaskCount()
        }
        
        fetchTodosFromCoreData()
        if tasks.isEmpty {
            loadTodosFromAPI()
        }
    }
    func setupNavigationBarBottomItems() {
        let taskCountLabel = UILabel()
        taskCountLabel.textAlignment = .center
        taskCountLabel.font = UIFont.systemFont(ofSize: 14)
        self.taskCountLabel = taskCountLabel
        
        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        editButton.tintColor = UIColor(red: 0xFE/255, green: 0xD7/255, blue: 0x02/255, alpha: 1)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [ flexibleSpace, UIBarButtonItem(customView: taskCountLabel), flexibleSpace, editButton]
        navigationController?.toolbar.barTintColor = UIColor( red: 0x27/255.0, green: 0x27/255.0, blue: 0x29/255.0, alpha: 1.0)
        navigationController?.toolbar.isTranslucent = false
        navigationController?.isToolbarHidden = false
    }
    
    // Func for update tasks count in Navigation bar label
    func updateTaskCount() {
        guard let taskCountLabel = self.taskCountLabel else { return }
        DispatchQueue.main.async {
            taskCountLabel.text = "\(self.tasks.count) Задач"
            taskCountLabel.sizeToFit()
        }
    }

    @objc func editButtonTapped() {
        let alertController = UIAlertController(title: "Новая задача", message: "Введите задачу", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Задача"
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
        CoreDataStack.shared.saveContext(context: CoreDataStack.shared.viewContext)
        DispatchQueue.main.async{
            self.fetchTodosFromCoreData()
            self.tableView.reloadData()
            self.updateTaskCount()
        }
    }
    //MARK: - Set up UI and constraints
    func setupViews() {
        view.addSubview(tableView)
        setupNavigationBarBottomItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    //MARK: - load data from api and fetch from coredata
    func loadTodosFromAPI() {
        APIService().fetchTodoItems { [weak self] todoItems in
            guard let self = self else { return }
            guard let todoItems = todoItems else { return }
            CoreDataStack.shared.saveTodoItemsToCoreData(todoItems)
            if self.tasks.isEmpty {
                DispatchQueue.main.async {
                    self.fetchTodosFromCoreData()
                    self.tableView.reloadData()
                    self.updateTaskCount()
                }
            }
        }
    }
    func fetchTodosFromCoreData() {
        CoreDataStack.shared.fetchTodosFromCoreData { [weak self] tasks in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tasks = tasks
                print("Loaded from core data:", tasks.map { "\($0.todo ?? "nil") - \($0.completed)" })
                self.tableView.reloadData()
                self.updateTaskCount()
            }
        }
    }
    //Task button func in contentView for tableViewCell
    private func editTask(at indexPath: IndexPath) {
        let task = isFiltering ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        let taskDetailVC = TaskDetailViewController()
        taskDetailVC.taskText = task.todo
        taskDetailVC.task = task
        
        taskDetailVC.onSave = { [weak self] updatedText in
            guard let self = self else { return }
            task.todo = updatedText
            CoreDataStack.shared.saveContext(context: CoreDataStack.shared.viewContext)
            
            if self.isFiltering {
                self.filteredTasks[indexPath.row] = task
            } else {
                self.tasks[indexPath.row] = task
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        navigationController?.pushViewController(taskDetailVC, animated: true)
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
        let createdAt = task.createdAt ?? Date()
        
        cell.configure(with: task.todo ?? "", isCompleted: task.completed, createdAt: createdAt, desc: task.desc ?? "")
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
            
            if let indexInTasks = self.tasks.firstIndex(where: { $0.objectID == task.objectID }) {
                self.tasks.remove(at: indexInTasks)
                CoreDataStack.shared.viewContext.delete(task)
                print("Task is deleted")
                CoreDataStack.shared.saveContext(context: CoreDataStack.shared.viewContext)
            }
            
            if self.isFiltering {
                self.filteredTasks.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateTaskCount()
        }
        // edit button in content menu
        cell.onEdit = {[weak self] in
            guard let self = self else {return}
            self.editTask(at: indexPath)
        }
        
        return cell
    }
    
    // pushing taskDetailVC
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
        guard let searchText = searchController.searchBar.text else {
            filteredTasks.removeAll()
            tableView.reloadData()
            return
        }
        if searchText.isEmpty {
            filteredTasks.removeAll()
        } else {
            filteredTasks = tasks.filter { $0.todo?.localizedCaseInsensitiveContains(searchText) ?? false }
        }
        tableView.reloadData()
    }
}

// Loading indicator set up
extension ViewController {
    private func setupLoadingIndicator() {
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        loadingLabel.text = "Загрузка..."
        loadingLabel.textAlignment = .center
        loadingLabel.textColor = .gray
        loadingLabel.frame = CGRect(x: 0, y: activityIndicator.frame.maxY + 8, width: view.bounds.width, height: 30)
        
        view.addSubview(activityIndicator)
        view.addSubview(loadingLabel)
    }
}
