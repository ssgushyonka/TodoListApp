import UIKit

class TaskTableViewCell: UITableViewCell {

    static let Identifier = "TaskTableViewCell"
    private let checkmarkButton = CheckmarkButton()
    
    private let taskLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
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
            taskLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    var toggleCompletion: (() -> Void)?
    
    @objc private func didTapCheckmark() {
        toggleCompletion?()
    }
        
    func configure(with text: String, isCompleted: Bool) {
        taskLabel.text = text
        checkmarkButton.setAppearance(isDone: isCompleted)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
