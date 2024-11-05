//
//  NetworkError.swift
//  RestfulApiDemoMVC
//
//  Created by Lydia Lu on 2024/10/31.
//

import Foundation

// MARK: - NetworkError.swift
enum NetworkError: Error {
    case invalidURL
    case noData
    case encodingError
    case decodingError
    case invalidResponse
    case requestFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "無效的URL"
        case .noData:
            return "無法獲取數據"
        case .encodingError:
            return "數據編碼錯誤"
        case .decodingError:
            return "數據解碼錯誤"
        case .invalidResponse:
            return "無效的伺服器響應"
        case .requestFailed(let message):
            return "請求失敗: \(message)"
        }
    }
}
