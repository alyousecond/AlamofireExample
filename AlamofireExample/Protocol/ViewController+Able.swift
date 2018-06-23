//
//  UIViewController+Presentable.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/17.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import Foundation
import RxSwift
import SVProgressHUD
import NotificationBanner

///////////////////////////////////////////////////////////////////////
// FetchingPresentable
///////////////////////////////////////////////////////////////////////
//
// You need to add the following code to ViewController.
// bindFetching(state: viewState, disposeBag: disposeBag)
//
protocol FetchingPresentable {
    func bindFetching<T: HasFetching>(state: Observable<T>, disposeBag: DisposeBag)
}

extension FetchingPresentable where Self: UIViewController {
    func bindFetching<T>(state: Observable<T>, disposeBag: DisposeBag) where T : HasFetching {
        state
            .map{ $0.isFetching }
            .distinctUntilChanged()
            .subscribe(onNext: { $0 ? SVProgressHUD.show() : SVProgressHUD.dismiss() })
            .disposed(by: disposeBag)
        
        state
            .map{ $0.isFetching }
            .distinctUntilChanged()
            .bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
    }
}

///////////////////////////////////////////////////////////////////////
// RequestStatePresentable
///////////////////////////////////////////////////////////////////////
//
// You need to add the following code to ViewController.
// bindRequestState(state: viewState, disposeBag: disposeBag)
//
protocol RefreshingPresentable: class {
    var refreshControl: UIRefreshControl { get }
    var refreshControlView: UIScrollView { get }
    func bindRefreshing<T: HasRequestState>(state: Observable<T>, disposeBag: DisposeBag)
}

extension RefreshingPresentable where Self: UIViewController {
    func bindRefreshing<T>(state: Observable<T>, disposeBag: DisposeBag) where T : HasRequestState {
        refreshControlView.addSubview(refreshControl)

        state
            .map{ $0.requestState }
            .distinctUntilChanged()
            .filter { $0.requestType == .request }
            .map { $0.isFetching }
            .subscribe(onNext: { $0 ? SVProgressHUD.show() : SVProgressHUD.dismiss() })
            .disposed(by: disposeBag)
        
        state
            .map{ $0.requestState.isFetching }
            .distinctUntilChanged()
            .bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)

        state
            .map { $0.requestState }
            .distinctUntilChanged()
            .filter { $0.requestType == .refresh }
            .map { $0.isFetching }
            .filter { $0.reverse }
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
    }
}

///////////////////////////////////////////////////////////////////////
// ErrorNotificationPresentable
///////////////////////////////////////////////////////////////////////
//
// You need to add the following code to ViewController.
// bindFetching(state: viewState, disposeBag: disposeBag)
//
protocol ErrorNotificationPresentable: class {
    var bannerQueue: [NotificationBanner] { get set }
    func bindErrorNotification<T: HasError>(state: Observable<T>, disposeBag: DisposeBag)
}

extension ErrorNotificationPresentable where Self: UIViewController {
    func bindErrorNotification<T>(state: Observable<T>, disposeBag: DisposeBag) where T : HasError {
        state
            .map { $0.error }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] error in self?.switchAlert(error: error) })
            .disposed(by: disposeBag)
    }

    private func switchAlert(error: AppError) {
        if error.isError {
            let banner = NotificationBanner(title: error.message, style: .danger)
            banner.autoDismiss = false
            banner.dismissOnTap = true
            banner.show()
            bannerQueue.append(banner)
        } else {
            bannerQueue.forEach({ $0.dismiss() })
            bannerQueue.removeAll()
        }
    }
}

