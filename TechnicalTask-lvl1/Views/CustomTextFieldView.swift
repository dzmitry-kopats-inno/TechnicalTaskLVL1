//
//  CustomTextFieldView.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 27/11/2024.
//

import UIKit
import RxSwift

private enum Constants {
    static let commonSpacing: CGFloat = 8.0
}

enum CustomTextFieldType {
    case text
    case email
    case requiredText
}

final class CustomTextFieldView: UIView {
    // MARK: - Properties
    private let type: CustomTextFieldType
    
    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    // MARK: - GUI Properties
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8.0
        textField.font = .systemFont(ofSize: 14)
        textField.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        return textField
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [label, textField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.commonSpacing
        return stackView
    }()

    // MARK: - Life cycle
    init(labelText: String, type: CustomTextFieldType = .text) {
        self.type = type
        super.init(frame: .zero)
        setupUI(labelText: labelText)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func setBorderColor(_ color: UIColor) {
        textField.layer.borderColor = color.cgColor
    }
}

private extension CustomTextFieldView {
    func setupUI(labelText: String) {
        label.text = labelText

        if type == .email {
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
        }

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
