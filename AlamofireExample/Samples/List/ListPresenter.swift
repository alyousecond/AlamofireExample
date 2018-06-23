//
//  ListPresenter.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/19.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//
import Alamofire
import RxSwift

protocol ListPresenterProtocol{
    func request(_ type: RequestState.RequestType)
    func markAsRead(with identify: String)
    func toggleLike(with identify: String)
    var repository: ListRepositoryProtocol { get }
    var stateVariable: BehaviorSubject<ListState> { get }
}

struct ListPresenter: ListPresenterProtocol {
    var repository: ListRepositoryProtocol
    var stateVariable = BehaviorSubject<ListState>(value: ListState())
    private let disposeBag = DisposeBag()
    private var state: ListState { return try! stateVariable.value() }

    init(repository: ListRepositoryProtocol) {
        self.repository = repository
    }

    // MAKR: Helper method
    private func onNext(newState: ListState) {
        stateVariable.onNext(newState)
    }

    private func selectItem(with state: ListState, identify: String) -> QiitaItemElement? {
        return state.qiitaItems.filter { $0.identifier == identify }.first
    }
    
    // MARK: Public event method
    func request(_ type: RequestState.RequestType) {
        switch type {
        case .request:
            onNext(newState: stateRequestStart(origin: state))
        case .refresh:
            onNext(newState: stateRefreshStart(origin: state))
        }
        
        let urlString = "https://qiita.com/api/v2/items?page=\(state.page)&per_page=\(state.perPage)"
        getQiitaItems(urlString: urlString)
            .subscribe { event in
                switch event {
                case .success(let entities):
                    self.onNext(newState: self.stateResponceOnSuccess(origin: self.state, entities: entities))
                case .error(let error):
                    guard let appError = error as? AppError else { assertionFailure(); return }
                    self.onNext(newState: self.stateResponceOnError(origin: self.state, appError: appError))
                }
            }
            .disposed(by: disposeBag)
    }

    func markAsRead(with identify: String) {
        guard let item = selectItem(with: state, identify: identify) else { return }
        onNext(newState: stateReadItem(origin: state, selectItem: item))
    }

    func toggleLike(with identify: String) {
        guard let item = selectItem(with: state, identify: identify) else { return }
        onNext(newState: stateLikeItem(origin: state, selectItem: item))
    }
}

extension ListPresenter {
    // MARK: For repository
    private func getQiitaItems(urlString: String) -> Single<[QiitaItemEntity]> {
        return repository.createQiitaItemsSingle(withEndpoint: urlString, method: .get, parameters: nil, encoding: JSONEncoding.default)
    }

    // MARK: For state update
    private func stateReadItem(origin: ListState, selectItem: QiitaItemElement) -> ListState {
        var newState = origin
        newState.qiitaItems = origin.qiitaItems.map({ element in
            var element = element
            if element.url == selectItem.url {
                element.unread = ReadStatus.read
            }
            return element
        })
        return newState
    }

    private func stateLikeItem(origin: ListState, selectItem: QiitaItemElement) -> ListState {
        log.debug("selectItem: \(selectItem.url)")
        var newState = origin
        newState.qiitaItems = origin.qiitaItems.map({ element in
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

    private func stateRequestStart(origin: ListState) -> ListState {
        var newState = origin
        newState.requestState = RequestState(requestType: .request, isFetching: true)
        newState.error = AppError.noError
        return newState
    }

    private func stateRefreshStart(origin: ListState) -> ListState {
        var newState = origin
        newState.requestState = RequestState(requestType: .refresh, isFetching: true)
        newState.error = AppError.noError
        return newState
    }

    private func stateResponceOnSuccess(origin: ListState, entities: [QiitaItemEntity]) -> ListState {
        var newState = origin
        newState.requestState = RequestState(requestType: origin.requestState.requestType, isFetching: false)
        newState.qiitaItems = qiitaItemsElement(entities: entities)
        return newState
    }
    
    private func stateResponceOnError(origin: ListState, appError: AppError) -> ListState {
        var newState = origin
        newState.error = appError
        newState.requestState = RequestState(requestType: origin.requestState.requestType, isFetching: false)
        return newState
    }

    // MARK: For conversion from entity to model view
    private func qiitaItemsElement(entities: [QiitaItemEntity]) -> [QiitaItemElement] {
        return entities.map { entity in
            let userElement = qiitaUserElement(entity: entity.user)
            return QiitaItemElement(url: entity.url, title: entity.title ?? "No title" , user: userElement)
        }
    }
    
    private func qiitaUserElement(entity: QiitaUserEntity?) -> QiitaUserElement {
        guard let user = entity else { return QiitaUserElement(id: "", profileImageUrl: "") }
        return QiitaUserElement(
            id: user.id ?? "",
            profileImageUrl: user.profileImageUrl ?? ""
        )
    }
}
