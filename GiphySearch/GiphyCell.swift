//
//  GiphyCell.swift
//  GiphySearch
//
//  Created by Kyle Fang on 6/18/16.
//  Copyright © 2016 Kyle Fang. All rights reserved.
//

import UIKit
import FLAnimatedImage

class GiphyCell: UICollectionViewCell {
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var imageView: FLAnimatedImageView!
    
    func render(giphy: Giphy) {
        self.tagLabel.hidden = giphy.tags.count == 0
        self.tagLabel.text = giphy.tags.joinWithSeparator(", ")
        self.imageView.animatedImage = nil
        self.imageView.image = nil
        self.imageView.nk_setImageWith(NSURL(string: giphy.images)!)
    }
}