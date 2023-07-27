import UIKit

class ImagesController: UIViewController {
    // MARK: - Properties
    var data: [Photo] = []
    var currentPage = 1
    let itemsPerPage = 20
    var isFetchingData = false // To avoid multiple API calls
    
    // MARK: - IBOutlets
    @IBOutlet weak var imagesTableView: UITableView! {
        didSet {
            let nib = UINib(nibName: "ImageTableCell", bundle: Bundle.main)
            imagesTableView.register(nib, forCellReuseIdentifier: "ImageTableCell")
        }
    }
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.addLogoToNavigationBarItem()
    }
    
    // MARK: - API Call
    func fetchImages() {
        guard !isFetchingData else { return }
        isFetchingData = true
        
        Task.detached {
            await self.getImages()
        }
    }
    
    func getImages() async {
        let baseUrl = "https://api.slingacademy.com/v1/sample-data/photos"
        let params = ["offset": "\(currentPage)", "limit": "\(itemsPerPage)"]
        
        do {
            let response: PhotosBase = try await APIClient.shared.get(url: baseUrl, parameters: params, responseType: PhotosBase.self)
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.data.append(contentsOf: response.photos)
                self.data = self.data.removingDuplicates(by: \.id)
                self.currentPage += 1
                self.imagesTableView.reloadData()
                
                // Hide the loader activity indicator
                self.imagesTableView.tableFooterView?.isHidden = true
//                self.totalLabel.text = "Total Results: \(self.data.count)"
//                self.pageLabel.text = "Page Number: \(response.offset)"
                
                self.isFetchingData = false
            }
        } catch {
            // Handle error
            print("Error: \(error)")
            self.isFetchingData = false
        }
    }
}

// MARK: - Table View DataSource and Delegate
extension ImagesController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableCell", for: indexPath) as! ImageTableCell
        cell.photo = self.data[indexPath.row]
        cell.indexLabel.text = "Index: \(indexPath.row) -- Id: \(self.data[indexPath.row].id)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            spinner.color = .red
            spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            tableView.tableFooterView = spinner
            tableView.tableFooterView?.isHidden = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 2 {
            // Hide the activity indicator if already fetching data
            if isFetchingData {
                imagesTableView.tableFooterView?.isHidden = false
                return
            }
            
            // Load more data when reaching the end of the table
            fetchImages()
        }
    }
}

// MARK: - Array Extension for Removing Duplicates
extension Array where Element: Hashable {
    func removingDuplicates<Key: Hashable>(by key: KeyPath<Element, Key>) -> [Element] {
        let uniqueElements = reduce(into: [Key: Element]()) { result, element in
            let key = element[keyPath: key]
            result[key] = element
        }.values
        
        return Array(uniqueElements)
    }
}
