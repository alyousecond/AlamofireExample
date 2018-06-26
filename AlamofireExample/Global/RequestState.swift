//
//  RequestState.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/23.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

struct RequestState: Equatable {
    enum RequestType {
        case request
        case refresh
        case paging
    }

    static func ==(lhs: RequestState, rhs: RequestState) -> Bool {
        return lhs.isFetching == rhs.isFetching && lhs.requestType == rhs.requestType
    }
    
    var requestType: RequestType
    var isFetching: Bool
    
    init(requestType: RequestType, isFetching: Bool) {
        self.requestType = requestType
        self.isFetching = isFetching
    }
}
