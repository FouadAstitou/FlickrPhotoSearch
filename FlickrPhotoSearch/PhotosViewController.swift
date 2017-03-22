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
    case search = "Search"
    case searching = "Searching..."
}

class PhotosViewController: UIViewController {
    
    var photoStore: PhotoStore!
    fileprivate let photoDataSource = PhotoDataSource()
    
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = UIColor.white
        textField.layer.cornerRadius = 5
        textField.returnKeyType = .search
        textField.placeholder = "Search"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        addConstraintsTo(collectionView: self.collectionView)
        fetchPhotosFromFlickr()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Check if there's an internet connection
        ReachabilityHelper.checkReachability(viewController: self)
    }
    
    override func viewWillLayoutSubviews() {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupViews() {
        if let navigationBarWidth = navigationController?.navigationBar.frame.size.width {
            self.searchTextField.frame = CGRect(x: 0, y: 0, width: navigationBarWidth / 2, height: 30)
        }
        navigationItem.titleView = self.searchTextField
        view.addSubview(self.collectionView)
    }
    
    private func addConstraintsTo(collectionView: UICollectionView) {
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
    }
    
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
                    cell.updateWithImage(image: flickrPhoto.image)
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

extension PhotosViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Checks if the textfield is not empty.
        if textField.text!.isEmpty {
            showAlertWith(title: "S😉rry", message: "No search term detected, please enter a search term.")
            return false
        }
        else {
            textField.placeholder = TextFieldPlaceHolderText.searching.rawValue
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            textField.addSubview(activityIndicator)
            activityIndicator.frame = textField.bounds
            activityIndicator.startAnimating()
            
            // Fetches the photos from flickr using the user's search term.
            photoStore.fetchPhotosFromFlickr(searchTerm: textField.text!) {
                (photosResult) -> Void in
                
                // Calls the mainthread to update the UI.
                OperationQueue.main.addOperation() {
                    
                    switch photosResult {
                        
                    case let .success(photos):
                        
                        // Checks if photos were found using the search term.
                        if photos.count == 0 {
                            self.showAlertWith(title: "S😞rry", message: "No images found matching your search for: \(textField.text), please try again.")
                        }
                        activityIndicator.removeFromSuperview()
                        textField.placeholder = TextFieldPlaceHolderText.search.rawValue
                        
                        // Sets the result to the data source array.
                        self.photoDataSource.flickrPhotos = photos
                        print("Successfully found \(photos.count) recent photos.")
                        
                    case let .failure(error):
                        
                        ReachabilityHelper.checkReachability(viewController: self)
                        activityIndicator.removeFromSuperview()
                        //textField.placeholder = TextFieldPlaceHolderText.Search.rawValue
                        self.photoDataSource.flickrPhotos.removeAll()
                        self.showAlertWith(title: "", message: "Something went wrong, please try again.")
                        
                        print("Error fetching photo's for search term: \(textField.text!), error: \(error)")
                    }
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                    self.collectionView.contentOffset = CGPoint.zero
                }
            }
            textField.text = nil
            textField.resignFirstResponder()
            //self.collectionView?.backgroundColor = UIColor.white
            
            return true
        }
    }
    
}

