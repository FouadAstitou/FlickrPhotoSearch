//
//  PhotoCollectionCell.swift
//  FlickrPhotoSearch
//
//  Created by Supervisor on 22-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
    //MARK: - Properties
    static let identifier = "PhototCollectionCell"
    
    fileprivate let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "flickr-icon")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
 
    fileprivate let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    //MARK: - updateWithImage()
    func updateWithImage(image: UIImage?, size: ImageSize?) {
        
        if let imageToDisplay = image, let imageSize = size {
            switch imageSize {
            case .thumbnail:
                self.thumbnailImageView.image = imageToDisplay
                self.thumbnailImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                addSubview(self.thumbnailImageView)
            case .regular:
                self.photoImageView.image = imageToDisplay
                self.photoImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                addSubview(self.photoImageView)
            }
        }
        else {
            self.thumbnailImageView.image = nil
            self.photoImageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateWithImage(image: nil, size: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateWithImage(image: nil, size: nil)
    }
    
}

