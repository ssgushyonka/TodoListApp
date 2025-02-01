import UIKit

class TaskTableViewCell: UITableViewCell {
    
    static let Identifier = "TaskTableViewCell"
    private let checkmarkButton = CheckmarkButton()
    private var isCompleted: Bool = false
    var toggleCompletion: (() -> Void)?
    var onDelete: (() -> Void)?
    var isContextMenuEnabled: Bool = false
    
    private let taskLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        isContextMenuEnabled = true
        let interaction = UIContextMenuInteraction(delegate: self)
        contentView.addInteraction(interaction)
    }
    
    private func setupViews() {
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkmarkButton)
        contentView.addSubview(taskLabel)
        checkmarkButton.addTarget(self, action: #selector(didTapCheckmark), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            checkmarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 24),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 24),
            
            taskLabel.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 16),
            taskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            taskLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
    
    @objc private func didTapCheckmark() {
        toggleCompletion?()
    }
    func configure(with text: String, isCompleted: Bool) {
        self.isCompleted = isCompleted
        let attributes: [NSAttributedString.Key: Any] = isCompleted ? [
            .strikethroughStyle: NSUnderlineStyle.thick.rawValue,
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 16)
        ] : [
            .font: UIFont.systemFont(ofSize: 16)
        ]
        taskLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        checkmarkButton.setAppearance(isDone: isCompleted)
        setNeedsLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// for task preview
extension TaskTableViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            let previewVC = TaskDetailViewController()
            previewVC.taskText = self.taskLabel.text
            previewVC.preferredContentSize = CGSize(width: 300, height: 300)
            return previewVC
        }, actionProvider: { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), handler: { _ in
                self.onDelete?()
            })
            return UIMenu(title: "", children: [deleteAction])
        })
    }
}
