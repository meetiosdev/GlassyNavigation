//
//  ImageTableCell.swift
//  GlassyNavigation
//
//  Created by Swarajmeet Singh on 26/07/23.
//

import UIKit

class ImageTableCell: UITableViewCell {
    @IBOutlet weak var entityImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var photo : Photo!{
        didSet{
            if let photo{
                self.entityImage.loadImage(from: photo.url)
                self.descriptionLabel.text = photo.description
                self.titleLabel.text = photo.title
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      // self.backgroundColor = .green
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}



extension UIImageView {
    private static let imageCache = NSCache<NSString, UIImage>()

    func loadImage(from urlString: String, showLoader: Bool = true, completion: (() -> Void)? = nil) {
        // Clear any existing image
        image = nil

        // Check if the image is available in cache
        if let cachedImage = UIImageView.imageCache.object(forKey: NSString(string: urlString)) {
            image = cachedImage
            completion?()
            return
        }

        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion?()
            return
        }

        if showLoader {
            showActivityIndicator()
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.hideActivityIndicator()

                guard let data = data, let image = UIImage(data: data), error == nil else {
                    print("Failed to load image from URL: \(urlString), Error: \(error?.localizedDescription ?? "Unknown error")")
                    completion?()
                    return
                }

                self?.image = image

                // Cache the image
                UIImageView.imageCache.setObject(image, forKey: NSString(string: urlString))

                completion?()
            }
        }.resume()
    }

    private func showActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    private func hideActivityIndicator() {
        subviews.compactMap { $0 as? UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
    }
}
