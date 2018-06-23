//
//  ListState.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/19.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import RxSwift

struct RequestState: Equatable {
    static func ==(lhs: RequestState, rhs: RequestState) -> Bool {
        return lhs.isFetching == rhs.isFetching && lhs.requestType == rhs.requestType
    }
    
    enum RequestType {
        case request
        case refresh
    }
    var requestType = RequestType.request
    var isFetching = false
}

struct ListState: HasError, HasRequestState {
    var page = 1
    var perPage = 20
    var requestState  = RequestState()
    var error = AppError.noError
    var qiitaItems: [QiitaItemElement] = []
}
