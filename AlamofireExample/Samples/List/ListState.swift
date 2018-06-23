//
//  ListState.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/19.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

struct ListState: HasError, HasRequestState {
    var page = 1
    var perPage = 20
    var requestState  = RequestState()
    var error = AppError.noError
    var qiitaItems: [QiitaItemElement] = []
}
