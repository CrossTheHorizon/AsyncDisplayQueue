//
//  AkFPSLayer.swift
//  test1
//
//  Created by AaronZhang on 2018/2/8.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit

class AkFPSLayer: CAShapeLayer {
    
    var ptLst = [Int]()
    var countFrames = 0;
    var countTime:Double = 0, pTime:Double = 0;

    override init() {
        super.init()
        lineWidth = 1
        lineCap = kCALineCapButt;
        strokeColor = UIColor.red.cgColor;
        fillColor = nil;
        self.frame = CGRect(x: 0, y: 80, width: UIScreen.main.bounds.size.width, height: 120)

        let size = UIScreen.main.bounds.size;
        AkDisplayQueue.shared.AddTask(repeateTime: -1) { task in
                let tTime = CACurrentMediaTime()
                self.countTime += (tTime - self.pTime);
                self.pTime = tTime;
                
                if self.countTime >= 0.5 {
                    self.ptLst.append(self.countFrames * 4)
                    if self.ptLst.count > 100
                    {
                        self.ptLst.removeFirst();
                    }
                    self.countFrames = 0;
                    self.countTime = 0;
                    let path1 = CGMutablePath()
                    path1.move(to: CGPoint(x: 0, y: 10))
                    path1.addLine(to: CGPoint(x: size.width, y: 10))
                    path1.move(to: CGPoint(x: 0, y: 120))
                    path1.addLine(to: CGPoint(x: size.width, y: 120))
                    path1.move(to: CGPoint.init(x: 0, y: 120-self.ptLst[0]))
                    for i in 0...self.ptLst.count-1
                    {
                        path1.addLine(to: CGPoint(x: i*3, y: 120-self.ptLst[i]))
                    }
                    self.path = path1
                }
                self.countFrames += 1;
            }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
