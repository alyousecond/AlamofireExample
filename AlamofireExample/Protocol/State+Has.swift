//
//  State+Has.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/18.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

protocol HasFetching {
    var isFetching: Bool { get }
}

protocol HasError {
    var error: AppError { get }
}
