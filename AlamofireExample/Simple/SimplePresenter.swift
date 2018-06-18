//
//  SimplePresenter.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/15.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//
import RxSwift

struct SimplePresenter {
    let stateVariable = BehaviorSubject<SimpleSate>(value: SimpleSate())
    private let disposeBag = DisposeBag()
    private let repository: HttpRequestable
    private var stateValue: SimpleSate { return try! stateVariable.value() }

    init(repository: HttpRequestable) {
        self.repository = repository
    }

    func request() {
        requesStart()
        getHttpbinIp()
            .subscribe(onSuccess: { entity in
                self.responceOnSuccess(entity: entity)
            }, onError: { error in
                self.responceOnError(error: error)
            })
            .disposed(by: disposeBag)
    }

    private func requesStart() {
        var state = stateValue
        state.isFetching = true
        state.error = AppError.noError
        state.origin = "Loading..."
        stateVariable.onNext(state)
    }

    private func responceOnSuccess(entity: HttpbinIpEntity) {
        var state = stateValue
        if let origin = entity.origin {
            state.origin = origin
        }
        state.isFetching = false
        self.stateVariable.onNext(state)
    }
    
    private func responceOnError(error: Error) {
        var state = stateValue
        guard let appError = error as? AppError else { assertionFailure(); return }
        state.origin = appError.message
        state.error = appError
        state.isFetching = false
        self.stateVariable.onNext(state)
    }

    private func getHttpbinIp() -> Single<HttpbinIpEntity> {
        let urlString = "https://httpbin.org/ip"
        return repository.createSingle(withEndpoint: urlString)
    }
}
