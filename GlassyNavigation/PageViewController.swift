import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private let viewControllersIDs = ["FeedNavigationController", "ChatController"]
    private var lchildViewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        lchildViewControllers = viewControllersIDs.compactMap { viewControllerID in
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            return storyboard.instantiateViewController(withIdentifier: viewControllerID)
        }
        
        if let firstViewController = lchildViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        self.view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = lchildViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = currentIndex - 1
        return (previousIndex >= 0 && previousIndex < lchildViewControllers.count) ? lchildViewControllers[previousIndex] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = lchildViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = currentIndex + 1
        return (nextIndex < lchildViewControllers.count) ? lchildViewControllers[nextIndex] : nil
    }
    
}
