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

class ListViewController: UIViewController, RefreshingPresentable, ErrorNotificationPresentable {
    var refreshControl = UIRefreshControl() // RefreshingPresentable
    var refreshControlView: UIScrollView { return tableViewController.tableView  } // RefreshingPresentable
    var bannerQueue: [NotificationBanner] = [] // ErrorNotificationPresentable

    private let presenter: ListPresenterProtocol
    private let disposeBag = DisposeBag()
    private let cellIdentifier = String(describing: type(of: ListViewCell.self))
    private lazy var tableViewController: UITableViewController = {
        let tableViewController = UITableViewController(style: .plain)
        tableViewController.tableView.register(UINib(nibName: String(describing: ListViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableViewController.tableView.rowHeight = CGFloat(90.0)
        return tableViewController
    }()
    private var tableView: UITableView { return tableViewController.tableView }

    init(presenter: ListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        addChildViewController(tableViewController)
        tableViewController.didMove(toParentViewController: self)
        
        let viewState = presenter.stateVariable
            .asObservable()
            .observeOn(MainScheduler.instance)

        bindRefreshing(state: viewState, disposeBag: disposeBag) // RefreshingPresentable
        bindErrorNotification(state: viewState, disposeBag: disposeBag) // ErrorNotificationPresentable

        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged) // Required for refresh controll

        viewState
            .map { $0.qiitaItems }
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

    private func makeConstraints() {
        tableViewController.tableView.snp.makeConstraints {
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

