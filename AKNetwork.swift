//
//  AKNetwork.swift
//  test1
//
//  Created by cn-diss-mac1 on 2018/2/7.
//  Copyright © 2018年 Kodak Alaris. All rights reserved.
//

import UIKit

class AKNetwork:NSObject, URLSessionDelegate, URLSessionDataDelegate {

    let config = URLSessionConfiguration.default
    var session:URLSession?
    override init() {
        super.init()
        config.httpShouldUsePipelining = true
        session = URLSession.init(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }
    func Call() {

        let urlString
        = "http://www.baidu.com";
        //= "http://speed-fun-driver.de/slike/SFD_Header-graf.jpg"
        //= "https://kodakalarisstudio.atlassian.net/secure/BrowseProjects.jspa?selectedCategory=all"
        var request = URLRequest.init(url: URL.init(string: urlString)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let urlCache = URLCache.shared;
        let cResponse = urlCache.cachedResponse(for: request)
        if cResponse != nil{
            let response = cResponse!.response as? HTTPURLResponse;
            if let tag = response?.allHeaderFields["Etag"] as? String
            {
                //request.setValue(tag, forHTTPHeaderField: "If-None-Match")
            }
        }
        request.setValue("100", forHTTPHeaderField: "Keep-Alive")
        //request.httpMethod = "Head"
        var ct = 0;
        let tTime = CACurrentMediaTime()
        for _ in 0...2
        {
        //request.setValue("bytes=0" , forHTTPHeaderField: "AccetpRange")
             //request.setValue("bytes=0" , forHTTPHeaderField: "Range")

            let task = session!.dataTask(with: request) { (data, response, error) in
                guard let data = data else {return}
                let strMSg = String.init(data: data, encoding: String.Encoding.utf8)
                    //print(strMSg)
                    print(response as! HTTPURLResponse)
                    print(CACurrentMediaTime() - tTime)
            }
            
            task.resume()
        }
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
