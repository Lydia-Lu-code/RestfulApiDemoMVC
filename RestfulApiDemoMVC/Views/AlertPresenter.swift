//
//  AlertPresenter.swift
//  RestfulApiDemoMVC
//
//  Created by Lydia Lu on 2024/11/5.
//

import Foundation
import UIKit

// MARK: - AlertPresenter.swift (View)
protocol AlertPresenterProtocol {
    func showError(_ error: Error, on viewController: UIViewController)
    func showSuccess(message: String, on viewController: UIViewController)
    func showFavoritePrompt(on viewController: UIViewController, completion: @escaping (String?) -> Void)
}

class AlertPresenter: AlertPresenterProtocol {
    static let shared = AlertPresenter()
    
    func showError(_ error: Error, on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "錯誤",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        viewController.present(alert, animated: true)
    }
    
    func showSuccess(message: String, on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "成功",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        viewController.present(alert, animated: true)
    }
    
    func showFavoritePrompt(on viewController: UIViewController, completion: @escaping (String?) -> Void) {
        let alert = UIAlertController(
            title: "添加到收藏",
            message: "要添加筆記嗎？",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "筆記（選填）"
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
            completion(nil)
        })
        
        alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
            let note = alert.textFields?.first?.text
            completion(note)
        })
        
        viewController.present(alert, animated: true)
    }
}
