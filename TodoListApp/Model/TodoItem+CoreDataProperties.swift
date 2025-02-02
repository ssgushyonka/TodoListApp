

import Foundation
import CoreData


extension TodoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItem> {
        return NSFetchRequest<TodoItem>(entityName: "TodoItem")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var id: Int64
    @NSManaged public var todo: String?
    @NSManaged public var userId: Int64

}

extension TodoItem : Identifiable {

}
