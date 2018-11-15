//
//  GIFCreateViewControllerTests.swift
//  GifWalletTests
//
//  Created by Jordi Serra i Font on 07/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import XCTest
@testable import GifWallet

class GIFCreateViewControllerTests: SnapshotTest {

    func testGIFCreateViewController() {
        let observer = MockObserver()
        let vc = GIFCreateViewController.Factory.viewController(presenter: GIFCreateViewController.MockPresenter(observer: observer))
        waitABitAndVerify(viewController: vc)
    }
}

class MockObserver: GIFCreateObserver {
    func didCreateGIF() {
        
    }
}
