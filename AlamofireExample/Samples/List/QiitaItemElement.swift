//
//  QiitaItemElement.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/21.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import UIKit

enum ReadStatus {
    case read
    case unread
    var color: UIColor {
        switch self {
        case .read: return UIColor.white
        case .unread: return UIColor(red: 255/255, green: 186/255, blue: 82/256, alpha: 0.2)
        }
    }
}

enum LikeStatus {
    case none
    case like
    var color: UIColor {
        switch self {
        case .none: return UIColor.lightGray.withAlphaComponent(0.5)
        case .like: return UIColor(red: 52/255, green: 94/255, blue: 242/255, alpha: 1.0)
        }
    }
}

struct QiitaItemElement: Identifiable {
    var identifier: String { return url }
    
    let url: String
    let title: String
    let user: QiitaUserElement
    var unread = ReadStatus.unread
    var like = LikeStatus.none

    init(url: String, title: String, user: QiitaUserElement) {
        self.url = url
        self.title = title
        self.user = user
    }
}

struct QiitaUserElement: Identifiable  {
    var identifier: String { return id }

    let id: String
    let profileImageUrl: String
    
    init(id: String, profileImageUrl: String) {
        self.id = id
        self.profileImageUrl = profileImageUrl
    }
}
