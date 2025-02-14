import Foundation
import CoreData

struct TodoItemModel: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
    let createdAt: Date?
    let desc: String?
}

struct TodoItemModelResponse: Codable {
    let todos: [TodoItemModel]
}

extension TodoItemModel {
    func convertToCoreData(context: NSManagedObjectContext) -> TodoItem {
        let todoItem = TodoItem(context: context)
        todoItem.id = Int64(self.id)
        todoItem.todo = self.todo
        todoItem.completed = self.completed
        todoItem.userId = Int64(self.userId)
        todoItem.createdAt = self.createdAt ?? Date()
        todoItem.desc = self.desc ?? ""

        return todoItem
    }

    static func fromCoreDataModel(_ coreDataModel: TodoItem) -> TodoItemModel {
        return TodoItemModel(
            id: Int(coreDataModel.id),
            todo: coreDataModel.todo ?? "",
            completed: coreDataModel.completed,
            userId: Int(coreDataModel.userId),
            createdAt: coreDataModel.createdAt ?? Date(),
            desc: coreDataModel.desc ?? ""
        )
    }
}
