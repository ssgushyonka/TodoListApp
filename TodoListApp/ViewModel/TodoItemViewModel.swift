import Foundation
import CoreData

public final class TodoViewModel {
    // MARK: - Properties
    private(set) var tasks: [TodoItem] = []
    private(set) var filteredTasks: [TodoItem] = []
    private let apiService: APIService
    private let coreDataStack: CoreDataStack
    var onTaskUpdated: (() -> Void)?
    var searchText: String = ""

    var isFiltering: Bool {
        return !searchText.isEmpty
    }

    init(apiService: APIService, coreDataStack: CoreDataStack) {
        self.apiService = apiService
        self.coreDataStack = coreDataStack
    }

    func loadInitialDataIfNeeded(completion: @escaping () -> Void) {
        fetchTodosFromCoreData { [weak self] todos in
            guard let self = self else { return }
            if todos.isEmpty {
                print("Load from API")
                self.fetchTodosFromAPI { todoItems in
                    guard let todoItems = todoItems else {
                        print("Error loading data from API")
                        DispatchQueue.main.async {
                            completion()
                        }
                        return
                    }
                    self.tasks = todoItems.map { todo in
                        let task = TodoItem(context: self.coreDataStack.viewContext)
                        task.id = Int64(todo.id)
                        task.todo = todo.todo
                        task.completed = todo.completed
                        task.userId = Int64(todo.userId)
                        task.createdAt = Date()
                        return task
                    }
                    DispatchQueue.main.async {
                        self.onTaskUpdated?()
                    }
                    self.coreDataStack.saveTodoItemsToCoreData(todoItems)
                    UserDefaults.standard.set(true, forKey: "DataLoaded")

                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } else {
                print("Load from Core Data")
                self.tasks = todos
                DispatchQueue.main.async {
                    self.onTaskUpdated?()
                    completion()
                }
            }
        }
    }

    func fetchTodosFromAPI(completion: @escaping ([TodoItemModel]?) -> Void) {
        apiService.fetchTodoItems { todoItems in
            if let todoItems = todoItems {
                completion(todoItems)
                print("API data loaded: \(todoItems.count)")
            } else {
                print("Error loading data from API")
                completion(nil)
            }
        }
    }

    func fetchTodosFromCoreData(completion: @escaping ([TodoItem]) -> Void) {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        do {
            let todos = try coreDataStack.viewContext.fetch(request)
            completion(todos)
        } catch {
            print("Error fetching todos from Core Data: \(error)")
            completion([])
        }
    }

    func addItem(
        id: Int,
        todo: String,
        completed: Bool,
        userId: Int,
        createdAt: Date? = nil,
        desc: String? = nil
    ) {
        guard !todo.isEmpty else { return }
        if tasks.contains(where: { $0.id == Int64(id) }) { return }

        let todoItem = TodoItem(context: coreDataStack.viewContext)
        todoItem.id = Int64(id)
        todoItem.todo = todo
        todoItem.completed = completed
        todoItem.userId = Int64(userId)
        todoItem.createdAt = Date()
        todoItem.desc = desc ?? ""
        tasks.append(todoItem)

        do {
            try coreDataStack.viewContext.save()
            onTaskUpdated?()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    func deleteItem(_ todo: TodoItem) {
        coreDataStack.viewContext.delete(todo)
        do {
            try coreDataStack.viewContext.save()
            if let index = tasks.firstIndex(of: todo) {
                tasks.remove(at: index)
            }
            onTaskUpdated?()
        } catch {
            print("Error deleting item: \(error)")
        }
    }

    func updateItem(
        _ todo: TodoItem,
        title: String,
        completed: Bool,
        createdAt: Date? = nil,
        desc: String? = nil
    ) {
        todo.todo = title
        todo.completed = completed
        todo.createdAt = createdAt
        todo.desc = desc ?? ""
        do {
            try coreDataStack.viewContext.save()
            onTaskUpdated?()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    func filteredTasks(with searchText: String) {
        self.searchText = searchText
        if searchText.isEmpty {
            filteredTasks = tasks
        } else {
            filteredTasks = tasks.filter { $0.todo?.localizedCaseInsensitiveContains(searchText) ?? false }
        }
        onTaskUpdated?()
    }

    func task(at index: Int) -> TodoItem {
        return isFiltering ? filteredTasks[index] : tasks[index]
    }

    func taskCount() -> Int {
        return isFiltering ? filteredTasks.count : tasks.count
    }
}
