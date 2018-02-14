//
//  AKTableViewCell.swift
//  test1
//
//  Created by cn-diss-mac1 on 2018/2/5.
//  Copyright © 2018年 Kodak Alaris. All rights reserved.
//

import UIKit

extension UITableViewCell {
    var idenetify:String
    {
        get
        {
            return (self.value(forKey: "identity") ?? "") as! String
        }
        set
        {
            return self.setValue(newValue, forKey: "identity")
        }
    }
    var index:IndexPath
    {
        get
        {
            return (self.value(forKey: "IndexPath") ?? IndexPath.init(item: 0, section: 0)) as! IndexPath
        }
        set
        {
            return self.setValue(newValue, forKey: "IndexPath")
        }
    }

}

