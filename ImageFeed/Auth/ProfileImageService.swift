//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Jojo Smith on 1/14/25.
//

import Foundation

struct UserResult: Codable {
    let profileImageUrl: Dictionary<String, String>
    
    enum CodingKeys: String, CodingKey {
        case profileImageUrl = "profile_image"
    }
}


enum ProfileError: Error {
    case invalidRequest
}


final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var task: URLSessionTask?
    private let storage = OAuth2TokenStorage.shared
    private(set) var avatarURL: String?
    static let shared = ProfileImageService()
    
    private init() {}
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let token = storage.bearerToken else {
            print("no token")
            return nil
        }
        
        guard let url = URL(
            string: "/users/\(username)"
            + "?client_id=\(Constants.accessKey)",
            relativeTo: Constants.defaultBaseURL)
        else {
            assertionFailure("Failed to create URL for username: \(username)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            print("The request is already in progress")
            completion(.failure(ProfileError.invalidRequest))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username) else {
            completion(.failure(ProfileError.invalidRequest))
            print("failed to create request")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userImage):
                guard let profileImageUrl = userImage.profileImageUrl["small"] else {
                    print("not correct decoding")
                    return
                }
                self.avatarURL = profileImageUrl
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageUrl])
                
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func deleteAvatar() {
        avatarURL = nil
    }
    
}
