//
//  ViewController1.swift
//  test1
//
//  Created by cn-diss-mac1 on 2018/2/8.
//  Copyright © 2018年 Kodak Alaris. All rights reserved.
//

import UIKit

class ViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    let fpsLayer = AkFPSLayer.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.layer.addSublayer(fpsLayer);
//        for _ in 0...12
//        {
//            TableViewCell1.init(style: UITableViewCellStyle.default, reuseIdentifier: "cellActivitiesIdentifier")
//        }
    }
    @IBOutlet var tb1: UITableView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1000
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tb1.dequeueReusableCell(withIdentifier: "cellActivitiesIdentifier") as! TableViewCell1;
        cell.asyncView!.prepareRender()
        for imgView in cell.asyncView!.imgList
        {
            imgView.image = nil
        }

        cell.DisplayId.id += 1;
        AkDisplayQueue.shared.AddTask(associatedId:cell.DisplayId, taskWeight: 100) {
            cell.asyncView!.render(cell.DisplayId.id) { ()->Void in
                for imgView in cell.asyncView!.imgList
                {
                    imgView.image = UIImage.init(named: "splashBackground1.jpg");
                }
            }
        }
        return cell;
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

