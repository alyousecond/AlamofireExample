//
//  IndicatorFooterView.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/25.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import UIKit
import SnapKit

class IndicatorFooterView: UIView, IndicatorFooterViewProtocol {
    private var endImageView = UIImageView(image: UIImage(named: "circle.png"))
    private var indicatorView = UIActivityIndicatorView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareInitilize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareInitilize() {
        indicatorView.activityIndicatorViewStyle = .gray
        endImageView.isHidden = true
        
        addSubview(endImageView)
        addSubview(indicatorView)
        endImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.width.equalTo(20)
        }
        indicatorView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.width.equalTo(44)
        }
    }

    func toggleEndIndicator(isShowing: Bool) {
        if isShowing {
            endImageView.isHidden = false
            indicatorView.isHidden = true
        } else {
            endImageView.isHidden = true
            indicatorView.isHidden = false
        }
    }
    
    func startAnimating() {
        indicatorView.startAnimating()
    }
    
    func stopAnimating() {
        indicatorView.stopAnimating()
    }
}
