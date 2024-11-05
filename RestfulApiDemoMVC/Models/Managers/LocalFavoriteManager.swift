//
//  LocalFavoriteManager.swift
//  RestfulApiDemoMVC
//
//  Created by Lydia Lu on 2024/11/3.
//

import Foundation

// MARK: - Local FavoriteManager
class LocalFavoriteManager: FavoriteManageable {
    static let shared = LocalFavoriteManager()
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favorite_videos"
    
    private init() {}
    
    func fetchFavorites(completion: @escaping (Result<[FavoriteVideo], Error>) -> Void) {
        if let data = userDefaults.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode([FavoriteVideo].self, from: data) {
            completion(.success(favorites))
        } else {
            completion(.success([]))
        }
    }
    
    func addToFavorites(_ video: FavoriteVideo, completion: @escaping (Result<FavoriteVideo, Error>) -> Void) {
        fetchFavorites { [weak self] result in
            switch result {
            case .success(var favorites):
                if !favorites.contains(where: { $0.id == video.id }) {
                    favorites.append(video)
                    if self?.saveFavorites(favorites) == true {
                        completion(.success(video))
                    } else {
                        completion(.failure(LocalStorageError.saveFailed))
                    }
                } else {
                    completion(.failure(LocalStorageError.alreadyExists))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateFavorite(_ video: FavoriteVideo, completion: @escaping (Result<FavoriteVideo, Error>) -> Void) {
        fetchFavorites { [weak self] result in
            switch result {
            case .success(var favorites):
                if let index = favorites.firstIndex(where: { $0.id == video.id }) {
                    favorites[index] = video
                    if self?.saveFavorites(favorites) == true {
                        completion(.success(video))
                    } else {
                        completion(.failure(LocalStorageError.saveFailed))
                    }
                } else {
                    completion(.failure(LocalStorageError.notFound))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteFavorite(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchFavorites { [weak self] result in
            switch result {
            case .success(var favorites):
                if let index = favorites.firstIndex(where: { $0.id == id }) {
                    favorites.remove(at: index)
                    if self?.saveFavorites(favorites) == true {
                        completion(.success(()))
                    } else {
                        completion(.failure(LocalStorageError.saveFailed))
                    }
                } else {
                    completion(.failure(LocalStorageError.notFound))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func saveFavorites(_ favorites: [FavoriteVideo]) -> Bool {
        if let data = try? JSONEncoder().encode(favorites) {
            userDefaults.set(data, forKey: favoritesKey)
            return true
        }
        return false
    }
}
