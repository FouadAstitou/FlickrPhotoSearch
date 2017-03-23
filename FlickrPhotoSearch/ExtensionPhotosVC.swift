//
//  ExtensionPhotosVC.swift
//  FlickrPhotoSearch
//
//  Created by Supervisor on 23-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import UIKit

// I would refactor this if i had more time.

// MARK: - UITextFieldDelegate methods.
extension PhotosViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let spinner = textField.showSpinner(inView: textField)
        
        if textField.text!.isEmpty {
            showAlertWith(title: "S😉rry", message: "No search term detected, please enter a search term.")
            return false
        }
        else {
            textField.placeholder = TextFieldPlaceHolderText.searching.rawValue
            spinner.startAnimating()
            
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
                        spinner.removeFromSuperview()
                        textField.placeholder = TextFieldPlaceHolderText.search.rawValue
                        
                        // Sets the result to the data source array.
                        self.photoDataSource.flickrPhotos = photos
                        
                    case let .failure(error):
                        
                        ReachabilityHelper.checkReachability(viewController: self)
                        spinner.removeFromSuperview()
                        textField.placeholder = TextFieldPlaceHolderText.search.rawValue
                        self.photoDataSource.flickrPhotos.removeAll()
                        self.showAlertWith(title: "", message: "Something went wrong, please try again.")
                        
                        print("Error fetching photo's for search term: \(textField.text!), error: \(error)")
                    }
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                }
            }
            textField.text = nil
            textField.resignFirstResponder()
            
            return true
        }
    }
}
