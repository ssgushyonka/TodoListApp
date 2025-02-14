import Foundation
import CoreData

final class APIService {
    func fetchTodoItems(completion: @escaping ([TodoItemModel]?) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Data load error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(TodoItemModelResponse.self, from: data)
                completion(response.todos)
            } catch {
                print("JSON decode error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
