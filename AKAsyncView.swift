//
//  AKAsyncView.swift
//  test1
//
//  Created by AaronZhang on 2018/2/5.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit

class AKAsyncView: UIView {

    // #1
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewItems()
    }
    
    // #2
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewItems()
    }

    public func setupViewItems() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    func prepareRender()
    {
        displayQueue.cancelAllOperations()
        displayId = -1;
    }
    
    var displayId:Int = 0;
    let displayQueue:OperationQueue = { let queue = OperationQueue.init();
        queue.maxConcurrentOperationCount = 1;
        return queue;
    }()
    
    func render(_ curdisplayId:Int, task:@escaping ()->Void) {
        self.displayId = curdisplayId
        if RunLoop.current.currentMode == RunLoopMode.defaultRunLoopMode
        {
            task()
            return;
        }
        
        let size = CGSize.init(width: self.bounds.size.width, height: self.bounds.size.height);
        displayQueue.addOperation({
            if self.displayId != curdisplayId
            {
                return;
            }
            
            UIGraphicsBeginImageContext(size)
            guard let context = UIGraphicsGetCurrentContext() else {
                // cannot create context - handle error
                return;
            }
            
            let flipVertical:CGAffineTransform = CGAffineTransform.init(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(size.height))
            context.ctm.concatenating(flipVertical)
            task()
            self.layer.render(in: context);
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async {
                if self.displayId != curdisplayId
                {
                    return;
                }
                let cgi = image?.cgImage
                self.layer.contents = cgi;
                self.layer.contentsGravity = kCAGravityTopLeft
                self.layer.contentsScale = image!.scale
                self.setNeedsDisplay()
            }
        })
    }
}
