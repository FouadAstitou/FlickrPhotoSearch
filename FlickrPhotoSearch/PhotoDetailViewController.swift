//
//  PhotoDetailViewController.swift
//  FlickrPhotoSearch
//
//  Created by Supervisor on 22-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    //MARK: - Properties
    var photoStore: PhotoStore!
    var photoDataSource: PhotoDataSource!
    var selectedPhotoIndex: Int!
    
    lazy var collectionView: UICollectionView = {
        let layout = CustomFlowLayout()
        layout.scrollDirection = . horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: PhotoCollectionCell.identifier)
        cv.dataSource = self.photoDataSource
        cv.delegate = self
        cv.backgroundColor = UIColor.white
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(self.collectionView)
        view.addConstraintsTo(collectionView: self.collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityHelper.checkReachability(viewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.isHidden = false
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let indexPath = IndexPath(row: self.selectedPhotoIndex, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .left , animated: true)
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }
}

// MARK: - UICollectionView delegate methods.
extension PhotoDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Make the collectionview cell full screen
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let flickrPhoto = photoDataSource.flickrPhotos[indexPath.row]
        self.title = flickrPhoto.title
        
        // Downloads the image data for a thumbnail.
        photoStore.fetchImageForPhoto(flickrPhoto: flickrPhoto, size: .regular) { (result) -> Void in
            
            // Calls the mainthread to update the UI.
            OperationQueue.main.addOperation() {
                
                /* The indexpath for the photo might have changed between the time the request started and finished, so find the most recent indeaxpath */
                let photoIndex = self.photoDataSource.flickrPhotos.index(of: flickrPhoto)!
                let photoIndexPath = IndexPath(row: photoIndex, section: 0)
                
                // When the request finishes, only update the cell if it's still visible
                if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionCell {
                    cell.updateWithImage(image: flickrPhoto.image, size: .regular)
                }
            }
        }
    }
}
