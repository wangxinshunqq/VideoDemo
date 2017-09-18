//
//  ViewController.swift
//  MaskDemo
//
//  Created by wangxs on 2017/9/14.
//  Copyright © 2017年 xhey. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func capture(_ sender: Any) {
        print("capture")
    }
    
    
    @IBAction func edit(_ sender: Any) {
        
        let screenWidth = UIScreen.main.bounds.size.width
        
        let layoutMy = UICollectionViewFlowLayout()
        
        layoutMy.itemSize = CGSize(width:(screenWidth-20)*0.25,height:(screenWidth-20)*0.25)
        layoutMy.scrollDirection = .vertical
        layoutMy.minimumLineSpacing = 4;
        layoutMy.minimumInteritemSpacing = 4;
        layoutMy.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4)
        
        let photosViewController = XHPhotosCollectionViewController.init(collectionViewLayout: layoutMy)
        
        let viewControllerDemo = UINavigationController(rootViewController: photosViewController)
        
        self.present(viewControllerDemo, animated: true, completion: nil)
    }
    
    
}

