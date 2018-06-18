//
//  AppError.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/15.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import Foundation

enum AppError: Error, Equatable {
    case noError
    case network(Error)
    case generic(String)
    
    static func ==(lhs: AppError, rhs: AppError) -> Bool {
        return lhs.message == rhs.message
    }

    var isError: Bool {
        switch self {
        case .noError: return false
        default: return true
        }
    }

    var message: String {
        switch self {
        case .noError: return ""
        case .network(let error):
            return error.localizedDescription
        case .generic(let message):
            return message
        }
    }
}
