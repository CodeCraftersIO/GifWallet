//
//  UIViewController+Wallet.swift
//  GifWallet
//
//  Created by Jordi Serra i Font on 03/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import UIKit

extension UIViewController {
    //Based on https://stackoverflow.com/a/28158013/1152289
    @objc func closeViewController(sender: Any?) {
        guard let presentingVC = targetViewController(forAction: #selector(closeViewController(sender:)), sender: sender) else { return }
        presentingVC.closeViewController(sender: sender)
    }
}

extension UINavigationController {
    @objc
    override func closeViewController(sender: Any?) {
        self.popViewController(animated: true)
    }
}
