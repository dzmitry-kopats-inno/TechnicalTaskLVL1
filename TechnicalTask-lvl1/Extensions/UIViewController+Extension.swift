//
//  UIViewController+Extension.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 09/12/2024.
//

import UIKit

extension UIViewController {
    // TODO: - Remove this method after update
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
