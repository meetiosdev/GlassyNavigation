//
//  ImagesController.swift
//  GlassyNavigation
//
//  Created by Swarajmeet Singh on 26/07/23.
//

import UIKit

class ImagesController: UIViewController {
    
    var data: [Photo] = []
    var currentPage = 1
    let itemsPerPage = 20
    var isLoading = false
    
    
    @IBOutlet weak var imagesTableView: UITableView!{
        didSet{
            let nib = UINib(nibName: "ImageTableCell", bundle: Bundle.main)
            imagesTableView.register(nib, forCellReuseIdentifier: "ImageTableCell")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchNextPage()
        getImages()
        
    }
    
    func getImages(){
        let baseUrl = "https://api.slingacademy.com/v1/sample-data/photos"
        let params = ["offset":"\(currentPage)",
                      "limit":"\(itemsPerPage)"]
      
        APIClient.shared.get(url: baseUrl,parameters: params, responseType: PhotosBase.self) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.data.append(contentsOf: response.photos)
                    self.currentPage += 1
                    self.isLoading = false
                    self.imagesTableView.reloadData()
                    
                    // Hide the loader activity indicator
                    self.imagesTableView.tableFooterView?.isHidden = true
                }
                
            case .failure(let error):
                // Handle error
                print(error)
            }
        }
    }
    
    
    
    
    
}
extension ImagesController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableCell") as! ImageTableCell
        cell.photo = self.data[indexPath.row]
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
            spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            tableView.tableFooterView = spinner
            tableView.tableFooterView?.isHidden = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 2 {
            getImages()
        }
    }
    
    
}
