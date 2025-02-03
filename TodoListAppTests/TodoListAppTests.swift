//
//  TodoListAppTests.swift
//  TodoListAppTests
//
//  Created by Элина Борисова on 28.01.2025.
//

import XCTest
import CoreData
@testable import TodoListApp

final class TodoListAppTests: XCTestCase {
    
    var viewModel: TodoViewModel!
    var context: NSManagedObjectContext!
    override func setUpWithError() throws {
        try super.setUpWithError()
        let persistentContainer = NSPersistentContainer(name: "TodoListApp")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        context = persistentContainer.viewContext
        viewModel = TodoViewModel()
    }

    override func tearDownWithError() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TodoItem.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        viewModel = nil
        context = nil
        try super.tearDownWithError()
    }

    func testTodoItemInitialization() {
        let todo = TodoItemModel(id: 1, todo: "Покататься на коньках", completed: false, userId: 1, createdAt: Date(), desc: "")
        XCTAssertEqual(todo.id, 1)
        XCTAssertEqual(todo.todo, "Покататься на коньках")
        XCTAssertFalse(todo.completed)
        XCTAssertEqual(todo.userId, 1, "User ID should be 1")
    }

    func testAddTaskToArray() {
        let initialCount = viewModel.tasks.count
        viewModel.addItem(id: 1, todo: "Написать книгу", completed: false, userId: 1)
        XCTAssertEqual(viewModel.tasks.count, initialCount + 1)
        XCTAssertEqual(viewModel.tasks.last?.todo, "Написать книгу")
    }
    func testDeleteTaskFromArray() {
        viewModel.addItem(id: 1, todo: "Написать книгу", completed: false, userId: 1)
        if let task = viewModel.tasks.first {
            viewModel.deleteItem(task)
            XCTAssertEqual(viewModel.tasks.count, 0)
        } else {
            XCTFail("Task array is empty")
        }
    }
    func testAddEmptyTask() {
        let initialCount = viewModel.tasks.count
        viewModel.addItem(id: 1, todo: "", completed: false, userId: 1)
        XCTAssertEqual(viewModel.tasks.count, initialCount)
    }

    func testUniqueTaskID() {
        viewModel.addItem(id: 1, todo: "Покататься на коньках", completed: false, userId: 1)
        viewModel.addItem(id: 1, todo: "Написать книгу", completed: false, userId: 1)
        XCTAssertEqual(viewModel.tasks.count, 1)
    }

    func testEditTask() {
        viewModel.addItem(id: 1, todo: "Написать книгу", completed: false, userId: 1)
        let task = viewModel.tasks.first!
        task.todo = "Купить хлеб"
        XCTAssertEqual(task.todo, "Купить хлеб")
    }
}
