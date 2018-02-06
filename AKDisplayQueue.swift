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
    }
    
    deinit {
        self.displayLink.isPaused = true;
        displayLink.invalidate();
    }
    
    var tasks = [AkDisplayTask]()
    
    // Create a observer to monitor vSync by CADisplayLink
    lazy var displayLink =
        { ()->CADisplayLink in
            let ca = CADisplayLink.init(target: self, selector: #selector(fireTimer))
            ca.isPaused = true;
            ca.add(to: RunLoop.current, forMode: RunLoopMode.commonModes);
            return ca;
    }();
    
    @objc public func fireTimer() {
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
    }
    
    // Add a task to list
    func AddTask(holdingView:UIView, task:@escaping (() -> Swift.Void))
    {
        tasks.append(AkDisplayTask(task: task, displayId: holdingView.DisplayId!, holdingView: holdingView));
        
        // If vSync timer not running, run it
        if displayLink.isPaused {
            displayLink.isPaused = false;
        }
    }
}
