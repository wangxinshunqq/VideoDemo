//
//  XHEditViewController.swift
//  MaskDemo
//
//  Created by wangxs on 2017/9/14.
//  Copyright © 2017年 xhey. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import Photos

class XHEditViewController: UIViewController ,XHCutSliderProtocol{

    var assetVideo : AVAsset?
    var playViewBackground : UIView?
    var playView : XHAVPlayerView?
    var playerAVPlayer : AVPlayer?
    var playButton : UIButton?
    var playSlider : UISlider?
    var playCutSlider : XHPlayerCutSlider?
    var progressView : XHProgressView?
    
    var timeObserverObjc:Any?
    //edit
    var mComposition : AVMutableComposition?
    var mVideoComposition : AVMutableVideoComposition?
    var mAudioMix : AVMutableAudioMix?
    var mAnimateTool : AVVideoCompositionCoreAnimationTool?
    
    
    //export
    var videoExport: AVAssetExportSession?
    var progressTimer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.isTranslucent = false;
        self.createNavgitionItem()
        self.createSubView()
        self.addObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //navigation
    func createNavgitionItem(){
        self.title = "编辑"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.done, target: self, action: #selector(returnBack))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "输出", style:.done, target: self, action: #selector(cutSure))
    }
    
    @objc func returnBack(){
        self.pauseFunc()
        self.deleteObserver()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func cutSure(){
        print("BeginExport")
        let outPutDir = NSTemporaryDirectory()
        let outPath = outPutDir + "xHey.mov"
        print(outPath)
        self.showProgress()
        self.exportVideo(self.assetVideo!)
        
    }
    
    //createSubView
    func createSubView(){
        
        let screenSize = UIScreen.main.bounds.size
        
        //playViewBackground
        if(playViewBackground == nil){
            self.playViewBackground = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.width))
            self.playViewBackground?.backgroundColor = UIColor.black
            self.view.addSubview(self.playViewBackground!)
            //点击事件
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pauseFunc))
            tapGesture.numberOfTapsRequired = 1
            self.playViewBackground?.addGestureRecognizer(tapGesture)
        }
        //playView
        if(playView == nil){
            createPlayerView()
        }
        //playButtion
        if(playButton == nil){
            self.playButton = UIButton(type: .system)
            self.playButton?.setTitle("播放", for: .normal)
            self.playButton?.addTarget(self, action: #selector(playFunc), for: UIControlEvents.touchUpInside)
            self.playButton?.backgroundColor = UIColor.darkGray
            self.playButton?.frame = CGRect(x: screenSize.width*0.5-20, y: screenSize.width*0.5-15, width: 40, height: 30)
            self.playViewBackground?.addSubview(self.playButton!)
        }
        //playSlider
        if(self.playSlider == nil){
            self.playSlider = UISlider(frame: CGRect(x: 2, y: screenSize.width+4, width: screenSize.width-4, height: 30))
            self.playSlider?.minimumValue = 0.0
            self.playSlider?.maximumValue = Float(CMTimeGetSeconds((self.assetVideo?.duration)!))
            self.view.addSubview(self.playSlider!)
            self.playSlider?.value = 0.0
            self.playSlider?.addTarget(self, action: #selector(playSliderValueChange), for: UIControlEvents.valueChanged)
        }
        //cutSlider
        if(self.playCutSlider == nil){
            let heightUsed = self.playSlider?.frame.maxY
            let heightRetain = screenSize.height-64-heightUsed!
            self.playCutSlider = XHPlayerCutSlider(frame: CGRect(x: 0, y: heightUsed!+heightRetain*0.25, width: screenSize.width, height: heightRetain*0.5))
            self.playCutSlider?.backgroundColor = UIColor.green
            self.view.addSubview(self.playCutSlider!)
            self.playCutSlider?.cutDelegate = self
            //minMax
            self.playCutSlider?.setMinAndMaxValue(0.0, CMTimeGetSeconds((self.assetVideo?.duration)!) )
            
            self.playCutSlider?.setLeftValue(0.0)
            self.playCutSlider?.setRightValue(CMTimeGetSeconds((self.assetVideo?.duration)!))
            self.playCutSlider?.displayCutSlider()
            
        }
        
        self.playFunc()
    }
    
    func createPlayerView(){
        
        if(self.playView != nil){
            return
        }
        
        let playViewBackSize = self.playViewBackground?.bounds.size
        
        let trackVideo = self.assetVideo?.tracks(withMediaType: .video).last
        let videoSize = (trackVideo?.naturalSize)!
    
        let videoTransform = trackVideo?.preferredTransform
        
        var playViewWidth = playViewBackSize?.width
        var playViewHeight = videoSize.height/videoSize.width * playViewWidth!
        
        if(videoTransform?.a == 0.0){
            playViewHeight = (playViewBackSize?.width)!
            playViewWidth = videoSize.height/videoSize.width * playViewHeight
        }
        if(videoSize.height>videoSize.width){
            playViewHeight = (playViewBackSize?.width)!
            playViewWidth = videoSize.width/videoSize.height * playViewHeight
        }
        
        let playViewFrame = CGRect(x: ((playViewBackSize?.width)!-playViewWidth!)*0.5, y: ((playViewBackSize?.height)! - playViewHeight)*0.5, width: playViewWidth!, height: playViewHeight)
        
        self.playView = XHAVPlayerView(frame: playViewFrame)
        self.playView?.backgroundColor = UIColor.clear
        self.playViewBackground?.addSubview(self.playView!)
        
        //设置播放
        self.playerAVPlayer = AVPlayer(playerItem: AVPlayerItem.init(asset: self.assetVideo!))
        let playerLayer:AVPlayerLayer = self.playView?.layer as! AVPlayerLayer
        
        playerLayer.player = self.playerAVPlayer
        
    }
    
    func addObserver(){
        let intervalTime = CMTimeMake(1, 10)
        self.timeObserverObjc = self.playerAVPlayer?.addPeriodicTimeObserver(forInterval: intervalTime, queue: DispatchQueue.main, using: { [unowned self] time in
            if((self.playerAVPlayer?.rate)! > 0.0){
                self.playSlider?.value = Float(CMTimeGetSeconds(time))
            }
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(playToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerAVPlayer?.currentItem)
    }
    
    func deleteObserver(){
        
        if(self.timeObserverObjc != nil){
            self.playerAVPlayer?.removeTimeObserver(self.timeObserverObjc as Any)
            self.timeObserverObjc = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerAVPlayer?.currentItem)
    }
    
    @objc func playFunc(){
        self.playerAVPlayer?.play()
        self.playButton?.isHidden = true
    }
    @objc func pauseFunc(){
        self.playerAVPlayer?.pause()
        self.playButton?.isHidden = false
    }
    @objc func playSliderValueChange(){
        self.pauseFunc()
        let currentTime = CMTime(seconds: Double((self.playSlider?.value)!), preferredTimescale: (self.assetVideo?.duration.timescale)!);
        
       self.playerAVPlayer?.seek(to: currentTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    @objc func playToEnd(){
        
        self.pauseFunc()
        self.playerAVPlayer?.seek(to: kCMTimeZero, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
        self.playSlider?.value = (self.playSlider?.minimumValue)!
    }
    //mark
    func leftThumbChanged(_ left: Float64) {
        self.pauseFunc()
        let currentTime = CMTime.init(seconds: left, preferredTimescale: 600)
        self.playerAVPlayer?.seek(to: currentTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func rightThumbChanged(_ right: Float64) {
        self.pauseFunc()
        let currentTime = CMTime.init(seconds: right, preferredTimescale: 600)
        self.playerAVPlayer?.seek(to: currentTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func showProgress(){
        self.progressView = XHProgressView.init(frame: UIScreen.main.bounds)
        self.progressView?.backgroundColor = UIColor.init(white: 0.2, alpha:0.8)
        self.progressView?.alpha = 0.0
        UIApplication.shared.keyWindow?.addSubview(self.progressView!)
        UIView.animate(withDuration: 0.5, animations: {
            [weak self] in
            self?.progressView?.alpha = 1.0
        })
        
        self.perform(#selector(disappearProgress), with: nil, afterDelay: 3)
    }
    @objc func disappearProgress(){
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                [weak self] in
                self?.progressView?.alpha = 0.0
            }) { [weak self](_ anim:Bool) in
                self?.progressView?.removeFromSuperview()
                self?.progressView = nil
            }
        }
        
    }
    
    func createMutableComposition(){
        self.mComposition = AVMutableComposition.init() 
        
        let mVideoTrack = self.mComposition?.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let assetVideoTrack = self.assetVideo?.tracks(withMediaType: .video).last
        
        let beginTime = CMTime.init(seconds: (self.playCutSlider?.getLeftCutTime())!, preferredTimescale: 600)
        let endTime = CMTime.init(seconds: (self.playCutSlider?.getRightCutTime())!, preferredTimescale: 600)
        let timeRange : CMTimeRange = CMTimeRange.init(start: beginTime, end: endTime)
        
        //video
        //mVideoTrack?.preferredTransform = (assetVideoTrack?.preferredTransform)!
        
        do{
            try mVideoTrack?.insertTimeRange(timeRange, of: assetVideoTrack!, at: kCMTimeZero)
        }catch{
            print("insert Video Error")
        }
        
        //audio
        let mAudioTrack = self.mComposition?.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let assetAudioTrack = self.assetVideo?.tracks(withMediaType: .audio).first
        
        do{
            try mAudioTrack?.insertTimeRange(timeRange, of: assetAudioTrack!, at: kCMTimeZero)
        }catch{
            print("insert Audio Error")
        }
        
        //video
        let videoCompositionInstruction = AVMutableVideoCompositionInstruction.init()
        videoCompositionInstruction.timeRange = CMTimeRange.init(start: kCMTimeZero, duration: CMTimeSubtract(endTime, beginTime))
        
        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: mVideoTrack!)
        videoLayerInstruction.setTransform((assetVideoTrack?.preferredTransform)!, at: kCMTimeZero)
        videoCompositionInstruction.layerInstructions = [videoLayerInstruction]
        
        self.mVideoComposition = AVMutableVideoComposition.init()
        
        self.mVideoComposition?.instructions = [videoCompositionInstruction]
        self.mVideoComposition?.renderSize = (assetVideoTrack?.naturalSize)!
        if(assetVideoTrack?.preferredTransform.a == 0.0){
            self.mVideoComposition?.renderSize = CGSize.init(width: Double((assetVideoTrack?.naturalSize.height)!), height:  Double((assetVideoTrack?.naturalSize.width)!))
        }
        //self.mVideoComposition?.renderSize = CGSize.init(width: 1080, height: 1920)
        self.mVideoComposition?.frameDuration = CMTime.init(seconds: Double(1.0/(assetVideoTrack?.nominalFrameRate)!), preferredTimescale: 600)
        
        //audio
        self.mAudioMix = AVMutableAudioMix.init()
        let mixParameters = AVMutableAudioMixInputParameters.init(track: mAudioTrack)
        mixParameters.setVolumeRamp(fromStartVolume: 1.0, toEndVolume: 1.0, timeRange: videoCompositionInstruction.timeRange)
        self.mAudioMix?.inputParameters = [mixParameters]
        
        //animationTool
        let parentLayer = CALayer.init()
        let videoWidth = (self.mVideoComposition?.renderSize.width)!
        let videoHeight = (self.mVideoComposition?.renderSize.height)!
        parentLayer.frame = CGRect(x: 0, y: 0, width: videoWidth, height: videoHeight)
        
        let videoLayer = CALayer.init()
        videoLayer.frame = CGRect(x: 0, y: 0, width: videoWidth, height: videoHeight)
        parentLayer.addSublayer(videoLayer)
        
        //mask
        let textLayer = CATextLayer.init()
        let minEdge = Float64.minimum(Float64(videoHeight), Float64(videoWidth))
        let fontHeight = minEdge * 0.1
        textLayer.string = "小嘿科技"
        textLayer.fontSize = CGFloat(fontHeight)
        textLayer.frame = CGRect(x: 0.0, y: Float64(videoHeight)*0.5 - fontHeight*0.7, width: Float64(videoWidth), height: fontHeight*1.4)
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.foregroundColor = UIColor.darkGray.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = kCAAlignmentCenter
        parentLayer.addSublayer(textLayer)
    
        self.mAnimateTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
    }
    
    func exportVideo(_ asset:AVAsset){
        self.createMutableComposition()
        self.videoExport = AVAssetExportSession.init(asset: self.mComposition!, presetName: AVAssetExportPresetHighestQuality)
        
        let outPutDir = NSTemporaryDirectory()
        let outPath = outPutDir + "xHey.mov"
        
        if(FileManager.default.fileExists(atPath: outPutDir)){
            do{
                try FileManager.default.removeItem(atPath: outPath)
            }catch{
                print("delete error")
            }
        }
        
        self.videoExport?.outputURL = NSURL.init(fileURLWithPath: outPath) as URL
        self.videoExport?.outputFileType = AVFileType.mov
        self.videoExport?.shouldOptimizeForNetworkUse = true
        self.videoExport?.audioMix = self.mAudioMix
        self.mVideoComposition?.animationTool = self.mAnimateTool
        self.videoExport?.videoComposition = self.mVideoComposition
        
        self.videoExport?.exportAsynchronously(completionHandler: {
            if(self.videoExport?.status == AVAssetExportSessionStatus.completed){
                self.progressTimer?.invalidate()
                print("success")
                self.saveVideoToPhoto("123")
                self.disappearProgress()
            }
        })
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgress(){
        if((self.videoExport?.progress)! > 0.99){
            self.progressTimer?.invalidate()
        }
        self.progressView?.setProgress((self.videoExport?.progress)!)
    }
    
    func saveVideoToPhoto(_ path:String){
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: (self.videoExport?.outputURL)!)
        }) { (isSuccess:Bool, error:Error?) in
            if(isSuccess){
                print("success save")
            }else{
                print("error")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.playerAVPlayer?.pause()
    }
    
    deinit {
        if(self.playerAVPlayer != nil){
            self.playerAVPlayer?.replaceCurrentItem(with: nil) ;
        }
    }
    
}
