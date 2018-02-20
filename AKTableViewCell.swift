//
//  AKTableViewCell.swift
//  test1
//
//  Created by AaronZhang on 2018/2/5.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
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
    
    static var indexPathID = "indexPathID"
    var indexPath:IndexPath
    {
        get
        {
            return objc_getAssociatedObject(self, &UITableViewCell.indexPathID) as? IndexPath ?? IndexPath.init(item: 0, section: 0)
        }
        set
        {
            objc_setAssociatedObject(self, &UITableViewCell.indexPathID, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

}

