//
//  TestAsyncView.swift
//  test1
//
//  Created by AaronZhang on 2018/2/13.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit

class TestAsyncView: AKAsyncView {

    var imgList = [UIImageView]()
    public override func setupViewItems() {
        NSLog("setup cell")
        translatesAutoresizingMaskIntoConstraints = false
        layer.shouldRasterize = true;
        for i in 0 ... 100
        {
            let imgV = UIImageView()
            imgV.frame = CGRect.init(x: 10*i, y: 10, width: 64, height: 64)
            imgV.layer.cornerRadius = 20;
            //            let mask = CAShapeLayer.init();
            //            mask.fillColor = nil
            //            mask.lineWidth = 10
            //            mask.lineCap = kCALineCapButt;
            //            mask.strokeColor = UIColor.red.cgColor;
            //            mask.path = CGPath.init(roundedRect: imgV.bounds, cornerWidth: 20, cornerHeight: 20, transform: nil)
            //            imgV.layer.addSublayer(mask)
            imgV.layer.masksToBounds = true;
            addSubview(imgV)
            imgList.append(imgV);
        }
        
        //        let text = AkLabel.init(frame: CGRect(x: 20, y: 20, width: 300, height: 100))
        //        text.numberOfLines = 5;
        //        text.text = "😃😇😍😜😸🙈🐺🐰👽🐉💰🏡🎅🍪🍕🚀🚻💩📷📦😃😇😍😜😸🙈🐺🐰👽🐉💰🏡🎅🍪🍕🚀🚻💩📷📦😃😇😍😜😸🙈🐺🐰👽🐉💰🏡🎅🍪🍕🚀🚻💩📷📦😃😇😍😜😸🙈🐺🐰👽🐉💰🏡🎅🍪🍕🚀🚻💩📷📦😃😇😍😜😸🙈🐺🐰👽🐉💰🏡🎅🍪🍕🚀🚻💩📷📦😃😇";
        //        addSubview(text)
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)));
        //        tap.numberOfTapsRequired = 1;
        //        self.addGestureRecognizer(tap);
        
        // Create, add and layout the children views ..
        //layer.affineTransform().rotated(by: 0.5)
    }
}
