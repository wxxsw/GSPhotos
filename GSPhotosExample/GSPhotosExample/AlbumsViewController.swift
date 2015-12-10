//
//  AlbumsViewController.swift
//  GSPhotosExample
//
//  Created by Gesen on 15/11/9.
//  Copyright © 2015年 Gesen. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class AlbumsViewController: UITableViewController {

    var albums: [GSAlbum] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GSPhotoLibrary.sharedInstance.fetchAlbums { albums, error in
            if let albums = albums where error == nil {
                self.albums = albums
                self.tableView.reloadData()
            } else {
                print(GSPhotoLibrary.authorizationStatus())
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AlbumCell
        
        let album = albums[indexPath.row]
        cell.titleLabel.text = "\(album.name)（\(album.count)）"
        cell.posterView.setImageWithAlbum(album)

        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let assetsVC = segue.destinationViewController as? AssetsViewController else { return }
        
        if segue.identifier == "showAlbum" {

            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let album = albums[indexPath.row]
            
            assetsVC.title = album.name
            assetsVC.album = album
            
        } else if segue.identifier == "showAll" {
            
            assetsVC.title = "All Assets"
            
        }
    }

}
