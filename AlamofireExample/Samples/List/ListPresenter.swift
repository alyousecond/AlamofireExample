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

    // MARK: Helper method
    private func onNext(newState: ListState) {
        stateVariable.onNext(newState)
    }

    private func selectItem(with state: ListState, identify: String) -> QiitaItemElement? {
        return state.elements.filter { $0.identifier == identify }.first
    }
    
    // MARK: Public event method
    func request(_ type: RequestState.RequestType) {
        switch type {
        case .request:
            onNext(newState: state.renewRequestStart())
        case .refresh:
            onNext(newState: state.renewRefreshStart())
        case .paging:
            onNext(newState: state.renewPagingStart())
        }
        
        let urlString = "https://qiita.com/api/v2/items?page=\(state.page)&per_page=\(state.perPage)"
        getQiitaItems(urlString: urlString)
            .subscribe { event in
                switch event {
                case .success(let entities):
                    self.onNext(newState: self.state.renewResponceOnSuccess(newElements: self.qiitaItemsElement(entities: entities)))
                case .error(let error):
                    guard let appError = error as? AppError else { assertionFailure(); return }
                    self.onNext(newState: self.state.renewResponceOnError(appError: appError))
                }
            }
            .disposed(by: disposeBag)
    }

    func markAsRead(with identify: String) {
        guard let item = selectItem(with: state, identify: identify) else { return }
        onNext(newState: state.renewReadItem(selectItem: item))
    }

    func toggleLike(with identify: String) {
        guard let item = selectItem(with: state, identify: identify) else { return }
        onNext(newState: state.renewLikeItem(selectItem: item))
    }
}

extension ListPresenter {
    // MARK: For repository
    private func getQiitaItems(urlString: String) -> Single<[QiitaItemEntity]> {
        return repository.createQiitaItemsSingle(withEndpoint: urlString, method: .get, parameters: nil, encoding: JSONEncoding.default)
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
