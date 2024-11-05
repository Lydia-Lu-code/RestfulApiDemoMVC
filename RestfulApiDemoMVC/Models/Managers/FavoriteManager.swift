// MARK: - FavoriteManager.swift
import Foundation

// MARK: - Network FavoriteManager
class FavoriteManager: FavoriteManageable {
    static let shared = FavoriteManager()
    private init() {}
    
    func addToFavorites(_ video: FavoriteVideo, completion: @escaping (Result<FavoriteVideo, Error>) -> Void) {
        NetworkManager.shared.performRequest(
            endpoint: "/favorites",
            method: .post,
            body: try? JSONEncoder().encode(video),
            completion: completion
        )
    }
    
    func updateFavorite(_ video: FavoriteVideo, completion: @escaping (Result<FavoriteVideo, Error>) -> Void) {
        NetworkManager.shared.performRequest(
            endpoint: "/favorites/\(video.id)",
            method: .put,
            body: try? JSONEncoder().encode(video),
            completion: completion
        )
    }
    
    func deleteFavorite(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        NetworkManager.shared.performRequestWithoutResponse(
            endpoint: "/favorites/\(id)",
            method: .delete,
            completion: completion
        )
    }
    
    func fetchFavorites(completion: @escaping (Result<[FavoriteVideo], Error>) -> Void) {
        NetworkManager.shared.performRequest(
            endpoint: "/favorites",
            method: .get,
            completion: completion
        )
    }
}






