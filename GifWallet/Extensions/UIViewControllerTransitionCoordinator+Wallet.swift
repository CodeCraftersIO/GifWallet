//
//  UIViewControllerTransitionCoordinator+Wallet.swift
//  GifWallet
//
//  Created by Jordi Serra i Font on 03/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import UIKit
import ObjectiveC

private var xoAssociationKey: UInt8 = 0

extension UIViewControllerTransitionCoordinator {
    var newCollection: UITraitCollection? {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey) as? UITraitCollection
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
