//
//  AppBuilder.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/19.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

struct AppBuilder {
    func buildListView() ->ListViewController  {
        let repository = ListRepository()
        let presenter = ListPresenter(repository: repository)
        let viewController = ListViewController(presenter: presenter)
        return viewController
    }
}
