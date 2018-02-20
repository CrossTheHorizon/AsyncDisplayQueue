//
//  ViewController.swift
//  test1
//
//  Created by AaronZhang on 2018/1/31.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit
class TableViewCell1: UITableViewCell {
    @IBOutlet var lb1: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        asyncView = self.contentView.subviews.first { (view) -> Bool in
            return view is TestAsyncView
        } as? TestAsyncView
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        print("layout cell: \(self.indexPath.row)")
    }
    public var asyncView:TestAsyncView?
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CALayerDelegate,URLSessionDelegate {

    @IBOutlet var tb1: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.layer.addSublayer(AkFPSLayer.init());
        tb1.estimatedRowHeight = 88;
        tb1.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        print("height: \(indexPath.row)")
//        return 88
//    }

//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        print("est height: \(indexPath.row)")
//        return 88
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tb1.dequeueReusableCell(withIdentifier: "cellActivitiesIdentifier") as! TableViewCell1;
        cell.indexPath = indexPath;
        print("cell: \(indexPath.row)")
        
        cell.DisplayId.id += 1;
        for imgView in cell.asyncView!.imgList
        {
            imgView.layer.masksToBounds = false
            imgView.alpha = 0;
            AKRunloopQueue.shared.AddTask(associatedId: cell.DisplayId, taskWeight: 100, task:  { [unowned imgView](task) in
                withExtendedLifetime(imgView, {
                    imgView.image = UIImage.init(named: "splashBackground1.jpg");
                    imgView.alpha = 1;
                    imgView.layer.masksToBounds = true
                })
            })
        }
        
        //cell.layoutIfNeeded()
        return cell;
    }
}

