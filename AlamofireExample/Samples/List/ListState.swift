//
//  ListState.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/19.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

struct ListState: HasError, HasRequestState, HasPagingState {
    let maxPage = 3 // There is a limit on the API request, it is limited to 3 pages
    var page = 1
    var perPage = 20
    var requestState  = RequestState(requestType: .request, isFetching: false) // HasRequestState
    var error = AppError.noError // HasError
    var elements: [QiitaItemElement] = []
    
    // MARK: For state renew
    func renewReadItem(selectItem: QiitaItemElement) -> ListState {
        var newState = self
        newState.elements = elements.map({ element in
            var element = element
            if element.url == selectItem.url {
                element.unread = ReadStatus.read
            }
            return element
        })
        return newState
    }
    
    func renewLikeItem(selectItem: QiitaItemElement) -> ListState {
        var newState = self
        newState.elements = elements.map({ element in
            var element = element
            if element.url == selectItem.url {
                switch selectItem.like {
                case .none: element.like = LikeStatus.like
                case .like: element.like = LikeStatus.none
                }
            }
            return element
        })
        return newState
    }
    
    func renewRequestStart() -> ListState {
        var newState = self
        newState.requestState = RequestState(requestType: .request, isFetching: true)
        newState.page = 1
        newState.error = AppError.noError
        return newState
    }
    
    func renewRefreshStart() -> ListState {
        var newState = self
        newState.requestState = RequestState(requestType: .refresh, isFetching: true)
        newState.page = 1
        newState.error = AppError.noError
        return newState
    }

    func renewPagingStart() -> ListState {
        var newState = self
        newState.requestState = RequestState(requestType: .paging, isFetching: true)
        newState.page = page + 1
        newState.error = AppError.noError
        return newState
    }

    func renewResponceOnSuccess(newElements: [QiitaItemElement]) -> ListState {
        var newState = self
        switch requestState.requestType {
        case .request, .refresh:
            newState.elements = newElements
        case .paging:
            newState.elements = elements + newElements
        }
        newState.requestState = RequestState(requestType: requestState.requestType, isFetching: false)
        return newState
    }
    
    func renewResponceOnError(appError: AppError) -> ListState {
        var newState = self
        newState.error = appError
        newState.requestState = RequestState(requestType: requestState.requestType, isFetching: false)
        return newState
    }
}
