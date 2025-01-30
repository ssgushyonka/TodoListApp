import Foundation
import UIKit

class TaskDetailViewController: UIViewController {
    
    var taskText: String?
    
    private let taskLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        setupConstraints()
        taskLabel.text = taskText
    }
    
    private func setupViews() {
        view.addSubview(taskLabel)
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            taskLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taskLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            taskLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            taskLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
