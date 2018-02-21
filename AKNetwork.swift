//
//  AKNetwork.swift
//  test1
//
//  Created by AaronZhang on 2018/2/7.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit

class AKNetwork:NSObject, URLSessionDelegate, URLSessionDataDelegate {

    let config = URLSessionConfiguration.default
    var session:URLSession?
    override init() {
        super.init()
        config.httpShouldUsePipelining = true
        session = URLSession.init(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        URLCache.shared.removeAllCachedResponses()
    }
    func Call() {
        let img = UIImage.init(named: "splashBackground1.jpg");
        let ci = AKURLCacheItem.init(type: .DiskOnly, data: UIImageJPEGRepresentation(img!, 1), ETag: "dddd", LastModify: "sadfljk");
        let url = "ssssd";

        let cache = AKCache.shared;
        cache.storeItem(ci, forKey: url);
        
        let ccc = cache.getURLItem(forKey: url)
        
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

   func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
       NSLog("Triger")
//
//        if (challenge.previousFailureCount == 0)
//        {
//            if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM) {
//                self.bUseNTLM = true;
//                credential?.pointee = URLCredential.init(user: self.setting.userName, password: self.setting.password, persistence: .none);
//                return URLSession.AuthChallengeDisposition.useCredential;
//            }
//            else if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
//            {
//                if(self.manager.securityPolicy.evaluateServerTrust(challenge.protectionSpace.serverTrust!, forDomain: challenge.protectionSpace.host))
//                {
//                    credential?.pointee = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
//
//                    if ((credential?.pointee) != nil) {
//                        return URLSession.AuthChallengeDisposition.useCredential;
//                    } else {
//                        return URLSession.AuthChallengeDisposition.performDefaultHandling;
//                    }
//                }
//            }else {
//                return URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge;
//            }
//        }
//        return URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge;
  }
}
