import Foundation
import UIKit

class TaskDetailViewController: UIViewController {
    
    var taskText: String?
    var task: TodoItem?

    private let taskTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 34)
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()

    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    var onSave: ((String) -> Void)?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        setupConstraints()
        taskTextView.text = taskText
        taskTextView.isEditable = true
        taskTextView.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveButtonTapped))
    }
    
    
    //MARK: - set up views and constraints
    
    private func setupViews() {
        view.addSubview(taskTextView)
    }
    private func setupConstraints() {

        NSLayoutConstraint.activate([
            taskTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            taskTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            taskTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            taskTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    @objc private func saveButtonTapped() {
        guard let updatedText = taskTextView.text, !updatedText.isEmpty else { return }
        if let task = task {
            task.todo = updatedText
            CoreDataStack.shared.saveContext(context: CoreDataStack.shared.viewContext)
        }
        onSave?(updatedText)
        taskTextView.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
}
