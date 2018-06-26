//
//  APIManager.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/16.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import Alamofire

class APIManager {
    static let shared: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 5
        configuration.urlCache = nil
        configuration.httpShouldSetCookies = false
        configuration.httpShouldUsePipelining = true
        return SessionManager(configuration: configuration)
    }()
}
