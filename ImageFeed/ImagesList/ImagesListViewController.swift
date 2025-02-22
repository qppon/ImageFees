//
//  ViewController.swift
//  ImageFeed
//
//  Created by Jojo Smith on 10/29/24.
//

import UIKit

class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imageListService = ImagesListService.shared
    
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            guard !photo.largeImageURL.isEmpty, let url = URL(string: photo.largeImageURL) else {
                assertionFailure("Invalid or empty URL for image")
                return
            }
            viewController.imageURL = url
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.rowHeight = 200
        
        NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                
                updateTableViewAnimated()
            }
        imageListService.fetchPhotosNextPage()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imageListService.fetchPhotosNextPage()
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        if let url = URL(string: photo.largeImageURL) {
            
            cell.cellImage.kf.indicatorType = .activity
            let placeholder = UIImage(resource: .placeholder)
            cell.cellImage.contentMode = .center
            
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: nil,
                progressBlock: nil
            ) { [weak self] result in
                switch result {
                case .success:
                    
                    DispatchQueue.main.async {
                        cell.cellImage.contentMode = .scaleAspectFill
                        self?.tableView.beginUpdates()
                        self?.tableView.endUpdates()
                    }
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
            cell.dateLabel.text = dateFormatter.string(from: Date())
            
            let likeImage = UIImage(resource: photo.isLiked ? .likedButtonOn : .likedButtonOff)
            cell.likeButton.setImage(likeImage, for: .normal)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        
        return imageListCell
    }
}


extension ImagesListViewController: ImagesListCellDelegate {
    func cellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        let isPhotoLiked = !photo.isLiked
        
        imageListService.changeLike(photoId: photo.id, isLike: isPhotoLiked) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    guard let self = self else { return }
                    
                    if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
                        self.photos[index].isLiked = isPhotoLiked
                    }
                    
                    cell.setIsLiked(isLiked: isPhotoLiked)
                    UIBlockingProgressHUD.dismiss()
                case .failure:
                    print("Error")
                    UIBlockingProgressHUD.dismiss()
                }
            }
        }
    }
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = photos[indexPath.row]
        _ = URL(string: image.largeImageURL)
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageWidth != 0 ? imageViewWidth / imageWidth : 0
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}

