import Foundation
import UIKit
import CoreData

class TodoViewModel {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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

    func addItem(id: Int, todo: String, completed: Bool, userId: Int) {
        let todoItem = TodoItem(context: context)
        todoItem.id = Int64(id)
        todoItem.todo = todo
        todoItem.completed = completed
        todoItem.userId = Int64(userId)
        try? context.save()
    }

    func deleteItem(_ todo: TodoItem) {
        context.delete(todo)
        try? context.save()
    }

    func updateItem(_ todo: TodoItem, title: String, completed: Bool) {
        todo.todo = title
        todo.completed = completed
        try? context.save()
    }

    private func fetchTodoById(_ id: Int) -> TodoItem? {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        return try? context.fetch(request).first
    }
}
