//
//  PhotosCollectionViewController.swift
//  MaskDemo
//
//  Created by wangxs on 2017/9/14.
//  Copyright © 2017年 xhey. All rights reserved.
//

import UIKit
import Photos
import AVKit


private let reuseIdentifier = "XheyCell"

class XHPhotosCollectionViewController: UICollectionViewController {

    var fetchVideos : PHFetchResult<PHAsset>!
    var thumbSize = CGSize()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        self.collectionView?.backgroundColor = UIColor.darkGray
        self.createNavgitionItem()
        
        let screenSize = UIScreen.main.bounds.size
        thumbSize = CGSize(width: screenSize.width*0.5, height: screenSize.width*0.5)
        
        self.createVideoData()
        self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(XHVideoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
    
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchVideos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? XHVideoCollectionViewCell
        
        cell?.resentAsset(asset: self.fetchVideos.object(at: indexPath.item))
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoAsset = fetchVideos.object(at: indexPath.item)
        
        PHImageManager.default().requestAVAsset(forVideo: videoAsset, options:nil,resultHandler: {asset, _, _ in
            /*let play = AVPlayer(playerItem: AVPlayerItem(asset: asset!))
            let playViewController = AVPlayerViewController()
            playViewController.player = play
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(playViewController, animated: true)
            }*/
            let cutViewController = XHEditViewController()
            cutViewController.assetVideo = asset
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(cutViewController, animated: true)
            }
        })
    }
    
    //navigation
    func createNavgitionItem(){
        self.title = "视频"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.done, target: self, action: #selector(returnBack))
    }
    
    @objc func returnBack(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //dealData
    func createVideoData(){
        
        PHPhotoLibrary.shared().register(self)
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        fetchVideos = PHAsset.fetchAssets(with: .video, options: fetchOption)
        
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

extension XHPhotosCollectionViewController : PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print(changeInstance)
    }
}
