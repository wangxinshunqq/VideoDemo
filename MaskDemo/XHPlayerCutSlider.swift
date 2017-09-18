//
//  XHPlayerCutSlider.swift
//  MaskDemo
//
//  Created by wangxs on 2017/9/15.
//  Copyright © 2017年 xhey. All rights reserved.
//

import UIKit
import AVFoundation

protocol XHCutSliderProtocol:class {
    func leftThumbChanged(_ left:Float64)
    func rightThumbChanged(_ right:Float64)
}

class XHPlayerCutSlider: UIView {
    
    var leftThumb : UIImageView?
    var rightThumb : UIImageView?
    var sliderBody : UIImageView?
    var thumbWidth = 30.0
    var videoAsset : AVAsset?
    
    var minValue :Float64 = 0.0
    var maxValue :Float64 = 1.0
    var leftValue:Float64 = 0.0
    var rightValue:Float64 = 0.0
    
    var beginPanX: Float64?
    var beginThumbX:Float64?
    
    weak var cutDelegate : XHCutSliderProtocol?
    //设置Slider表示的范围
    func setMinAndMaxValue(_ min:Float64,_ max:Float64){
        self.minValue = min
        self.maxValue = Float64.maximum(min, max)
    }
    //设置左值
    func setLeftValue(_ left:Float64){
        self.leftValue = Float64.maximum(self.minValue, left)
        
    }
    //设置右边的值
    func setRightValue(_ right:Float64){
        self.rightValue = Float64.minimum(self.maxValue, right)
        
    }
    
    //调用此函数显示完整View在确定View的位置大小后调用
    func displayCutSlider(){
        self.createSubView()
    }
    
    //outPutCutTime
    func getLeftCutTime()-> Float64{
        let leftFrame = self.leftThumb?.frame
        let value = self.getValueFromUIValue(Float64((leftFrame?.maxX)!))
        return value
    }
    func getRightCutTime() -> Float64 {
        let rightFrame = self.rightThumb?.frame
        let value = self.getValueFromUIValue(Float64((rightFrame?.minX)!))
        return value
    }
    
    func createSubView(){
        self.backgroundColor = UIColor.clear
        let sliderSize = self.bounds.size
        
        //createSliderBody
        self.sliderBody = UIImageView.init(frame: CGRect(x: self.thumbWidth, y: 0.0, width: Double(sliderSize.width) - self.thumbWidth*2, height: Double(sliderSize.height)))
        //self.sliderBody?.layer.borderColor = UIColor.red.cgColor
        //self.sliderBody?.layer.borderWidth = 2.0
        self.sliderBody?.isUserInteractionEnabled = true
        self.sliderBody?.contentMode = .scaleAspectFill
        self.sliderBody?.image = UIImage.init(named: "thumb")
        self.sliderBody?.clipsToBounds = true
        self.addSubview(self.sliderBody!)
        
        //createLeftThumb
        let leftValueUI = self.getUIValueFromValue(self.leftValue)
        self.leftThumb = UIImageView.init(frame: CGRect(x: leftValueUI-self.thumbWidth, y: 0.0, width: self.thumbWidth, height: Double(sliderSize.height)))
        self.leftThumb?.image = UIImage.init(named: "thumb")
        self.leftThumb?.isUserInteractionEnabled = true
        self.leftThumb?.clipsToBounds = true
        //pan
        let leftPanGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerLeft(_:)))
        self.leftThumb?.addGestureRecognizer(leftPanGesture)
        
        self.addSubview(self.leftThumb!)
        
        //createRightThumb
        let rightValueUI = self.getUIValueFromValue(self.rightValue)
        self.rightThumb = UIImageView.init(frame: CGRect(x: rightValueUI, y: 0.0, width: self.thumbWidth, height: Double(sliderSize.height)))
        self.rightThumb?.image = UIImage.init(named: "thumb")
        self.rightThumb?.isUserInteractionEnabled = true
        self.rightThumb?.clipsToBounds = true
        //pan
        let rightPanGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerRight(_:)))
        self.rightThumb?.addGestureRecognizer(rightPanGesture)
        self.addSubview(self.rightThumb!)
        
        
    }
    
    @objc func panGestureRecognizerLeft(_ recognizer :UIPanGestureRecognizer){
        switch (recognizer.state) {
        case .began:
            self.beginPanX = Float64(recognizer.translation(in: self).x)
            self.beginThumbX = Float64((self.leftThumb?.frame.minX)!)
        case .changed:
            let changeX : Float64 = Float64(recognizer.translation(in: self).x)
            let changeThumbX = self.beginThumbX! + (changeX - self.beginPanX!)
            self.changeLeftThumb(changeThumbX)
        case .ended:
            print("end left")
        case .cancelled:
            print("cancel left")
        default:
            print("default left")
        }
    }
    
    @objc func panGestureRecognizerRight(_ recognizer :UIPanGestureRecognizer){
        
        switch (recognizer.state) {
        case .began:
            self.beginPanX = Float64(recognizer.translation(in: self).x)
            self.beginThumbX = Float64((self.rightThumb?.frame.minX)!)
            
        case .changed:
            let changeX : Float64 = Float64(recognizer.translation(in: self).x)
            let changeThumbX = self.beginThumbX! + (changeX - self.beginPanX!)
            self.changeRightThumb(changeThumbX)
        case .ended:
            print("end Right")
        case .cancelled:
            print("cancel Right")
        default:
            print("default Right")
        }
    }
    
    func changeLeftThumb(_ leftX:Float64){
        var leftThumbX = leftX ;
        if(leftThumbX < 0){
            leftThumbX = 0
        }
        let rightX :Float64 = Float64((self.rightThumb?.frame.minX)!)
        if(leftThumbX > (rightX-self.thumbWidth)){
            leftThumbX = (rightX-self.thumbWidth)
        }
        
        var leftFrame = self.leftThumb?.frame
        leftFrame?.origin.x = CGFloat(leftThumbX)
        self.leftThumb?.frame = leftFrame!
        if(self.cutDelegate != nil){
            let value = self.getValueFromUIValue(Float64((leftFrame?.maxX)!))
            self.cutDelegate?.leftThumbChanged(value)
        }

    }
    
    func changeRightThumb(_ rightX:Float64){
        var rightThumbX = rightX
        if(rightThumbX > Float64((self.sliderBody?.frame.maxX)!)){
            rightThumbX = Float64((self.sliderBody?.frame.maxX)!)
        }
        let leftX :Float64 = Float64((self.leftThumb?.frame.maxX)!)
        if(rightThumbX < leftX){
            rightThumbX = leftX
        }
        var rightFrame = self.rightThumb?.frame
        rightFrame?.origin.x = CGFloat(rightThumbX)
        self.rightThumb?.frame = rightFrame!
        
        if(self.cutDelegate != nil){
            let value = self.getValueFromUIValue(Float64((rightFrame?.minX)!))
            self.cutDelegate?.rightThumbChanged(value)
        }
    }
    
    
    func getValueFromUIValue(_ valueUI:Float64) -> Float64{
        
        var valueUITemp = valueUI
        let rangeValueUI : Float64 = Float64((self.sliderBody?.bounds.size.width)!)
        
        if(valueUITemp < self.thumbWidth){
            valueUITemp = self.thumbWidth
        }
        if(valueUITemp > self.thumbWidth + rangeValueUI){
            valueUITemp = self.thumbWidth + rangeValueUI
        }
        
        let valueReturn = (self.maxValue-self.minValue) * (valueUITemp - self.thumbWidth)/rangeValueUI
        
        return valueReturn + self.minValue
    }
    func getUIValueFromValue(_ value:Float64) -> Float64{
        
        var valueTemp : Float64 = value
        if(valueTemp < self.minValue){
            valueTemp = self.minValue
        }
        if(valueTemp > self.maxValue){
            valueTemp = self.maxValue
        }
        
        let rangeValueUI : Float64 = Float64((self.sliderBody?.bounds.size.width)!)
        let valueResult = rangeValueUI * (valueTemp-self.minValue) / (self.maxValue-self.minValue)
        return valueResult + self.thumbWidth
    }

}
