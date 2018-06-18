//
//  SimpleViewController.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/14.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD
import NotificationBanner

class SimpleViewController: UIViewController {
    @IBOutlet var ipLabel: UILabel!
    private let disposeBag = DisposeBag()
    private let presenter = SimplePresenter(repository: SimpleRepository())
    var bannerQueue: [NotificationBanner] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        let viewState = presenter.stateVariable
                .asObservable()
                .observeOn(MainScheduler.instance)

        viewState
            .map{ $0.isFetching }
            .distinctUntilChanged()
            .subscribe(onNext: { $0 ? SVProgressHUD.show() : SVProgressHUD.dismiss() })
            .disposed(by: disposeBag)

        viewState
            .map{ $0.isFetching }
            .distinctUntilChanged()
            .bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        
        viewState
            .map { $0.error }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] appError in self?.switchNotificationBanner(error: appError) })
            .disposed(by: disposeBag)

        viewState
            .map { $0.origin }
            .distinctUntilChanged()
            .bind(to: ipLabel.rx.text)
            .disposed(by: disposeBag)

        presenter.request()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapRefreshButton() {
        presenter.request()
    }

    private func switchNotificationBanner(error: AppError) {
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




