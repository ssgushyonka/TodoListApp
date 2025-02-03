import Foundation
import UIKit
import CoreData

class TodoViewModel {
    var tasks: [TodoItem] = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func loadInitialDataIfNeeded(completion: @escaping () -> Void) {
        if UserDefaults.standard.bool(forKey: "DataLoaded") {
            fetchTodosFromCoreData { [weak self] todos in
                guard let self = self else { return }
                self.tasks = todos
                completion()
            }
        } else {
            fetchTodosFromAPI { [weak self] todoItems in
                guard let self = self, let todoItems = todoItems else {
                    print("API error")
                    completion()
                    return
                }
                self.saveTodoItemsToCoreData(todoItems)
                UserDefaults.standard.set(true, forKey: "DataLoaded")
                self.fetchTodosFromCoreData { todos in
                    self.tasks = todos
                    completion()
                }
            }
        }
    }
    
    func fetchTodosFromAPI(completion: @escaping ([TodoItemModel]?) -> Void) {
        let apiService = APIService()
        apiService.fetchTodoItems { todoItems in
            completion(todoItems)
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
    }

    func deleteItem(_ todo: TodoItem) {
        if let index = tasks.firstIndex(of: todo) {
            tasks.remove(at: index)
        }
        context.delete(todo)
        try? context.save()
    }

    func updateItem(_ todo: TodoItem, title: String, completed: Bool, createdAt: Date? = nil, desc: String? = nil) {
        todo.todo = title
        todo.completed = completed
        todo.createdAt = createdAt
        todo.desc = desc ?? ""
        try? context.save()
    }

    private func fetchTodoById(_ id: Int) -> TodoItem? {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        return try? context.fetch(request).first
    }
}
