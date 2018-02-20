//
//  sViewController.swift
//  test1
//
//  Created by AaronZhang on 2018/2/9.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit

class sViewController: UIViewController,CAAnimationDelegate {

    let car = CALayer.init()
    let wheel1 = CALayer.init()
    var wheel2 = CALayer.init()
    let cnt = CALayer.init()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cnt.bounds = CGRect.init(x: 0, y: 0, width: 300, height: 150)
        cnt.position = CGPoint.init(x: -300, y: view.frame.height - 150)
        
        car.frame = CGRect.init(x: 0, y: 0, width: 300, height: 150)
        let img = UIImage.init(named: "car.png")
        car.contents = img?.cgImage
        car.contentsGravity = kCAGravityResizeAspect
        cnt.addSublayer(car)
        
        wheel1.bounds = CGRect.init(x: 0, y: 0, width: 38, height: 38)
        wheel1.position = CGPoint.init(x: 80, y: 101)
        wheel1.contents = UIImage.init(named: "wheel")?.cgImage
        wheel1.contentsGravity = kCAGravityResizeAspect
        cnt.addSublayer(wheel1)
        
        wheel2.bounds = CGRect.init(x: 0, y: 0, width: 38, height: 38)
        wheel2.contents = UIImage.init(named: "wheel")?.cgImage
        wheel2.contentsGravity = kCAGravityResizeAspect
        wheel2.position = CGPoint.init(x: 228, y: 101)
        cnt.addSublayer(wheel2)
        
        view.layer.addSublayer(cnt)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cnt.position = CGPoint.init(x: -300, y: view.frame.height - 150)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var theAnimation = CABasicAnimation.init(keyPath: "transform.rotation");
        theAnimation.beginTime = 0;
        theAnimation.fromValue = 0;
        theAnimation.toValue = 4 * Double.pi;
        theAnimation.duration = 2;
        theAnimation.fillMode = kCAFillModeForwards;
        theAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        theAnimation.repeatCount = 1
        //theAnimation.delegate = self
        
        wheel1.add(theAnimation, forKey: nil)
        wheel2.add(theAnimation, forKey: nil)
        
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(2)
        cnt.position.x = view.frame.midX
        CATransaction.commit()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
