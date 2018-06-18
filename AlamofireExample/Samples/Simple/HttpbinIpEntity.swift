//
//  HttpbinIpEntity.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/15.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//
import ObjectMapper

struct HttpbinIpEntity: Mappable {
    var origin: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        origin<-map["origin"]
    }
}
