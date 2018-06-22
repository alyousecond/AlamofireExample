//
//  ListState.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/19.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import RxSwift

struct ListState: HasError, HasFetching {
    var isFetching  = false
    var error = AppError.noError
    var qiitaItems: [QiitaItemElement] = []
}
