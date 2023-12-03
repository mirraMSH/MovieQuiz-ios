//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Мария Шагина on 26.11.2023.
//

import UIKit

final class AlertPresenter {
    
    private let alert: AlertModel
    weak var controller: UIViewController?
    
    init(appearingAlert alert: AlertModel) {
        self.alert = alert
    }
    
    func showAlert() {
        
        let alertController = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert)
        alertController.view.accessibilityIdentifier = "Game results"
        
        alertController.addAction(UIAlertAction(
                    title: alert.buttonText,
                    style: .cancel,
                    handler: {_ in
                        self.alert.completion()
                    }))
                controller?.present(alertController, animated: true, completion: nil)
    }
}
