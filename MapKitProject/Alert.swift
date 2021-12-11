//
//  Alert.swift
//  MapKit
//
//  Created by vlad on 8/17/21.
//  Copyright © 2021 Vlad Lazoryk. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func alertAddPlace(name: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        
        let alertController = UIAlertController(title: name, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { (action) in
            
            let tftext = alertController.textFields?.first
            guard let text = tftext?.text else { return }
            completionHandler(text)
        }
        
        alertController.addTextField { (tf) in
            tf.placeholder = placeholder
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { (_) in}
        
        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func alertError(name: String, message: String) {
        
        let alertController = UIAlertController(title: name, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(alertOk)

        present(alertController, animated: true, completion: nil)
    }
}
