//
//  ListViewCell.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/21.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ListViewCell: UITableViewCell, Identifiable {
    var identifier = String(describing: type(of: ListViewCell.self)) // To make it easier to understand than empty characters

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    let disposeBag = DisposeBag()
    var isSubscribe = false

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareInitialize()
    }

    private func prepareInitialize() {
        // Initialization code
        accessoryType = .none
        separatorInset = .zero
    }

    func bind(element: QiitaItemElement) {
        identifier = element.identifier

        titleLabel.text = element.title
        nameLabel.text = element.user.id
        backgroundColor = element.unread.color
        profileImageView.kf.setImage(with: URL(string: element.user.profileImageUrl), placeholder: UIImage(named: "Loading"))
        likeButton.setImage(UIImage(named: "like")?.withRenderingMode(.alwaysTemplate), for: .normal)
        likeButton.imageView?.tintColor = element.like.color
    }
}
