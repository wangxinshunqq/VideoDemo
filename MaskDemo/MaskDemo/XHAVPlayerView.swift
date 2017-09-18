//
//  XHAVPlayerView.swift
//  MaskDemo
//
//  Created by wangxs on 2017/9/15.
//  Copyright © 2017年 xhey. All rights reserved.
//

import UIKit
import AVFoundation

class XHAVPlayerView: UIView {
    
    override class var layerClass:AnyClass{
        return AVPlayerLayer.self
    }
    
}
