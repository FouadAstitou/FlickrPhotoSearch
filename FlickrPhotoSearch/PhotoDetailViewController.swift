//
//  PhotoDetailViewController.swift
//  FlickrPhotoSearch
//
//  Created by Supervisor on 22-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    var photoStore: PhotoStore!
    var photoDataSource: PhotoDataSource!
    var selectedPhotoIndex: Int!
    
    lazy var collectionView: UICollectionView = {
        let layout = CustomFlowLayout()
        layout.scrollDirection = . horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self.photoDataSource
        cv.delegate = self
        cv.backgroundColor = UIColor.red
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(self.collectionView)
        
        self.collectionView.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: PhotoCollectionCell.identifier)
        
        view.addConstraint(NSLayoutConstraint(item: self.collectionView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: self.collectionView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: self.collectionView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: self.collectionView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.collectionView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.isHidden = false
        
    }
    /*
     override func viewWillLayoutSubviews() {
     super.viewWillLayoutSubviews()
     
     let indexPath = IndexPath(row: self.selectedPhotoIndex, section: 0)
     self.collectionView.scrollToItem(at: indexPath, at: .left , animated: true)
     }
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let indexPath = IndexPath(row: self.selectedPhotoIndex, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .left , animated: true)
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }
}

extension PhotoDetailViewController: UICollectionViewDelegateFlowLayout {
    //update the sizes.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Make the collectionview full screen
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let flickrPhoto = photoDataSource.flickrPhotos[indexPath.row]
        
        // Downloads the image data for a thumbnail.
        photoStore.fetchImageForPhoto(flickrPhoto: flickrPhoto, size: .regular) { (result) -> Void in
            
            // Calls the mainthread to update the UI.
            OperationQueue.main.addOperation() {
                
                // The indexpath for the photo might have changed between the time the request started and finished, so find the most recent indeaxpath
                let photoIndex = self.photoDataSource.flickrPhotos.index(of: flickrPhoto)!
                let photoIndexPath = IndexPath(row: photoIndex, section: 0)
                
                // When the request finishes, only update the cell if it's still visible
                if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionCell {
                    cell.updateWithImage(image: flickrPhoto.image)
                }
            }
        }
    }
    
}
