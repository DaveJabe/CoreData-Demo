//
//  Extensions.swift
//  CoreDataDemo
//
//  Created by David Jabech on 8/1/22.
//

import UIKit
import CoreData

extension UIViewController {
    
    func presentSimpleAlert(title: String, message: String? = nil, style: UIAlertController.Style = .alert, actionTitles: [String]? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: style)
        if let actionTitles = actionTitles {
            for action in actionTitles {
                alert.addAction(UIAlertAction(title: action,
                                              style: .default,
                                              handler: nil))
            }
        }
        else {
            alert.addAction(UIAlertAction(title: "Ok",
                                          style: .default,
                                          handler: nil))
        }
        present(alert, animated: true)
    }
}

extension UIAlertController {
    
    func addCancel() {
        let cancel = UIAlertAction(title: "Cancel",
                                   style: .cancel,
                                   handler: nil)
        addAction(cancel)
    }
    
    func addActions(_ actions: UIAlertAction...) {
        for action in actions {
            addAction(action)
        }
    }
    
    func addTextField(placeholder: String? = nil, text: String? = nil) {
        addTextField { textField in
            textField.placeholder = placeholder
            textField.text = text
        }
    }

    func addTextFieldWithPickerView(delegateDataSource: (UIPickerViewDelegate & UIPickerViewDataSource),
                                    placeholder: String? = nil,
                                    text: String? = nil,
                                    completion: @escaping (UITextField) -> Void) {
        
        addTextField { textField in
            textField.placeholder = placeholder
            textField.text = text
            textField.tintColor = .clear
            let pickerView = UIPickerView()
            pickerView.delegate = delegateDataSource
            pickerView.dataSource = delegateDataSource
            textField.inputView = pickerView
            completion(textField)
        }
    }
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

extension JSONDecoder {
    convenience init(context: NSManagedObjectContext) {
        self.init()
        self.userInfo[.context] = context
    }
}
