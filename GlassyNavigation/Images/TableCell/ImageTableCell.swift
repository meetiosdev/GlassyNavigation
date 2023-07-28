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
    @IBOutlet weak var indexLabel: UILabel!
    
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
