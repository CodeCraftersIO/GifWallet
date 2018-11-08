//
//  SaveButton.swift
//  GifWallet
//
//  Created by Jordi Serra i Font on 07/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import UIKit

final class SaveButton: UIButton {
    
    private enum Constants {
        static let padding: CGFloat = 10
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = UIColor.GifWallet.brand
        setTitle("Save", for: .normal)
    }
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        self.titleEdgeInsets = UIEdgeInsets.init(
            top: self.safeAreaInsets.bottom / 2 ,
            left: 0,
            bottom: 0,
            right: 0
        )
        self.contentEdgeInsets = UIEdgeInsets.init(
            top: self.safeAreaInsets.top + Constants.padding,
            left: self.safeAreaInsets.left + Constants.padding,
            bottom: self.safeAreaInsets.bottom + Constants.padding,
            right: self.safeAreaInsets.right + Constants.padding
        )
    }

}
