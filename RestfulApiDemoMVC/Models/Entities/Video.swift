import Foundation

// MARK: - Models/Video.swift
struct Video: Codable {
    var id: String?
    let title: String
    let description: String
    let thumbnailURL: String
    
    init(from snippet: Snippet) {
        self.title = snippet.title
        self.description = snippet.description
        self.thumbnailURL = snippet.thumbnails.medium.url
    }
}

// YouTube API Response Models
struct VideoListResponse: Codable {
    let items: [VideoItem]
}

struct VideoItem: Codable {
    let id: String
    let snippet: Snippet
}

struct Snippet: Codable {
    let title: String
    let description: String
    let thumbnails: Thumbnails
}

struct Thumbnails: Codable {
    let medium: ThumbnailInfo
}

struct ThumbnailInfo: Codable {
    let url: String
}
