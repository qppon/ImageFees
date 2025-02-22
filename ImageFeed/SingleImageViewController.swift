//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Jojo Smith on 11/14/24.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    var imageURL: URL?
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let items = [image]
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }
    
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = imageSize.width != 0 ? visibleRectSize.width / imageSize.width : 0
        let vScale = imageSize.height != 0 ? visibleRectSize.height / imageSize.height : 0
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        if let url = imageURL {
            UIBlockingProgressHUD.show()
            let placeholderImage = UIImage(named: "vvv")
            imageView.image = placeholderImage
            imageView.contentMode = .center
            
            
            imageView.kf.setImage(
                with: url,
                placeholder: placeholderImage,
                options: nil,
                progressBlock: nil,
                completionHandler: { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let value):
                            UIBlockingProgressHUD.dismiss()
                            self?.image = value.image
                        case .failure:
                            UIBlockingProgressHUD.dismiss()
                            print("error")
                        }
                    }
                }
            )
        }
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
