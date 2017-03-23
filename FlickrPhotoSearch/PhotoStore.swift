//
//  PhotoStore.swift
//  FlickrPhotoSearch
//
//  Created by Supervisor on 22-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import UIKit

// Checks if the result contains valid JSON data and an array of photos.
enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

// Error handeling.
enum PhotoError: Error {
    case imageCreationError
}

// Size of the image we want to display.
enum ImageSize {
    case thumbnail
    case regular
}

class PhotoStore {
    
    //MARK: - Properties.
    
    fileprivate let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    //MARK: - fetchPhotosFromFlickr
    
    /// Fetches the photos from flickr.
    func fetchPhotosFromFlickr(searchTerm: String?, completion: @escaping (PhotosResult) -> Void) {
        
        let url = FlickrAPI.photosForURL(searchTerm: searchTerm)
        let request = URLRequest(url: url as URL)
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            let result = self.processPhotos(data: data, error: error as NSError?)
            completion(result)
        })
        task.resume()
    }
    
    //MARK: - processPhotosForSearchTerm
    
    /// Processes the JSON data that is returned from the webservice.
    func processPhotos(data: Data?, error: NSError?) -> PhotosResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return FlickrAPI.photosFromJSONData(data: jsonData)
    }
    
    //MARK: - fetchImageForPhoto
    
    /// Downloads the image data from the webservice.
    func fetchImageForPhoto(flickrPhoto: Photo, size: ImageSize, completion: @escaping (ImageResult) -> Void) {
        
        let photoURL: URL
        
        switch size {
        case .thumbnail:
            if let image = flickrPhoto.image {
                completion(.success(image))
                return
            }
            // Download the small size image.
            photoURL = flickrPhoto.remoteThumbnailURL as URL
        case .regular:
            // Download the large size image.
            photoURL = flickrPhoto.remotePhotoURL as URL
        }
        
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error as NSError?)
            
            if case let .success(image) = result {
                flickrPhoto.image = image
            }
            completion(result)
        })
        task.resume()
    }
    
    //MARK: - processImageRequest
    
    /// Processes the data from the webservice into an image.
    func processImageRequest(data: Data?, error: NSError?) -> ImageResult {
        
        guard let
            imageData = data,
            let image = UIImage(data: imageData) else {
                
                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                }
                else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        return .success(image)
    }
}
