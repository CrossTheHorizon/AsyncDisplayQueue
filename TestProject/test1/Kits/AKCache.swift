//
//  AKCache.swift
//  test1
//
//  Created by MacJenkins on 20/02/2018.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit
enum AKCacheType:Int
{
    case DiskOnly = 0, Protected, Common
}
class AKCacheItem: NSObject, NSCoding {
    var type = AKCacheType.Common
    var data:Data?;
    var due_date = 7;
    var file_name = "";
    init(type:AKCacheType = .Common, dueDate:Int = 7, data: Data? = nil) {
        super.init();
        self.type = type;
        self.due_date = dueDate;
        self.data = data;
    }
    required init?(coder aDecoder: NSCoder) {
        super.init()
        file_name = aDecoder.decodeObject() as! String;
        due_date = aDecoder.decodeObject() as! Int;
        type = AKCacheType.init(rawValue: aDecoder.decodeObject() as! Int)!;
        data = aDecoder.decodeObject(forKey: "DATA") as! Data?;
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(file_name);
        aCoder.encode(due_date)
        aCoder.encode(type.rawValue);
        if data != nil {
            aCoder.encode(data, forKey: "DATA");
        }
    }
}

class AKCache: NSObject {

    private let queue = DispatchQueue(label: "SafeArrayQueue", attributes: .concurrent);
    private var itemLst = [String: AKCacheItem]();
    private let storage = AKStorage();
    static let shared = AKCache()
    private let tempFilePath:String;
    private override init() {
        tempFilePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        super.init();
    }
    deinit {
        
    }
    func storeItem(_ value:AKCacheItem, forKey key:String) ->Bool {
        queue.async(flags: .barrier) {
            // 写操作
            // Memory cache
            if value.type != .DiskOnly {
                self.itemLst.updateValue(value, forKey: key);
            }
            
            // Write to file if needed (larger than 16k)
            var tmpDt:Data? = nil;
            if let data = value.data {
                if data.count > 16000
                {
                    let path = value.file_name == "" ? self.tempFilePath + "/" + UUID.init().uuidString : value.file_name;
                    value.file_name = path;
                    try? data.write(to: URL.init(fileURLWithPath: path));
                    
                    // Remove data as it should not save to SQLite
                    tmpDt = value.data;
                    value.data = nil;
                }
            }
            
            // Save to SQLite
            self.storage?.dbSave(NSKeyedArchiver.archivedData(withRootObject: value), forKey: key, dueDate: value.due_date);
            
            // Add data back
            if value.type != .DiskOnly && tmpDt != nil{
                value.data = tmpDt;
            }
        }

        return true;
    }
    func getItem(forKey key:String) -> AKCacheItem? {
        var rst:AKCacheItem? = nil;
        queue.sync {
            rst = self.itemLst[key];
            if rst == nil{
                let data = self.storage?.dbValue(forKey: key);
                if data != nil{
                    rst = NSKeyedUnarchiver.unarchiveObject(with: data!) as! AKCacheItem?;
                }
                if rst?.file_name != ""
                {
                    try? rst?.data = Data.init(contentsOf: URL.init(fileURLWithPath: (rst?.file_name)!))
                }
            }
        }
        return rst;
    }

}
