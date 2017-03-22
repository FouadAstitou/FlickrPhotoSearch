//
//  FlickrAPI.swift
//  FlickrPhotoSearch
//
//  Created by Supervisor on 22-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import Foundation

// Endpoint to hit on the Flickr Api.
enum Method: String {
    case search = "flickr.photos.search"
    case recentPhotos = "flickr.photos.getRecent"
}

// Checks if the result contains valid JSON data and an array of photos.
enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

// Error handeling.
enum FlickrError: Error {
    case invalidJSONData
}

struct FlickrAPI {
    fileprivate static let baseURLString = "https://api.flickr.com/services/rest"
    fileprivate static let APIKey = "a6d819499131071f158fd740860a5a88"
    
    fileprivate static func flickrURL(searchTerm: String?, method: Method, parameters: [String: String]?) -> URL {
        
        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": APIKey,
            "text": searchTerm ?? "",
            "per_page": "100",
            ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        print(components.url!)
        return components.url!
    }
    
    static func photosForURL(searchTerm: String?) -> URL {
        let method: Method
        if searchTerm != nil {
            method = .search
        } else {
            method = .recentPhotos
        }
        return flickrURL(searchTerm: searchTerm, method: method, parameters: ["extras": "url_q,url_h,date_taken"])
    }
    
    static func photosFromJSONData(data: Data) -> PhotosResult {
        
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let
                jsonDictionary = jsonObject as? [AnyHashable: Any],
                let photos = jsonDictionary["photos"] as? [String:AnyObject],
                let photosArray = photos["photo"] as? [[String:AnyObject]] else {
                    
                    // The JSON structure doesn't match our expectations
                    return .failure(FlickrError.invalidJSONData)
            }
            var finalPhotos = [Photo]()
            for photoJSON in photosArray {
                if let photo = photoFromJSONObject(json: photoJSON) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.count == 0 && photosArray.count > 0 {
                // We weren't able to parse any of the photos. Maybe the JSON format for photos has changed.
                return .failure(FlickrError.invalidJSONData)
            }
            return .success(finalPhotos)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    static func photoFromJSONObject(json: [String : AnyObject]) -> Photo? {
        guard let
            photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let thumbnailURLString = json["url_q"] as? String,
            let thumbnailURL = URL(string: thumbnailURLString),
            let photoURLString = json["url_h"] as? String,
            let photoURL = URL(string: photoURLString)
            
            else {
                
                // If we don't have enough information to construct a Photo.
                return nil
        }
        return Photo(photoID: photoID, title: title, remoteThumbnailURL: thumbnailURL, remotePhotoURL: photoURL)
    }
}
