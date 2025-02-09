import Foundation
import UIKit
import CoreData

class TodoViewModel {
    
    private(set) var tasks: [TodoItem] = []
    private(set) var filteredTasks: [TodoItem] = []
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var onTaskUpdated: (() -> Void)?
    var searchText: String = ""
    
    var isFiltering: Bool {
        return !searchText.isEmpty
    }
    func loadInitialDataIfNeeded(completion: @escaping () -> Void) {
        fetchTodosFromCoreData { [weak self] todos in
            guard let self = self else { return }
            
            if todos.isEmpty {
                print("load from api")
                self.fetchTodosFromAPI { todoItems in
                    guard let todoItems = todoItems else {
                        print("error")
                        DispatchQueue.main.async {
                            completion()
                        }
                        return
                    }
                    self.tasks = todoItems.map { todo in
                        let task = TodoItem(context: self.context)
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
                    self.saveTodoItemsToCoreData(todoItems)
                    UserDefaults.standard.set(true, forKey: "DataLoaded")
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } else {
                print("load from core data")
                self.tasks = todos
                DispatchQueue.main.async {
                    self.onTaskUpdated?()
                    completion()
                }
            }
        }
    }
    
    func fetchTodosFromAPI(completion: @escaping ([TodoItemModel]?) -> Void) {
        let apiService = APIService()
        apiService.fetchTodoItems { todoItems in
            if let todoItems = todoItems {
                completion(todoItems)
                print("данные апи: \(todoItems.count)")
            } else {
                print("Ошибка загрузки данных")
                completion(nil)
            }
        }
    }
    
    func saveTodoItemsToCoreData(_ todos: [TodoItemModel]) {
        CoreDataStack.shared.saveTodoItemsToCoreData(todos)
    }

    func fetchTodosFromCoreData(completion: @escaping ([TodoItem]) -> Void) {
        
        CoreDataStack.shared.fetchTodosFromCoreData { todos in
            completion(todos)
        }
    }

    func addItem(id: Int, todo: String, completed: Bool, userId: Int, createdAt: Date? = nil, desc: String? = nil) {
        guard !todo.isEmpty else {
            return
        }
        if tasks.contains(where: { $0.id == Int64(id) }) {
            return
        }
        let todoItem = TodoItem(context: context)
        todoItem.id = Int64(id)
        todoItem.todo = todo
        todoItem.completed = completed
        todoItem.userId = Int64(userId)
        todoItem.createdAt = Date()
        todoItem.desc = String()
        tasks.append(todoItem)
        try? context.save()
        onTaskUpdated?()
    }

    func deleteItem(_ todo: TodoItem) {
        let objectID = todo.objectID
        context.perform { [weak self] in
            guard let self = self else { return }
            if let taskInContext = try? self.context.existingObject(with: objectID) {
                self.context.delete(taskInContext)
                try? self.context.save()
                
                if let index = self.tasks.firstIndex(where: { $0.objectID == objectID }) {
                    self.tasks.remove(at: index)
                }
                self.onTaskUpdated?()
            }
        }
    }

    func updateItem(_ todo: TodoItem, title: String, completed: Bool, createdAt: Date? = nil, desc: String? = nil) {
        todo.todo = title
        todo.completed = completed
        todo.createdAt = createdAt
        todo.desc = desc ?? ""
        do {
            try context.save()
            onTaskUpdated?()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }

    private func fetchTodoById(_ id: Int) -> TodoItem? {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        let todoItem = try? context.fetch(request).first
        onTaskUpdated?()
        return todoItem
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
