//
//  PhotoDataSource.swift
//  FlickrPhotoSearch
//
//  Created by Supervisor on 22-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject {
    
    var flickrPhotos = [Photo]()
}

//MARK: - data source methods.
extension PhotoDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.identifier, for: indexPath) as! PhotoCollectionCell
        
        let photo = flickrPhotos[indexPath.item]
        cell.updateWithImage(image: photo.image, size: .regular)
        
        return cell
    }
}
