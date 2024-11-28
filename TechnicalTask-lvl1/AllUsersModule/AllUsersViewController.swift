//
//  AllUsersViewController.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/11/2024.
//

import UIKit
import RxSwift
import RxCocoa

private enum Constants {
    static let headerHeight: CGFloat = 40.0
    static let estimatedRowHeight: CGFloat = 60.0
    static let headerFont: UIFont = .boldSystemFont(ofSize: 16)
    static let buttonFont: UIFont = .boldSystemFont(ofSize: 18)
    static let headerTitle = "Full list of users"
    static let buttonTitle = "Add User"
    static let commonInset: CGFloat = 8.0
    static let buttonHeight: CGFloat = 50.0
    static let cornerRadius: CGFloat = 8.0
}

final class AllUsersViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: AllUsersViewModelProtocol
    private let disposeBag = DisposeBag()
    // MARK: - GUI Properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        return tableView
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Constants.buttonTitle, for: .normal)
        button.titleLabel?.font = Constants.buttonFont
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.cornerRadius
        return button
    }()
    
    // MARK: Life cycle
    init(viewModel: AllUsersViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "All users"
        setupUI()
        setupTableView()
        bindViewModel()
        viewModel.fetchUsers()
    }
}

// MARK: UITableViewDelegate
extension AllUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGray
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = Constants.headerTitle
        titleLabel.font = Constants.headerFont
        titleLabel.textColor = .black
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Constants.commonInset * 2),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Constants.commonInset * 2),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: Constants.commonInset),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Constants.commonInset)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { Constants.headerHeight }
}

// MARK: Private methods
private extension AllUsersViewController {
    func setupUI() {
        view.backgroundColor = .white
        
        view.addSubviews([
            tableView,
            addButton
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -Constants.commonInset),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.commonInset * 2),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.commonInset * 2),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.commonInset * 2),
            addButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    func setupTableView() {
        tableView.delegate = self
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self else { return }
                self.confirmDeletion(at: indexPath)
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        viewModel.users
            .bind(to: tableView.rx.items(cellIdentifier: UserTableViewCell.reuseIdentifier,
                                         cellType: UserTableViewCell.self)) { index, user, cell in
                cell.configure(with: user)
            }
                                         .disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                showError(error)
            })
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let viewModel = AddUserViewModel(userRepository: viewModel.getUserRepository())
                let userViewController = AddUserViewController(viewModel: viewModel)
                
                viewModel.success
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] in
                        guard let self else { return }
                        self.viewModel.fetchUsers()
                    })
                    .disposed(by: self.disposeBag)
                
                navigationController?.pushViewController(userViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func confirmDeletion(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete User",
            message: "Are you sure you want to delete this user?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            deleteUser(at: indexPath)
        }))
        present(alert, animated: true)
    }
    
    func deleteUser(at indexPath: IndexPath) {
        viewModel.users
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] users in
                guard let self, indexPath.row < users.count else { return }
                let user = users[indexPath.row]
                
                self.viewModel.delete(user: user)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onCompleted: {
                        UIView.transition(with: self.tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                            self.viewModel.fetchUsers()
                        })
                    }, onError: { error in
                        self.showError(error)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
