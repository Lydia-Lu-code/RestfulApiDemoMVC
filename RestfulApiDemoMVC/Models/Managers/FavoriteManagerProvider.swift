//
//  FavoriteManagerProvider.swift
//  RestfulApiDemoMVC
//
//  Created by Lydia Lu on 2024/11/3.
//

import Foundation

// MARK: - FavoriteManager Provider
class FavoriteManagerProvider {
    static let shared = FavoriteManagerProvider()
    private init() {}
    
    private let useLocalStorage = true
    
    var favoriteManager: FavoriteManageable {
        useLocalStorage ? LocalFavoriteManager.shared : FavoriteManager.shared
    }
}
