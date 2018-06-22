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

class ListViewController: UIViewController, FetchingPresentable, ErrorNotificationPresentable {
    private let disposeBag = DisposeBag()
    private let cellIdentifier = String(describing: type(of: ListViewCell.self))
    var bannerQueue: [NotificationBanner] = []
    let presenter: ListPresenterProtocol
    lazy var tableViewController:UITableViewController = {
        let tableViewController = UITableViewController(style: .plain)
        tableViewController.tableView.register(UINib(nibName: String(describing: ListViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableViewController.tableView.rowHeight = CGFloat(90.0)
        return tableViewController
    }()

    init(presenter: ListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableViewController.tableView)
        addChildViewController(tableViewController)
        tableViewController.didMove(toParentViewController: self)
        
        let viewState = presenter.stateVariable
            .asObservable()
            .observeOn(MainScheduler.instance)
        
        bindFetching(state: viewState, disposeBag: disposeBag) // FetchingPresentable
        bindErrorNotification(state: viewState, disposeBag: disposeBag) // ErrorNotificationPresentable

        viewState
            .map { $0.qiitaItems }
            .bind(to: tableViewController.tableView.rx.items(cellIdentifier: cellIdentifier, cellType: ListViewCell.self)) { (row, element, cell) in
                cell.bind(element: element)
                if cell.isSubscribe.reverse {
//                    cell.elementSubject
//                        .subscribe(onNext: { [weak self] in self?.presenter.switchingLike(with: $0) })
//                        .disposed(by: cell.disposeBag)
//                    cell.linkButtonOnTap
//                        .subscribe(onNext: { [weak self] in self?.presenter.switchingLike(with: $0) })
//                        .disposed(by: cell.disposeBag)
                    cell.likeButton.rx.tap
                        .subscribe(onNext: { [weak self] in self?.presenter.toggleLike(with: cell.identifier) })
                        .disposed(by: cell.disposeBag)
                    cell.isSubscribe = true
                }
            }
            .disposed(by: disposeBag)
        
        tableViewController.tableView.rx
            .modelSelected(QiitaItemElement.self)
            .subscribe(onNext: { [weak self] element in self?.presenter.markAsRead(with: element.identifier) })
            .disposed(by: disposeBag)
        
        presenter.request()

        makeConstraints()
        view.updateConstraintsIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func makeConstraints() {
        tableViewController.tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

