//
//  XHProgressView.swift
//  MaskDemo
//
//  Created by wangxs on 2017/9/16.
//  Copyright © 2017年 xhey. All rights reserved.
//

import UIKit

class XHProgressView: UIView {
    
    var progressView : UIProgressView?
    
    func setProgress(_ progress:Float){
        if(self.progressView == nil){
            let screenSize = UIScreen.main.bounds.size
            
            self.progressView = UIProgressView.init(frame: CGRect(x: 30, y: screenSize.height*0.3, width: screenSize.width-60, height: 20))
            self.addSubview(self.progressView!)
        }
        self.progressView?.progress = progress
    }

}
