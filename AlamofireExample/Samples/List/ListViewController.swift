//
//  ListViewController.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/19.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SVProgressHUD
import NotificationBanner
import Kingfisher

final class ListViewController: UIViewController, RefreshingPresentable, PagingPresentable, ErrorNotificationPresentable {
    let refreshControl = UIRefreshControl() // RefreshingPresentable
    var refreshControlView: UIScrollView { return tableView  } // RefreshingPresentable
    var bannerQueue: [NotificationBanner] = [] // ErrorNotificationPresentable
    let footerView = IndicatorFooterView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)) // PagingPresentable
    let tableView = UITableView(frame: .zero, style: .plain) // PagingPresentable

    private let presenter: ListPresenterProtocol
    private let disposeBag = DisposeBag()
    private let cellIdentifier = String(describing: type(of: ListViewCell.self))

    init(presenter: ListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: String(describing: ListViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = CGFloat(90.0)
        view.addSubview(tableView)

        let viewState = presenter.stateVariable
            .asObservable()
            .observeOn(MainScheduler.instance)

        bindRefreshing(state: viewState, disposeBag: disposeBag) // RefreshingPresentable
        bindPaging(state: viewState, disposeBag: disposeBag) // PagingPresentable
        bindErrorNotification(state: viewState, disposeBag: disposeBag) // ErrorNotificationPresentable

        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged) // Required for refresh controll

        viewState
            .map { $0.elements }
            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: ListViewCell.self)) { (row, element, cell) in
                cell.bind(element: element)
                if cell.isSubscribe.reverse {
                    cell.likeButton.rx.tap
                        .subscribe(onNext: { [weak self] in self?.presenter.toggleLike(with: cell.identifier) })
                        .disposed(by: cell.disposeBag)
                    cell.isSubscribe = true
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(QiitaItemElement.self)
            .subscribe(onNext: { [weak self] element in self?.presenter.markAsRead(with: element.identifier) })
            .disposed(by: disposeBag)
        
        request()
        makeConstraints()
        view.updateConstraintsIfNeeded()
    }

    private func request() {
        presenter.request(.request)
    }

    @objc func refresh() {
        presenter.request(.refresh)
    }

    func paging() {
        presenter.request(.paging)
    }

    private func isReachedBottom(contentOffset: CGFloat, contentHeight: CGFloat) -> Bool {
        return (UIScreen.main.bounds.height + contentOffset) > contentHeight
    }

    private func makeConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

