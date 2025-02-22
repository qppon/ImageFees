//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Jojo Smith on 1/8/25.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    private init() {}
    
    enum ProfileError: Error {
        case invalidRequest
    }
    
    private func makeProfileRequest(_ token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            print("The requesst is already in progress")
            completion(.failure(ProfileError.invalidRequest))
            return
        }
        
        guard let request = makeProfileRequest(token) else {
            completion(.failure(ProfileError.invalidRequest))
            print("Failed to create request")
            return
        }
        let task = URLSession.shared.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(username: profileResult.username, firstName: profileResult.firstName, lastName: profileResult.lastName, bio: profileResult.bio)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func deletProfil() {
        profile = nil
    }
}
