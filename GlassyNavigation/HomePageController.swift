//
//  HomePageController.swift
//  GlassyNavigation
//
//  Created by Swarajmeet Singh on 27/07/23.
//

import UIKit
import UIKit

class HomePageController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    private var pageViewController: UIPageViewController!
    private var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sb = UIStoryboard(name: "Main", bundle: .main)
        // Instantiate your view controllers
        let feedController = sb.instantiateViewController(identifier: "ImagesController") as! ImagesController
        let chatController = sb.instantiateViewController(identifier: "ChatController") as! ChatController
        
        // Add the view controllers to the array
        viewControllers.append(feedController)
        viewControllers.append(chatController)
        
        // Set up the page view controller
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // Set the initial view controller
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: true, completion: nil)
        
        // Add the page view controller to the containerView
        addChild(pageViewController)
        
        containerView.addSubview(pageViewController.view)
        pageViewController.view.frame = containerView.bounds
        pageViewController.didMove(toParent: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLogoToNavigationBarItem()
        let image = "https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=1000"
        let circularBarButton = UIBarButtonItem.profileImage(urlString: image, target: self, action: #selector(profileImageTapped))
        navigationItem.leftBarButtonItem = circularBarButton
    }
    
    @objc func profileImageTapped() {
        // Handle the button tap event here
        print("Profile image button tapped!")
    }
}

// MARK: - UIPageViewControllerDataSource

extension HomePageController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllers.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return viewControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllers.firstIndex(of: viewController), currentIndex < viewControllers.count - 1 else {
            return nil
        }
        return viewControllers[currentIndex + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension HomePageController: UIPageViewControllerDelegate {
    
    // If you want to perform actions when the user finishes a swipe gesture, you can implement the following delegate method:
    /*
     func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
     if completed, let currentViewController = pageViewController.viewControllers?.first {
     // Do something with the currentViewController after the swipe animation is completed
     if let currentIndex = viewControllers.firstIndex(of: currentViewController) {
     if currentIndex == 0 {
     // The user swiped to FeedController
     } else if currentIndex == 1 {
     // The user swiped to ChatController
     }
     }
     }
     }
     */
}
