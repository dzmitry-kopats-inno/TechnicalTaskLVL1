//
//  TableViewHeaderView.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 17/12/2024.
//

import UIKit

private enum Constants {
    static let headerFont: UIFont = .boldSystemFont(ofSize: 16)
    static let commonInset: CGFloat = 8.0
}

class TableViewHeaderView: UITableViewHeaderFooterView, Reusable {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.headerFont
        label.textColor = .black
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with title: String) {
        titleLabel.text = title
    }
}

private extension TableViewHeaderView {
    func setupView() {
        backgroundColor = .systemGray
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.commonInset * 2),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.commonInset * 2),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.commonInset),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.commonInset)
        ])
    }
}
