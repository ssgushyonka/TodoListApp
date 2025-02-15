import Foundation
import CoreData
import UIKit

final class ViewController: UIViewController {

    // MARK: - Properties
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    private let searchController = UISearchController(searchResultsController: nil)
    private var viewModel: TodoViewModel

    // MARK: - UI Components
    var taskCountLabel: UILabel?
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.Identifier)
        return tableView
    }()

    init(viewModel: TodoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupBindings()
        activityIndicator.startAnimating()
        loadingLabel.isHidden = false
        viewModel.loadInitialDataIfNeeded { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.loadingLabel.isHidden = true
            self?.tableView.reloadData()
        }
    }

    // MARK: - Setup UI
    private func setupBindings() {
        viewModel.onTaskUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateTaskCount()
            }
        }
    }

    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = ColorsExtension.grayToolBar
        title = "Задачи"

        let backButton = UIBarButtonItem()
        backButton.title = "Назад"
        navigationItem.backBarButtonItem = backButton
        navigationController?.isToolbarHidden = false
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
        setupLoadingIndicator()
    }

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

    private func setupViews() {
        view.addSubview(tableView)
        setupNavigationBarBottomItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupNavigationBarBottomItems() {
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
        editButton.tintColor = ColorsExtension.yellowButton
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [flexibleSpace, UIBarButtonItem(customView: taskCountLabel), flexibleSpace, editButton]
        if let toolbar = navigationController?.toolbar {
            let appearance = UIToolbarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = ColorsExtension.toolBarAppearance
            toolbar.standardAppearance = appearance
            toolbar.scrollEdgeAppearance = appearance
        }
        navigationController?.isToolbarHidden = false
    }

    // MARK: - Action funcs
    @objc
    private func editButtonTapped() {
        let alertController = UIAlertController(
            title: "Новая задача",
            message: "Введите задачу",
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            textField.placeholder = "Задача"
        }

        let addAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let textField = alertController.textFields?.first,
               let todoText = textField.text,
               !todoText.isEmpty {
                self.viewModel.addItem(
                    id: Int.random(in: 0..<1000),
                    todo: todoText,
                    completed: false, userId: 1
                )
            }
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Private funcs
    private func updateTaskCount() {
        guard let taskCountLabel = self.taskCountLabel else { return }
            taskCountLabel.text = "\(viewModel.taskCount()) Задач"
            taskCountLabel.sizeToFit()
    }

    private func editTask(at indexPath: IndexPath) {
        let task = viewModel.task(at: indexPath.row)
        let taskDetailVC = TaskDetailViewController()
        taskDetailVC.taskText = task.todo
        taskDetailVC.task = task
        taskDetailVC.descText = task.desc

        taskDetailVC.onSave = { [weak self] updatedText, updatedDesc in
            guard let self = self else { return }
            self.viewModel.updateItem(
                task,
                title: updatedText,
                completed: task.completed,
                createdAt: task.createdAt,
                desc: updatedDesc
            )
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        navigationController?.pushViewController(taskDetailVC, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.taskCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskTableViewCell.Identifier,
            for: indexPath
        ) as? TaskTableViewCell else {
            return UITableViewCell()
        }

        let task = viewModel.task(at: indexPath.row)
        let createdAt = task.createdAt ?? Date()

        cell.configure(
            with: task.todo ?? "",
            isCompleted: task.completed,
            createdAt: createdAt,
            desc: task.desc ?? ""
        )
        cell.toggleCompletion = { [weak self] in
            guard let self = self else { return }
            self.viewModel.updateItem(
                task, title: task.todo ?? "",
                completed: !task.completed,
                createdAt: createdAt,
                desc: task.desc ?? ""
            )
        }

        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            let task = self.viewModel.task(at: indexPath.row)
            self.viewModel.deleteItem(task)
            self.tableView.reloadData()
        }

        cell.onEdit = { [weak self] in
            guard let self = self else { return }
            self.editTask(at: indexPath)
            self.tableView.reloadData()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        editTask(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.filteredTasks(with: searchText)
    }
}
