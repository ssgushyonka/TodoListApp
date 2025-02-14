import UIKit

class CheckmarkButton: UIButton {

    private var isDone: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(toggleState), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setAppearance(isDone: Bool) {
        self.isDone = isDone
        updateImage()
    }

    @objc
    private func toggleState() {
        isDone.toggle()
        updateImage()
    }

    private func updateImage() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 24)
        let doneImage = UIImage(
            systemName: "checkmark.circle",
            withConfiguration: configuration)?
            .withTintColor(ColorsExtension.yellowButton,
                               renderingMode: .alwaysOriginal)

        let undoneImage = UIImage(
            systemName: "circle",
            withConfiguration: configuration)?
            .withTintColor(
                ColorsExtension.checkMarkUndone,
                renderingMode: .alwaysOriginal
            )

        setImage(isDone ? doneImage : undoneImage, for: .normal)
    }
}
