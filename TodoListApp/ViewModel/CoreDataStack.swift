import CoreData
import Foundation

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoListApp")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
        }
        return container
    }()
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    var backgroundContext: NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    func saveContext(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    func taskExists(id: Int64, in context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Task existance error: \(error)")
            return false
        }
    }
    
    func saveTodoItemsToCoreData(_ todoItems: [TodoItemModel]) {
        let context = CoreDataStack.shared.backgroundContext
        context.perform {
            for todoItem in todoItems {
                if !self.taskExists(id: Int64(todoItem.id), in: context) {
                    let newItem = TodoItem(context: context)
                    newItem.id = Int64(todoItem.id)
                    newItem.todo = todoItem.todo
                    newItem.completed = todoItem.completed
                    newItem.userId = Int64(todoItem.userId)
                }
                if context.hasChanges {
                    CoreDataStack.shared.saveContext(context: context)
                }
            }
        }
    }
    func fetchTodosFromCoreData(completion: @escaping ([TodoItem]) -> Void) {
        let context = CoreDataStack.shared.viewContext
        context.perform {
            let fetchRequest: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            
            do {
                let todos = try context.fetch(fetchRequest)
                DispatchQueue.main.async {
                    completion(todos)
                }
            } catch {
                print("Data error: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
}
