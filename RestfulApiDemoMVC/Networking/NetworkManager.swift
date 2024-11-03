//
//  NetworkManager.swift
//  RestfulApiDemoMVC
//
//  Created by Lydia Lu on 2024/10/31.
//

import Foundation

// MARK: - HTTPMethod.swift
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - NetworkManager.swift
class NetworkManager {
    static let shared = NetworkManager()
    private let apiKey = "AIzaSyBZKww0PeqoAQ1Y8kPA7fMcOI76NxSBSZs"
    private let baseURL = "https://www.googleapis.com/youtube/v3"
    
    private init() {}
    
    // 將方法改為 internal 存取層級
    func performRequest<T: Codable>(endpoint: String,
                                  method: HTTPMethod,
                                  body: Data? = nil,
                                  completion: @escaping (Result<T, Error>) -> Void) {
        let urlString = "\(baseURL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.requestFailed("Status code: \(httpResponse.statusCode)")))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Decoding error:", error)
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
    
    // 將方法改為 internal 存取層級
    func performRequestWithoutResponse(endpoint: String,
                                    method: HTTPMethod,
                                    body: Data? = nil,
                                    completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseURL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.requestFailed("Status code: \(httpResponse.statusCode)")))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
}

// MARK: - NetworkManager Extension
extension NetworkManager {
    // CRUD 操作方法
    
    func fetchVideos(completion: @escaping (Result<[Video], Error>) -> Void) {
        let endpoint = "/videos?part=snippet&chart=mostPopular&maxResults=50&regionCode=TW&key=\(apiKey)"
        
        performRequest(endpoint: endpoint, method: .get) { (result: Result<VideoListResponse, Error>) in
            switch result {
            case .success(let response):
                let videos = response.items.map { Video(from: $0.snippet) }
                completion(.success(videos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createVideo(video: Video, completion: @escaping (Result<Video, Error>) -> Void) {
        let endpoint = "/videos?key=\(apiKey)"
        
        do {
            let data = try JSONEncoder().encode(video)
            performRequest(endpoint: endpoint, method: .post, body: data, completion: completion)
        } catch {
            completion(.failure(NetworkError.encodingError))
        }
    }
    
    func updateVideo(_ video: Video, videoId: String, completion: @escaping (Result<Video, Error>) -> Void) {
        let endpoint = "/videos/\(videoId)?key=\(apiKey)"
        
        do {
            let data = try JSONEncoder().encode(video)
            performRequest(endpoint: endpoint, method: .put, body: data, completion: completion)
        } catch {
            completion(.failure(NetworkError.encodingError))
        }
    }
    
    func deleteVideo(videoId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = "/videos/\(videoId)?key=\(apiKey)"
        performRequestWithoutResponse(endpoint: endpoint, method: .delete, completion: completion)
    }
}
