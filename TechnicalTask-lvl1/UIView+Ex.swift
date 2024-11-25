//
//  UIView+Ex.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/11/2024.
//

import UIKit

extension UIView {
    /**
     Extends basic UIView functionality to add multiple subviews
     */
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
}
