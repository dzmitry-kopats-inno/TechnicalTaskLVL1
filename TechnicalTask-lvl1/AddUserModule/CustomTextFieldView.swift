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
    private let label = UILabel()
    private let textField = UITextField()
    private let type: CustomTextFieldType

    init(labelText: String, type: CustomTextFieldType = .text) {
        self.type = type
        super.init(frame: .zero)
        setupUI(labelText: labelText)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(labelText: String) {
        label.text = labelText
        label.font = .systemFont(ofSize: 16, weight: .medium)

        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8.0
        textField.font = .systemFont(ofSize: 14)
        textField.heightAnchor.constraint(equalToConstant: 40.0).isActive = true

        // Настройка клавиатуры для email
        if type == .email {
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
        }

        let stackView = UIStackView(arrangedSubviews: [label, textField])
        stackView.axis = .vertical
        stackView.spacing = Constants.commonSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    func setBorderColor(_ color: UIColor) {
        textField.layer.borderColor = color.cgColor
    }
}
