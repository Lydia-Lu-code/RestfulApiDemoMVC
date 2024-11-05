//
//  FavoriteManageable.swift
//  RestfulApiDemoMVC
//
//  Created by Lydia Lu on 2024/11/3.
//

import Foundation

// MARK: - Protocols
protocol FavoriteManageable {
    func fetchFavorites(completion: @escaping (Result<[FavoriteVideo], Error>) -> Void)
    func addToFavorites(_ video: FavoriteVideo, completion: @escaping (Result<FavoriteVideo, Error>) -> Void)
    func updateFavorite(_ video: FavoriteVideo, completion: @escaping (Result<FavoriteVideo, Error>) -> Void)
    func deleteFavorite(id: String, completion: @escaping (Result<Void, Error>) -> Void)
}
