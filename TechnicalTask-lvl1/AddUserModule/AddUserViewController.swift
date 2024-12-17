//
//  AddUserViewController.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 27/11/2024.
//

import UIKit
import RxSwift

private enum Constants {
    static let commonSpacing: CGFloat = 8.0
    static let commonInset: CGFloat = 16.0
    static let cornerRadius: CGFloat = 8.0
    static let saveButtonHeight: CGFloat = 50.0
    static let screenTitle = "Add New User"
    static let saveButtonTitle = "Save"
    static let instructionLabelText = "Provide all info to save user:"
}

final class AddUserViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: AddUserViewModel
    private let disposeBag = DisposeBag()

    // MARK: - GUI Properties
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.instructionLabelText
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let nameField = CustomTextFieldView(labelText: "User Name*:", type: .requiredText)
    private let emailField = CustomTextFieldView(labelText: "User Email*:", type: .email)
    private let cityField = CustomTextFieldView(labelText: "City Name:", type: .text)
    private let streetField = CustomTextFieldView(labelText: "Street Name:", type: .text)
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            instructionLabel,
            nameField,
            emailField,
            cityField,
            streetField
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.commonSpacing * 2
        return stackView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Constants.saveButtonTitle, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.cornerRadius
        button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        return button
    }()

    // MARK: - Life Cycle
    init(viewModel: AddUserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupDismissKeyboardGesture()
    }
}

private extension AddUserViewController {
    func setupUI() {
        view.backgroundColor = .white
        title = Constants.screenTitle

        view.addSubview(stackView)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.commonInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.commonInset),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.commonInset),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.commonInset),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.commonInset),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.commonInset),
            saveButton.heightAnchor.constraint(equalToConstant: Constants.saveButtonHeight)
        ])
    }

    func bindViewModel() {
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                nameField.validate()
                emailField.validate()
                
                self.viewModel.addUser(name: nameField.text,
                                       email: emailField.text,
                                       city: cityField.text,
                                       street: streetField.text)
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                guard let self else { return }
                showError(errorMessage)
            })
            .disposed(by: disposeBag)
        
        viewModel.success
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
