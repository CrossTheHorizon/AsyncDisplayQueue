//
//  AKDisplayQueue.swift
//  test1
//
//  Created by cn-diss-mac1 on 2018/2/5.
//  Copyright © 2018年 Kodak Alaris. All rights reserved.
//

import UIKit
extension UIView
{
    private struct AssociatedKeys {
        static var DisplayId = 0
        static var DisplayState = 0
    }
    
    var DisplayId: UInt?{
        get {
            var value = objc_getAssociatedObject(self, &AssociatedKeys.DisplayId) as? UInt
            if value == nil {
                value = 0;
                objc_setAssociatedObject(self, &AssociatedKeys.DisplayId, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
            return value;
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.DisplayId, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
}

struct AkDisplayTask {
    var task:(() -> Swift.Void)?;
    var displayId:UInt = 0;
    var holdingView:UIView;
}

class AKDisplayQueue: NSObject {
    static var shared = { () -> AKDisplayQueue in  let inst = AKDisplayQueue(); return inst;}();

    private override init() {
        super.init()
        let runLoopObserver = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, true, 300000) { (observer, activity) in
            while self.tasks.count != 0 {
                let taskItem = self.tasks.removeFirst()

                // Determine whether this task is abandon
                if taskItem.displayId == taskItem.holdingView.DisplayId!
                {
                    NSLog("Run task: %d", taskItem.displayId);
                    taskItem.task!();
                    break;
                }
            }
            if self.tasks.count == 0
            {
                self.displayLink.isPaused = true;
                NSLog("No more tasks");
            }
            else{
                CFRunLoopWakeUp(CFRunLoopGetMain())
            }
        }

        CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, CFRunLoopMode.commonModes)
    }
    
    
    deinit {
        self.displayLink.isPaused = true;
        displayLink.invalidate();
    }
    
    var tasks = [AkDisplayTask]()
    
    
    // Add a task to list
    func AddTask(holdingView:UIView, task:@escaping (() -> Swift.Void))
    {
        tasks.append(AkDisplayTask(task: task, displayId: holdingView.DisplayId!, holdingView: holdingView));
    }
}
