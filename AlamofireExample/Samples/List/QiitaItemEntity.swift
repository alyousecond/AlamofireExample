//
//  QiitaItemsEntity.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/19.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import ObjectMapper

struct QiitaItemEntity: Mappable {
    var url: String!
    var title: String?
    var user: QiitaUserEntity?

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        url <- map["url"]
        title <- map["title"]
        user <- map["user"]
    }
}

struct QiitaUserEntity: Mappable {
    var profileImageUrl: String?
    var id: String?

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        profileImageUrl <- map["profile_image_url"]
    }
}
