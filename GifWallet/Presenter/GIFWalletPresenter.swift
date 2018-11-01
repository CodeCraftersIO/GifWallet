//
//  Created by Pierluigi Cifani on 01/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import Foundation

protocol GIFWalletPresenterType {
    func fetchData() -> [GIFCollectionViewCell.VM]
}

extension GIFWalletViewController {
    
    class MockDataPresenter: GIFWalletPresenterType {
        
        var delaySeconds: Int = 1
        
        func fetchData() -> [GIFCollectionViewCell.VM] {
            return MockLoader.mockCellVM()
        }        
    }
}

