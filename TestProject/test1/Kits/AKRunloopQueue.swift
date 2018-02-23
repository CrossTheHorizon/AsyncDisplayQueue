//
//  AKDisplayQueue.swift
//  test1
//
//  Created by AaronZhang on 2018/2/5.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit

class AKRunloopQueue: AkAsyncQueue {
    
    static var shared = { () -> AKRunloopQueue in  let inst = AKRunloopQueue(); return inst;}();

    var runLoopObserver:CFRunLoopObserver!
    private override init() {
        super.init()
        runLoopObserver = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, true, 300000) { (observer, activity) in
            if self.tasks.count == 0 {
                return;
            }
            
            self.ProcessTask();
           
            if self.tasks.count != 0 {
                CFRunLoopWakeUp(CFRunLoopGetMain())
            }
        }

        CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, CFRunLoopMode.commonModes)
    }
    
    deinit {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), runLoopObserver, CFRunLoopMode.commonModes)
    }

}
