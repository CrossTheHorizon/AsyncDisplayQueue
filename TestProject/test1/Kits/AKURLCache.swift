//
//  AKURLCache.swift
//  test1
//
//  Created by MacJenkins on 21/02/2018.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit

class AKURLCacheItem: AKCacheItem {
    var eTag:String?;
    var lastModify:String?;
    
    init(type:AKCacheType, dueDate:Int, data: Data? = nil, ETag:String? = nil, LastModify:String? = nil) {
        super.init(type: type, dueDate: dueDate, data: data);
        self.eTag = ETag;
        self.lastModify = LastModify;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        eTag = aDecoder.decodeObject(forKey: "eTag") as? String;
        lastModify = aDecoder.decodeObject(forKey: "lastModify") as? String;
    }
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(eTag, forKey: "eTag");
        aCoder.encode(lastModify, forKey: "lastModify");
    }
}

extension AKCache
{
    func getURLItem(forKey key:String) -> AKURLCacheItem? {
        return self.getItem(forKey:key) as! AKURLCacheItem?;
    }
}
