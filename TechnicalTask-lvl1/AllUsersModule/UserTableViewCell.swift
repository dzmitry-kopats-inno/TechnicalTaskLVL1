//
//  UserTableViewCell.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/11/2024.
//

import UIKit

private enum Constants {
    static let userNameFont: UIFont = .boldSystemFont(ofSize: 18)
    static let userEmailFont: UIFont = .systemFont(ofSize: 14)
    static let addressFont: UIFont = .boldSystemFont(ofSize: 14)
    static let cityStreetFont: UIFont = .systemFont(ofSize: 14)
    static let boldFont: UIFont = .boldSystemFont(ofSize: 18)
    static let commonInset: CGFloat = 8.0
}

final class UserTableViewCell: UITableViewCell, Reusable {
    // MARK: - GUI Properties
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Constants.userNameFont
        label.text = "User Name"
        return label
    }()
    
    private let userEmailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.userEmailFont
        label.text = "User email"
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.addressFont
        label.text = "Address:"
        return label
    }()
    
    private let cityStreetLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Constants.cityStreetFont
        label.text = "City name,\nstreet name"
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        setupUI()
    }
    
    // MARK: - Methods
    func configure(with user: UserModel) {
        userNameLabel.text = user.name
        userEmailLabel.text = user.email
        
        var addressText = ""
        if let city = user.address?.city, !city.isEmpty {
            addressText += city
        }
        
        if let street = user.address?.street, !street.isEmpty {
            if !addressText.isEmpty {
                addressText += ",\n"
            }
            addressText += street
        }
        
        cityStreetLabel.text = addressText.isEmpty ? "N/A" : addressText
    }
}

// MARK: - Private methods
private extension UserTableViewCell {
    func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubviews([
            userNameLabel,
            userEmailLabel,
            addressLabel,
            cityStreetLabel
        ])
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.commonInset),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.commonInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.commonInset),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.commonInset),
            
            userNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.commonInset),
            userNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.commonInset),
            
            userEmailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            userEmailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.commonInset),
            userEmailLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -Constants.commonInset),
            
            addressLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.commonInset),
            addressLabel.leadingAnchor.constraint(greaterThanOrEqualTo: userNameLabel.trailingAnchor, constant: Constants.commonInset * 2),
            addressLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: contentView.bounds.width * 0.1),
            addressLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.commonInset),
            
            cityStreetLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4),
            cityStreetLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
            cityStreetLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.commonInset),
            cityStreetLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -Constants.commonInset)
        ])
    }
}
