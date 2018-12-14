//
//  NetworkManager.swift
//  ZhiHuTopic
//
//  Created by BitBill on 2018/12/14.
//  Copyright © 2018 CircleTable. All rights reserved.
//

import UIKit
import Alamofire

let SERVER_TEST_BASE_URL = "http://www.zhihu.com"

class NetworkManager: NSObject {
    
    var baseURL: URL!
    fileprivate var manager: SessionManager!
    
    static let manager = {
        return NetworkManager()
    }()
    
    override init() {
        super.init()
        baseURL = getBaseURL()
        initSessionManager()
    }
    
    func initSessionManager() {
//        let serverTrustPolicy = ServerTrustPolicy.pinCertificates(
//            certificates: ServerTrustPolicy.certificates(),
//            validateCertificateChain: true,
//            validateHost: true
//        )
        let serverTrustPolicies: [String: ServerTrustPolicy] = [:]
        manager = SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        manager.delegate.taskDidReceiveChallenge = { (session, task, challenge) in
            return (.cancelAuthenticationChallenge, nil)
        }
        manager.delegate.sessionDidReceiveChallenge = { (session, challenge) in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            switch challenge.protectionSpace.authenticationMethod {
            case NSURLAuthenticationMethodServerTrust:
                //认证服务器证书
                let host = challenge.protectionSpace.host
                if
                    let serverTrustPolicy = serverTrustPolicies[host],
                    let serverTrust = challenge.protectionSpace.serverTrust
                {
                    //session对对应的host有相应的Policy alamofire默认下session.serverTrustPolicyManager就为nil
                    if serverTrustPolicy.evaluate(serverTrust, forHost: host) {
                        //认证
                        disposition = .useCredential
                        credential = URLCredential(trust: serverTrust)
                    } else {
                        //取消
                        disposition = .cancelAuthenticationChallenge
                    }
                }
                return (disposition, credential)
            default:
                return (.cancelAuthenticationChallenge, nil)
            }
        }
    }
    
    func getBaseURL() -> URL {
        let hostName = Bundle.main.object(forInfoDictionaryKey: "ZHI_HU_TOPIC_HOST")
        if let h = hostName as? String {
            return URL(string: SERVER_TEST_BASE_URL + h)!
        }
        return URL(string: SERVER_TEST_BASE_URL)!
    }

    func request(serviceName: String, path: String?, parameters: Any?, method: HTTPMethod, isJsonRequest: Bool = true) {
        var urlPath = serviceName
        if let p = path, !p.isEmpty {
            urlPath.append(p)
        }
        
        if method == .get, let ps = parameters as? Array<Any> {
            for p in ps {
                if p is Int || p is String || p is NSNumber {
                    urlPath.append("/\(p)")
                }
            }
        }
        
        let url = URL(string: urlPath, relativeTo: baseURL)!
        
        
    }
    
}
