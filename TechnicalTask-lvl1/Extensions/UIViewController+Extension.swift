//
//  UIViewController+Extension.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 09/12/2024.
//

import UIKit

extension UIViewController {
    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
