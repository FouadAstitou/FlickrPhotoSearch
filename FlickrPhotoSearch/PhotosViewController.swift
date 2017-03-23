//
//  ViewController.swift
//  FlickrPhotoSearch
//
//  Created by Supervisor on 22-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import UIKit

// Enum for changing the textfield placeholder text.
enum TextFieldPlaceHolderText: String {
    case search = " Search"
    case searching = " Searching..."
}

class PhotosViewController: UIViewController {
    
    //MARK: - Properties
    var photoStore: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    fileprivate lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = UIColor.white
        textField.layer.cornerRadius = 5
        textField.returnKeyType = .search
        textField.placeholder = " Search"
        return textField
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: PhotoCollectionCell.identifier)
        cv.dataSource = self.photoDataSource
        cv.delegate = self
        cv.backgroundColor = UIColor.white
        cv.contentInset = UIEdgeInsetsMake(4, 4, 4, 4)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        view.addConstraintsTo(collectionView: self.collectionView)
        fetchPhotosFromFlickr()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Check if there's an internet connection
        ReachabilityHelper.checkReachability(viewController: self)
    }
    
    private func setupViews() {
        if let navigationBarWidth = navigationController?.navigationBar.frame.size.width {
            self.searchTextField.frame = CGRect(x: 0, y: 0, width: navigationBarWidth / 2, height: 30)
        }
        navigationItem.titleView = self.searchTextField
        view.addSubview(self.collectionView)
    }
    
    // MARK: - fetchPhotosFromFlickr
    private func fetchPhotosFromFlickr() {
        photoStore.fetchPhotosFromFlickr(searchTerm: nil) { (photoResult) in
            OperationQueue.main.addOperation {
                switch photoResult {
                    
                case let .success(photos):
                    self.photoDataSource.flickrPhotos = photos
                    print(photos.count)
                case let .failure(error) :
                    print(error)
                }
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - UICollectionView delegate methods.
extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // still need to refactor the size using best practices.
        let cellWidthAndHeight = view.frame.width / 4 - 10
        return CGSize(width: cellWidthAndHeight, height: cellWidthAndHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let flickrPhoto = photoDataSource.flickrPhotos[indexPath.row]
        
        // Downloads the image data for a thumbnail.
        photoStore.fetchImageForPhoto(flickrPhoto: flickrPhoto, size: .thumbnail) { (result) -> Void in
            
            OperationQueue.main.addOperation() {
                
                // The indexpath for the photo might have changed between the time the request started and finished, so find the most recent indeaxpath
                let photoIndex = self.photoDataSource.flickrPhotos.index(of: flickrPhoto)!
                let photoIndexPath = IndexPath(row: photoIndex, section: 0)
                
                // When the request finishes, only update the cell if it's still visible
                if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionCell {
                    cell.updateWithImage(image: flickrPhoto.image, size: .thumbnail)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPhotoIndex = indexPath.row
        let photoDetailVC = PhotoDetailViewController()
        
        photoDetailVC.photoStore = self.photoStore
        photoDetailVC.photoDataSource = self.photoDataSource
        photoDetailVC.selectedPhotoIndex = selectedPhotoIndex
        photoDetailVC.collectionView.isHidden = true
        self.navigationController?.pushViewController(photoDetailVC, animated: true)
    }
}

