//
//  Photo.swift
//  FlickrPhotoSearch
//
//  Created by Supervisor on 22-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import UIKit

class Photo {
    
    let photoID: String
    let title: String
    let remoteThumbnailURL: URL
    let remotePhotoURL: URL
    var image: UIImage?
    
    init(photoID: String, title: String, remoteThumbnailURL: URL, remotePhotoURL: URL) {
        self.photoID = photoID
        self.title = title
        self.remotePhotoURL = remotePhotoURL
        self.remoteThumbnailURL = remoteThumbnailURL
    }
}
