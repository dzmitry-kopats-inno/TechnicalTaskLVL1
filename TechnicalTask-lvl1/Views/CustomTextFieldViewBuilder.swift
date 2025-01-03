//
//  CustomTextFieldViewBuilder.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 27/12/2024.
//

import UIKit

final class CustomTextFieldViewBuilder {
    private var labelText: String = ""
    private var type: CustomTextFieldType = .text
    private var keyboardType: UIKeyboardType = .default
    private var autocapitalizationType: UITextAutocapitalizationType = .none
    private var borderColor: UIColor = .black
    
    func setLabelText(_ text: String) -> CustomTextFieldViewBuilder {
        labelText = text
        return self
    }
    
    func setType(_ type: CustomTextFieldType) -> CustomTextFieldViewBuilder {
        self.type = type
        switch type {
        case .email:
            keyboardType = .emailAddress
            autocapitalizationType = .none
        case .requiredText, .text:
            keyboardType = .default
        }
        
        return self
    }
    
    func setBorderColor(_ color: UIColor) -> CustomTextFieldViewBuilder {
        borderColor = color
        return self
    }
    
    func build() -> CustomTextFieldView {
        CustomTextFieldView(
            labelText: labelText,
            type: type,
            keyboardType: keyboardType,
            autocapitalizationType: autocapitalizationType,
            borderColor: borderColor
        )
    }
    
}
