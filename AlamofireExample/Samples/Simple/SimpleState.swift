//
//  SimpleViewModel.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/16.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import RxSwift

struct SimpleSate {
    var isFetching  = false
    var error = AppError.noError
    var origin = "No data"
}
