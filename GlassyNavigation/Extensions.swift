//
//  Extensions.swift
//  GlassyNavigation
//
//  Created by Swarajmeet Singh on 28/07/23.
//

import UIKit

extension UIViewController {
    
    func addLogoToNavigationBarItem() {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.image =  UIImage(named: "logo")
        //imageView.backgroundColor = .lightGray
        
        // In order to center the title view image no matter what buttons there are, do not set the
        // image view as title view, because it doesn't work. If there is only one button, the image
        // will not be aligned. Instead, a content view is set as title view, then the image view is
        // added as child of the content view. Finally, using constraints the image view is aligned
        // inside its parent.
        let contentView = UIView()
        self.navigationItem.titleView = contentView
        self.navigationItem.titleView?.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}



// Create a custom cache for images
let imageCache = NSCache<NSString, UIImage>()

extension UIBarButtonItem {
    static func profileImage(urlString: String, target: Any?, action: Selector?) -> UIBarButtonItem {
        let circularButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 34.4, height: 34.4)) // Adjust the size as needed

        let circularButton = UIButton(type: .custom)
        circularButton.frame = circularButtonView.bounds
        circularButton.layer.cornerRadius = circularButton.frame.size.width / 2
        circularButton.clipsToBounds = true
        circularButton.imageView?.contentMode = .scaleAspectFill
        if let target = target, let action = action {
            circularButton.addTarget(target, action: action, for: .touchUpInside)
        }

        circularButton.setBackgroundImage(UIImage(named: "placeholder"), for: .normal) // Set a placeholder image

        // Check if the image is already in the cache
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            circularButton.setBackgroundImage(cachedImage, for: .normal)
        } else {
            // If not in cache, download the image
            if let url = URL(string: urlString) {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data, let image = UIImage(data: data) {
                        // Update the image on the main thread
                        DispatchQueue.main.async {
                            circularButton.setBackgroundImage(image, for: .normal)
                        }
                        // Cache the downloaded image
                        imageCache.setObject(image, forKey: urlString as NSString)
                    }
                }
                task.resume()
            }
        }

        circularButtonView.addSubview(circularButton)
        return UIBarButtonItem(customView: circularButtonView)
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
