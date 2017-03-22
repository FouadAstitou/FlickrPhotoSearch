//
//  PhotoDataSource.swift
//  FlickrPhotoSearch
//
//  Created by Supervisor on 22-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject {
    
    // Check if i have to remove the instances and make them optional?
    var flickrPhotos = [Photo]()
    //var photoStore = PhotoStore()
}

extension PhotoDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.identifier, for: indexPath) as! PhotoCollectionCell
        
        let photo = flickrPhotos[indexPath.item]
        cell.updateWithImage(image: photo.image)
        cell.backgroundColor = .white
        
        return cell
    }
}
