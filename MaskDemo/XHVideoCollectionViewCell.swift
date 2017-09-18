//
//  XHVideoCollectionViewCell.swift
//  MaskDemo
//
//  Created by wangxs on 2017/9/14.
//  Copyright © 2017年 xhey. All rights reserved.
//

import UIKit
import Photos

class XHVideoCollectionViewCell: UICollectionViewCell {
    var thumbView : UIImageView?
    var durationLabel : UILabel?
    var cellAsset : PHAsset?
    var thumbSize = CGSize()
    
    func createSubView(){
        
        //create thumbView
        if(thumbView == nil){
            
            thumbView = UIImageView(frame: self.contentView.bounds)
            thumbView?.clipsToBounds = true
            thumbView?.contentMode = .scaleAspectFill
            thumbView?.isUserInteractionEnabled = true
            thumbView?.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
            self.contentView.addSubview(thumbView!)
            
            let cellSize = thumbView!.bounds.size
            self.thumbSize = CGSize(width:cellSize.width * UIScreen.main.scale, height: cellSize.width * UIScreen.main.scale)
        }
        //create label
        if(durationLabel == nil){
            let cellSize = self.contentView.bounds.size
            let durationFrame = CGRect(x: 2, y: cellSize.height - 16, width: cellSize.width-4, height: 14)
            durationLabel = UILabel(frame: durationFrame)
            durationLabel?.backgroundColor = UIColor.init(white: 0.0, alpha: 0.5)
            durationLabel?.font = UIFont.systemFont(ofSize: 12)
            durationLabel?.textColor = UIColor.white
            durationLabel?.textAlignment = .right
            durationLabel?.text = "00:00"
            durationLabel?.sizeToFit()
            thumbView?.addSubview(durationLabel!)
        }
    }
    
    func resentAsset(asset : PHAsset){
        
        if(self.cellAsset===asset){
            return
        }
        self.cellAsset = asset
        self.createSubView()
        
        //duration
        let duration : UInt = UInt(asset.duration)
        self.durationLabel?.text = String.init(format: "%02d:%02d", duration/60,duration%60)
        
        //thumbImage
        PHImageManager.default().requestImage(for: self.cellAsset!, targetSize: self.thumbSize, contentMode: .aspectFill, options: nil) { image, _ in
            DispatchQueue.main.async {
                self.thumbView?.image = image
            }
        }
    }
}
