import UIKit

final class TaskTableViewCell: UITableViewCell {

    // MARK: - Properties
    static let Identifier = "TaskTableViewCell"
    private let checkmarkButton = CheckmarkButton()
    private var isCompleted: Bool = false
    var toggleCompletion: (() -> Void)?
    var onEdit: (() -> Void)?
    var onShare: (() -> Void)?
    var onDelete: (() -> Void)?
    var isContextMenuEnabled: Bool = false

    // MARK: - UI Components
    private let taskLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    //MARK: - Overrige funcs
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        isContextMenuEnabled = true

        let interaction = UIContextMenuInteraction(delegate: self)
        contentView.addInteraction(interaction)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup views and constraints
    private func setupViews() {
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkmarkButton)
        contentView.addSubview(taskLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(dateLabel)
        checkmarkButton.addTarget(self, action: #selector(didTapCheckmark), for: .touchUpInside)
    }

    private func setupConstraints() {
        contentView.preservesSuperviewLayoutMargins = true
        NSLayoutConstraint.activate([
            checkmarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 24),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 24),

            taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            taskLabel.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 16),
            taskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descLabel.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: taskLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: taskLabel.trailingAnchor),

            dateLabel.topAnchor.constraint(
                equalTo: descLabel.isHidden ? taskLabel.bottomAnchor : descLabel.bottomAnchor,
                constant: 4
            ),
            dateLabel.leadingAnchor.constraint(equalTo: taskLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: taskLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        taskLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        dateLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    func configure(with text: String, isCompleted: Bool, createdAt: Date, desc: String) {
        self.isCompleted = isCompleted
        let attributes: [NSAttributedString.Key: Any] = isCompleted ? [
            .strikethroughStyle: NSUnderlineStyle.thick.rawValue,
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 16)
        ] : [
            .font: UIFont.systemFont(ofSize: 16)
        ]
        taskLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        dateLabel.text = "\(dateFormatter.string(from: createdAt))"
        descLabel.text = desc
        descLabel.isHidden = desc.isEmpty
        checkmarkButton.setAppearance(isDone: isCompleted)
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - Action funcs
    @objc
    private func didTapCheckmark() {
        toggleCompletion?()
    }
}

// Task context menu
extension TaskTableViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            let previewVC = TaskDetailViewController()
            previewVC.taskText = self.taskLabel.text
            previewVC.preferredContentSize = CGSize(width: 300, height: 300)
            return previewVC
        }, actionProvider: { _ in

            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive,
                handler: { _ in
                self.onDelete?()
            })
            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "square.and.pencil"),
                handler: { _ in
                self.onEdit?()
            })
            let shareAction = UIAction(
                title: "Поделиться",
                image: UIImage(systemName: "square.and.arrow.up"),
                handler: { _ in
                self.onShare?()
            })
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        })
    }
}
