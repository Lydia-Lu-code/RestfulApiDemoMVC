// MARK: - FavoriteVideo.swift
import Foundation

// MARK: - Models
struct FavoriteVideo: Codable {
    let id: String
    var title: String
    var description: String
    let thumbnailURL: String
    var note: String?
    
    init(from video: Video, note: String? = nil) {
        self.id = video.id ?? UUID().uuidString
        self.title = video.title
        self.description = video.description
        self.thumbnailURL = video.thumbnailURL
        self.note = note
    }
}



// MARK: - Errors
enum LocalStorageError: LocalizedError {
    case saveFailed
    case notFound
    case alreadyExists
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "無法保存數據"
        case .notFound:
            return "找不到指定的收藏"
        case .alreadyExists:
            return "該影片已經收藏"
        }
    }
}


