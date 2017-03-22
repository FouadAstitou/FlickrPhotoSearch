//
//  PhotoCollectionCell.swift
//  FlickrPhotoSearch
//
//  Created by Supervisor on 22-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let identifier = "PhototCollectionCell"
    /*
     let thumbnailImageView: UIImageView = {
     let imageView = UIImageView()
     imageView.contentMode = .scaleAspectFill
     return imageView
     }()
     */
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let actitvityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        return activityIndicator
    }()
    
    // override func layoutSubviews() {
    //    super.layoutSubviews()
    
    //}
    
    func setupViews() {
        addSubview(self.photoImageView)
        self.photoImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        self.actitvityIndicatorView.frame = self.photoImageView.bounds
        self.photoImageView.addSubview(self.actitvityIndicatorView)
        
        //bringSubview(toFront: actitvityIndicatorView)
        self.actitvityIndicatorView.startAnimating()
        
        //addConstraint(NSLayoutConstraint(item: photoImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        //addConstraint(NSLayoutConstraint(item: photoImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        //addConstraint(NSLayoutConstraint(item: photoImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
        //addConstraint(NSLayoutConstraint(item: photoImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
    }
    
    // Helper method for updating the spinner.
    func updateWithImage(image: UIImage?) {
        
        if let imageToDisplay = image {
            self.actitvityIndicatorView.stopAnimating()
            self.photoImageView.image = imageToDisplay
        }
        else {
            self.actitvityIndicatorView.stopAnimating()
            self.photoImageView.image = nil
        }
    }
    
    func updateWithThumb(image: UIImage?) {
        
        if let imageToDisplay = image {
            //            spinner.stopAnimating()
            photoImageView.image = imageToDisplay
        }
        else {
            //            spinner.startAnimating()
            photoImageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateWithImage(image: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateWithImage(image: nil)
    }
    
}

