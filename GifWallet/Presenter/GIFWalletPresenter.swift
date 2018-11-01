//
//  Created by Pierluigi Cifani on 01/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import Foundation

protocol GIFWalletPresenterType {
    func fetchData(handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void)
}

extension GIFWalletViewController {
    
    class MockDataPresenter: GIFWalletPresenterType {
                
        var delaySeconds: Int = 1
        
        func fetchData(handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delaySeconds)) {
                handler(MockLoader.mockCellVM(), nil)
            }
        }
    }
}

