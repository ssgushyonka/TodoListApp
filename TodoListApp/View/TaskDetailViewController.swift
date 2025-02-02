import Foundation
import UIKit

class TaskDetailViewController: UIViewController {
    
    var taskText: String?
    var task: TodoItem?
    var onSave: ((String) -> Void)?

    private let taskTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 34)
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.translatesAutoresizingMaskIntoConstraints = false

        return textView
    }()
    
    private let descTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        taskTextView.text = taskText
        if let createdAt = task?.createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd"
            dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            dateLabel.text = ""
        }
        descTextView.text = task?.desc
        
        taskTextView.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveButtonTapped))
        taskTextView.sizeToFit()
        setupViews()
        setupConstraints()
    }

    //MARK: - set up views and constraints
    
    private func setupViews() {
        view.addSubview(taskTextView)
        view.addSubview(descTextView)
        view.addSubview(dateLabel)
    }
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            taskTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            taskTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            taskTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            taskTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            dateLabel.topAnchor.constraint(equalTo: taskTextView.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    @objc private func saveButtonTapped() {
        guard let updatedText = taskTextView.text, !updatedText.isEmpty else { return }
        guard let updatedDesc = descTextView.text else { return }
        if let task = task {
            task.todo = updatedText
            task.desc = updatedDesc
            CoreDataStack.shared.saveContext(context: CoreDataStack.shared.viewContext)
        }
        onSave?(updatedText)
        navigationController?.popViewController(animated: true)
    }
}
