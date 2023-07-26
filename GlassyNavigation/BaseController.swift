//
//  BaseController.swift
//  GlassyNavigation
//
//  Created by Swarajmeet Singh on 26/07/23.
//

import UIKit

class BaseController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loadImagesButtonTapped(_ button: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = sb.instantiateViewController(identifier: "ImagesController") as! ImagesController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}

