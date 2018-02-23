//
//  AKNetwork.swift
//  test1
//
//  Created by AaronZhang on 2018/2/7.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit
enum AKCachePolicy
{
    case varifyBeforeUse, notUseCache, alwaysUseCache;
}

class AKRequest:Hashable
{
    var hashValue: Int
    
    static func ==(lhs: AKRequest, rhs: AKRequest) -> Bool {
        return lhs === rhs;
    }
    
    var reuest:URLRequest;
    var url:String!;
    var cachePolicy = AKCachePolicy.varifyBeforeUse;
    var cacheType = AKCacheType.Common;
    var dueDate = 7;
    var associatedId:AssociatedId?;
    var task:URLSessionTask?;
    
    init(_url:String, timeout:TimeInterval, _cachePolicy:AKCachePolicy = AKCachePolicy.varifyBeforeUse, _cacheType:AKCacheType = AKCacheType.Common, _associatedId:AssociatedId? = nil) {
        url = _url;
        cachePolicy = _cachePolicy;
        cacheType = _cacheType;
        associatedId = _associatedId;
        hashValue = _url.hashValue;
        reuest = URLRequest.init(url: URL.init(string: url)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: timeout);
    }
}

class AKNetwork{

    var session:URLSession?;
    let manager = AKNetworkManager();
    var pendingTasks = [(DispatchWorkItem, AssociatedId?, Int?, AKRequest?)]();         // Limit concurrent web request
    var runningTasks = Set<AKRequest>();                                    // Manage running tasks
    var maxConcurrentNum = 8;
    var pieceMinSize = 10000;
    var pieceMax = 4;
    
    private let dispatchTaskQueue = DispatchQueue(label: "AkNetwork dispatch queue")
    private let workingQueue = DispatchQueue.init(label: "AKNetwork network queue", attributes: DispatchQueue.Attributes.concurrent)
    private let group1 = DispatchGroup()
    init(config:URLSessionConfiguration = URLSessionConfiguration.default) {
        config.httpShouldUsePipelining = true
        session = URLSession.init(configuration: config, delegate: manager, delegateQueue: OperationQueue.init())
   
    }
    

    func dispatchTask(removeRequest:AKRequest?)
    {
        dispatchTaskQueue.async {
            if let request = removeRequest{
                self.runningTasks.remove(request);
            }
            self.dispatchTask();
        }
    }
    
    func dispatchTask()
    {
        if self.runningTasks.count >= self.maxConcurrentNum
        {
            return;
        }
        while self.pendingTasks.count != 0
        {
            let (task, associateId, id, akreq) = self.pendingTasks.removeFirst();
            if associateId?.id == id
            {
                self.runningTasks.insert(akreq!);
                workingQueue.async(execute: task);
                break;
            }
        }
    }
    
    func Get(akreq:AKRequest, completionHandler:@escaping (Data?, URLResponse?, Error?) -> Swift.Void)
    {
        let dispTask = DispatchWorkItem.init {
            var request = akreq.reuest;
            var cachedItem:AKURLCacheItem? = nil;
            if akreq.cachePolicy != .notUseCache
            {
                let urlCache = AKCache.shared;
                cachedItem = urlCache.getURLItem(forKey: akreq.url)
                if cachedItem != nil{
                    if akreq.cachePolicy == AKCachePolicy.alwaysUseCache
                    {
                        self.dispatchTask(removeRequest: akreq);
                        completionHandler(cachedItem?.data, nil, nil)
                        return;
                    }
                    if let tag = cachedItem?.eTag
                    {
                        request.setValue(tag, forHTTPHeaderField: "If-None-Match")
                    }
                    if let tag = cachedItem?.lastModify
                    {
                        request.setValue(tag, forHTTPHeaderField: "If-Modified-Since")
                    }
                }
            }
            let task = self.session!.dataTask(with: request) { (data, response, error) in
                // remove task from running task list
                self.dispatchTask(removeRequest: akreq);
                
                // process error
                if error != nil{
                    print(error!)
                }
                
                // save cache if needed and return result
                if let response = response as! HTTPURLResponse?
                {
                    print(response)
                    if response.statusCode == 304
                    {
                        completionHandler(cachedItem?.data, nil, nil)
                        return;
                    }
                    
                    if akreq.cachePolicy != .notUseCache {
                        AKCache.shared.storeItem(AKURLCacheItem.init(type: akreq.cacheType, dueDate: akreq.dueDate, data: data, ETag: response.allHeaderFields["Etag"] as! String?, LastModify: response.allHeaderFields["Last-Modified"] as! String?), forKey: akreq.url);
                    }
                    completionHandler(data, response, nil)
                }
            }
            akreq.task = task;
            task.resume()
        }
        self.dispatchTaskQueue.async {
            self.pendingTasks.append((dispTask, akreq.associatedId, akreq.associatedId?.id, akreq));
            self.dispatchTask();
        }
    }
    
    func GetOverlap(akreq:AKRequest, completionHandler:@escaping (Data?, URLResponse?, Error?) -> Swift.Void)
    {
        let dispTask = DispatchWorkItem.init {
            var request = akreq.reuest;
            var cachedItem:AKURLCacheItem? = nil;
            if akreq.cachePolicy == AKCachePolicy.alwaysUseCache
            {
                let urlCache = AKCache.shared;
                cachedItem = urlCache.getURLItem(forKey: akreq.url)
                if cachedItem != nil{
                    self.dispatchTask(removeRequest: akreq);
                    completionHandler(cachedItem?.data, nil, nil)
                    return;
                }
            }
            
            request.httpMethod = "Head";
            let task = self.session!.dataTask(with: request) { (data, response, error) in
                // remove task from running task list
                self.dispatchTask(removeRequest: akreq);
                
                // process error
                if error != nil{
                    print(error!)
                    completionHandler(nil, nil, error)
                    return
                }
                
                // save cache if needed and return result
                if let response = response as! HTTPURLResponse?
                {
                    print(response)
                    
                    if cachedItem != nil && response.allHeaderFields["Etag"] as! String? == cachedItem?.eTag
                        && response.allHeaderFields["Last-Modified"] as! String? == cachedItem?.lastModify
                    {
                        completionHandler(cachedItem?.data, nil, nil)
                    }
                    else {
                        let length = Int(response.allHeaderFields["Content-Length"] as! String)!
                        var piece = length / self.pieceMinSize + 1;
                        var pieceSize = self.pieceMinSize;
                        if piece > self.pieceMax
                        {
                            piece = self.pieceMax;
                            pieceSize = length / self.pieceMax;
                        }
                        var dataRst = [Data]();
                        let group = DispatchGroup();
                        for i in 0..<piece
                        {
                            group.enter();
                            let pieceReq = AKRequest.init(_url: akreq.url, timeout: akreq.reuest.timeoutInterval, _cachePolicy: AKCachePolicy.notUseCache, _associatedId: akreq.associatedId);
                            let beginBytes = i*pieceSize;
                            let endBytes = (i == (piece - 1) ? pieceSize + length % piece : pieceSize - 1) + pieceSize * i;
                            pieceReq.reuest.setValue("bytes=\(beginBytes)-\(endBytes)" , forHTTPHeaderField: "Range")
                            dataRst.append(Data())
                            self.Get(akreq: pieceReq, completionHandler: { (data, response, error) in
                                // process error
                                if error != nil {
                                    print(error!)
                                }
                                if let data = data {
                                    dataRst[i].append(data);
                                }
                                group.leave();
                            })
                        }
                        group.notify(queue: DispatchQueue.global(), execute: {
                            var data = Data();
                            dataRst.forEach({ (d) in
                                data.append(d)
                            })
                            dataRst.removeAll();
                            completionHandler(data, nil, nil)
                        })
                    }
                }
            }
            akreq.task = task;
            task.resume()
        }
        self.dispatchTaskQueue.async {
            self.pendingTasks.append((dispTask, akreq.associatedId, akreq.associatedId?.id, akreq));
            self.dispatchTask();
        }
    }
    
    func Call() {
//       let dt = try? Data.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "splashBackground1", ofType: "jpg")!))
////        let ci = AKURLCacheItem.init(data: dt, ETag: "dddd", LastModify: "sadfljk");
//       let ci1 = AKURLCacheItem.init(data: dt, ETag: "dddd1");
////        let url = "ssssd";
//
//        let cache = AKCache.shared;
////        cache.storeItem(ci, forKey: url);
//       cache.storeItem(ci1, forKey: "url");
//        //cache.ClearMemory();
//        let ccc = cache.getURLItem(forKey: "url")
//        let img = UIImage.init(data: ccc!.data!);
        //return

        let urlString
        = "http://sqdownb.onlinedown.net/down/360zip_setup_4.0.0.1040.exe"
        //= "http://www.baidu.com";
        //= "http://speed-fun-driver.de/slike/SFD_Header-graf.jpg"
        //= "https://kodakalarisstudio.atlassian.net/secure/BrowseProjects.jspa?selectedCategory=all"
        

        
        let tTime = CACurrentMediaTime()
        for i in 0...0
        {
            //group1.enter()
            let req = AKRequest.init(_url: urlString, timeout: 10, _cachePolicy: .notUseCache);
            self.Get(akreq: req, completionHandler: { (d, r, e) in
                //let img = UIImage.init(data: d!);
                NSLog("Finish %d", i)
                let curTime = CACurrentMediaTime() - tTime;
                print(curTime)
                //self.group1.leave()
            })
        }
        group1.notify(queue: DispatchQueue.global()) {
            let curTime = CACurrentMediaTime() - tTime;
            print(curTime)
        }
        return;
        var request = URLRequest.init(url: URL.init(string: urlString)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
//        let urlCache = URLCache.shared;
//        let cResponse = urlCache.cachedResponse(for: request)
//        if cResponse != nil{
//            let response = cResponse!.response as? HTTPURLResponse;
//            if let tag = response?.allHeaderFields["Etag"] as? String
//            {
//                request.setValue(tag, forHTTPHeaderField: "If-None-Match")
//            }
//            if let tag = response?.allHeaderFields["Last-Modified"] as? String
//            {
//                request.setValue(tag, forHTTPHeaderField: "If-Modified-Since")
//            }
//        }
//        request.setValue("100", forHTTPHeaderField: "Keep-Alive")
        //request.httpMethod = "Head"

             //request.setValue("bytes=0" , forHTTPHeaderField: "Range")
        let task = session!.downloadTask(with: URL.init(string: urlString)!, completionHandler: { (url, response, error) in
            
        })
        task.resume()
//            let task = session!.dataTask(with: request) { (data, response, error) in
//                guard let data = data else {return}
//                let strMSg = String.init(data: data, encoding: String.Encoding.utf8)
//                //print(strMSg)
//                print(response as! HTTPURLResponse)
//                print(CACurrentMediaTime() - tTime)
//
//                //URLCache.shared.storeCachedResponse(CachedURLResponse.init(response: response!, data: data), for: request)
//            }
//
//            task.resume()
        DispatchQueue.global().async {
            while task.state == .running {
                print(task.countOfBytesExpectedToReceive)
                print(task.countOfBytesReceived)
                
                if task.countOfBytesReceived > 10000
                {
                    task.cancel(byProducingResumeData: { (data) in
                        print(data)
                    })
                    break;
                }
            }

        }
        //}
        
        
//        request.httpShouldUsePipelining = true;
//        for _ in 0...5
//        {
//            let task = session!.dataTask(with: request) { (data, request1, error) in
//                print(data)
//            }
//            task.resume()
//        }
    }
    
   
}
