//
//  AkDisplayQueue.swift
//  test1
//
//  Created by cn-diss-mac1 on 2018/2/13.
//  Copyright © 2018年 Kodak Alaris. All rights reserved.
//

import UIKit

class AkDisplayQueue: AkAsyncQueue {
    
    //Create a observer to monitor vSync by CADisplayLink
    lazy var displayLink =
        { ()->CADisplayLink in
            let ca = CADisplayLink.init(target: self, selector: #selector(fireVSync))
            ca.isPaused = true;
            ca.add(to: RunLoop.current, forMode: RunLoopMode.commonModes);
            return ca;
    }();
    static var shared = { () -> AkDisplayQueue in  let inst = AkDisplayQueue(); return inst;}();
    
    @objc public func fireVSync() {
        if self.tasks.count == 0 {
            Stop()
        }
        
        self.ProcessTask();
        
        if self.tasks.count == 0 {
            Stop()
        }
    }
    
    deinit {
        displayLink.isPaused = true;
        displayLink.invalidate()
    }

    override func Start() {
        displayLink.isPaused = false;
    }
    
    override func Stop() {
        displayLink.isPaused = true;
    }
}
