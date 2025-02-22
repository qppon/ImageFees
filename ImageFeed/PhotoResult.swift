//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Jojo Smith on 2/7/25.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let description: String?
    let urls: UrlsResult
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case urls
        case isLiked = "liked_by_user"
    }
}
struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}
