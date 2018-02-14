//
//  ViewControllerNt.swift
//  test1
//
//  Created by cn-diss-mac1 on 2018/2/8.
//  Copyright © 2018年 Kodak Alaris. All rights reserved.
//

import UIKit

class ViewControllerNt: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.Call()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let manager = AKNetwork()
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
