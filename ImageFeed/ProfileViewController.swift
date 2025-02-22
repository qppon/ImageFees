//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Jojo Smith on 11/12/24.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let profileLogoutService = ProfileLogoutService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        guard let profile = ProfileService.shared.profile else {
            print("empty profile data")
            return }
        
        makeLabels(profile.fullName, profile.username, profile.bio)
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                updateAvatar()
            }
        updateAvatar()
        
        makeButton()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        makeProfileIcon(imageUrl: url)
    }
    
    private func makeProfileIcon(imageUrl: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        let placeholder = UIImage(resource: .userpick)
        let profileIcon = UIImageView()
        profileIcon.kf.indicatorType = .activity
        profileIcon.kf.setImage(with: imageUrl, placeholder: placeholder, options: [.processor(processor)])
        
        profileIcon.layer.cornerRadius = 35
        profileIcon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileIcon)
        
        NSLayoutConstraint.activate([
            profileIcon.heightAnchor.constraint(equalToConstant: 70),
            profileIcon.widthAnchor.constraint(equalToConstant: 70),
            profileIcon.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            profileIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func makeLabels(_ name: String, _ userName: String, _ bio: String?) {
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        let instLabel = UILabel()
        instLabel.text = userName
        instLabel.font = UIFont.systemFont(ofSize: 13)
        instLabel.textColor = .ypGray
        instLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instLabel)
        
        let helloWorldLabel = UILabel()
        helloWorldLabel.text = bio ?? ""
        helloWorldLabel.font = UIFont.systemFont(ofSize: 13)
        helloWorldLabel.textColor = .white
        helloWorldLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(helloWorldLabel)
        
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 152),
            instLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            helloWorldLabel.topAnchor.constraint(equalTo: instLabel.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            helloWorldLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
            
        ])
    }
    
    private func makeButton() {
        let exitButton = UIButton.systemButton(
            with: UIImage.exitButton,
            target: self,
            action: #selector(self.didTapButton)
        )
        exitButton.tintColor = .ypRed
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        exitButton.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 111).isActive = true
    }
    
    @objc
    private func didTapButton() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.profileLogoutService.logout()
            
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid Configuration")
                return
            }
            let authViewController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "AuthViewController")
            window.rootViewController = authViewController
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .default, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
}
