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

class AKRequest
{
    var reuest:URLRequest;
    var url:String!;
    var cachePolicy = AKCachePolicy.varifyBeforeUse;
    var cacheType = AKCacheType.Common;
    var dueDate = 7;
    
    init(_url:String, timeout:TimeInterval, _cachePolicy:AKCachePolicy = AKCachePolicy.varifyBeforeUse, _cacheType:AKCacheType = AKCacheType.Common) {
        url = _url;
        cachePolicy = _cachePolicy;
        cacheType = _cacheType;
        reuest = URLRequest.init(url: URL.init(string: url)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: timeout);
    }

}

class AKNetwork:NSObject, URLSessionDelegate {

    let config = URLSessionConfiguration.default;
    var session:URLSession?;
    var username = "", password = "";
    var certificateFile = "";
    var srvAuthenticationMethod = NSURLAuthenticationMethodDefault;
    override init() {
        super.init()
        config.httpShouldUsePipelining = true
        session = URLSession.init(configuration: config, delegate: self, delegateQueue: OperationQueue.init())
    }
    
    func Get(akreq:AKRequest, completionHandler:@escaping (Data?, URLResponse?, Error?) -> Swift.Void)
    {
        var request = akreq.reuest;
        var cachedItem:AKURLCacheItem? = nil;
        if akreq.cachePolicy != .notUseCache
        {
            let urlCache = AKCache.shared;
            cachedItem = urlCache.getURLItem(forKey: akreq.url)
            if cachedItem != nil{
                if akreq.cachePolicy == AKCachePolicy.alwaysUseCache
                {
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

        let task = session!.dataTask(with: request) { (data, response, error) in
            if let response = response as! HTTPURLResponse?
            {
                if response.statusCode == 304 && cachedItem != nil
                {
                    completionHandler(cachedItem?.data, nil, nil)
                }
                else {
                    AKCache.shared.storeItem(AKURLCacheItem.init(type: akreq.cacheType, dueDate: akreq.dueDate, data: data, ETag: response.allHeaderFields["Etag"] as! String?, LastModify: response.allHeaderFields["Last-Modified"] as! String?), forKey: akreq.url);
                    completionHandler(cachedItem?.data, response, nil)
                }
            }
        }
        
        task.resume()
    }
    
    func Call() {
        let dt = try? Data.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "splashBackground1", ofType: "jpg")!))
        let ci = AKURLCacheItem.init(data: dt, ETag: "dddd", LastModify: "sadfljk");
        let ci1 = AKURLCacheItem.init(data: dt, ETag: "dddd1");
        let url = "ssssd";

        let cache = AKCache.shared;
        cache.storeItem(ci, forKey: url);
        cache.storeItem(ci1, forKey: "url");
        //cache.ClearMemory();
        let ccc = cache.getURLItem(forKey: url)
        let img = UIImage.init(data: ccc!.data!);
        return;
        let urlString
        //= "http://www.baidu.com";
        = "http://speed-fun-driver.de/slike/SFD_Header-graf.jpg"
        //= "https://kodakalarisstudio.atlassian.net/secure/BrowseProjects.jspa?selectedCategory=all"
        let tTime = CACurrentMediaTime()
        //for _ in 0...2
        //{
        var request = URLRequest.init(url: URL.init(string: urlString)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let urlCache = URLCache.shared;
        let cResponse = urlCache.cachedResponse(for: request)
        if cResponse != nil{
            let response = cResponse!.response as? HTTPURLResponse;
            if let tag = response?.allHeaderFields["Etag"] as? String
            {
                request.setValue(tag, forHTTPHeaderField: "If-None-Match")
            }
            if let tag = response?.allHeaderFields["Last-Modified"] as? String
            {
                request.setValue(tag, forHTTPHeaderField: "If-Modified-Since")
            }
        }
        request.setValue("100", forHTTPHeaderField: "Keep-Alive")
        //request.httpMethod = "Head"


             //request.setValue("bytes=0" , forHTTPHeaderField: "Range")

            let task = session!.dataTask(with: request) { (data, response, error) in
                guard let data = data else {return}
                let strMSg = String.init(data: data, encoding: String.Encoding.utf8)
                //print(strMSg)
                print(response as! HTTPURLResponse)
                print(CACurrentMediaTime() - tTime)
                
                //URLCache.shared.storeCachedResponse(CachedURLResponse.init(response: response!, data: data), for: request)
            }
            
            task.resume()
//        DispatchQueue.global().async {
//            while task.state == .running {
//                print(task.countOfBytesExpectedToReceive)
//                print(task.countOfBytesReceived)
//            }
//
//        }
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
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        NSLog("didReceiveAuthorizationChallenge")
        if (challenge.previousFailureCount == 0)
        {
            srvAuthenticationMethod = challenge.protectionSpace.authenticationMethod;
            if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM) {
                let credential = URLCredential.init(user: self.username, password: self.password, persistence: .forSession);
                completionHandler(.useCredential, credential);
            }
            else if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic) {
                let credential = URLCredential.init(user: self.username, password: self.password, persistence: .forSession);
                completionHandler(.useCredential, credential)
            }
            else if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
            {
                if self.certificateFile != ""
                {
                    let certi = SecTrustGetCertificateAtIndex(challenge.protectionSpace.serverTrust!, 0);
                    let certidata = SecCertificateCopyData(certi!) as Data
                    let path = Bundle.main.path(forResource: certificateFile, ofType: "cer") ?? "";
                    let localCertiData = try? Data.init(contentsOf: URL.init(fileURLWithPath: path));
                    if (certidata == localCertiData) {
                        let credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
                        completionHandler(.useCredential, credential)
                    }
                    else{
                        completionHandler(.cancelAuthenticationChallenge, nil)
                    }
                }
                else {
                    let credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
                    completionHandler(.useCredential, credential)
                }
            }
            else {
                completionHandler(.performDefaultHandling, nil)
            }
        }
        else{
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
