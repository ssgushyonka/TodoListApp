//
//  TodoItem+CoreDataProperties.swift
//  TodoListApp
//
//  Created by Элина Борисова on 28.01.2025.
//
//

import Foundation
import CoreData


extension TodoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItem> {
        return NSFetchRequest<TodoItem>(entityName: "TodoItem")
    }

    @NSManaged public var id: Int64
    @NSManaged public var todo: String?
    @NSManaged public var completed: Bool
    @NSManaged public var userId: Int64

}

extension TodoItem : Identifiable {

}
