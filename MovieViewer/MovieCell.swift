//
//  MovieCell.swift
//  MovieViewer
//
//  Created by Edward Xue on 1/9/16.
//  Copyright © 2016 eidehua. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UIView!
    @IBOutlet weak var overviewLabel: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
