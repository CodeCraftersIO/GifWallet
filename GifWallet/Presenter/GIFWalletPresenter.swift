//
//  Created by Pierluigi Cifani on 01/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import UIKit
import GifWalletKit
import Deferred

protocol GIFWalletPresenterType {
    func fetchData(handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void)
    func addNewGIFViewController(observer: GIFCreateObserver) -> UIViewController
    func detailsViewController(gifID: String) -> UIViewController
}

extension GIFWalletViewController {
    
    class Presenter: GIFWalletPresenterType {
        
        let dataStore: DataStore
        
        init(dataStore: DataStore) {
            self.dataStore = dataStore
        }
        
        func fetchData(handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void) {
            let fetchGifsTask = dataStore
                .loadAndMigrateIfNeeded()
                .andThen(upon: DispatchQueue.main) {
                    return self.dataStore.fetchGIFsSortedByCreationDate()
                }
                
            let mapVMsTask: Task<[GIFCollectionViewCell.VM]> = fetchGifsTask.map(upon: DispatchQueue.main) { (managedGIFs) in
                let vms: [GIFCollectionViewCell.VM] = managedGIFs.compactMap {
                    guard let giphyID = $0.giphyID,
                        let title = $0.title,
                        let urlString = $0.remoteURL,
                        let url = URL(string: urlString) else {
                            return nil
                    }
                    return GIFCollectionViewCell.VM(id: giphyID, title: title, url: url)
                }
                return vms
            }
            mapVMsTask.upon(DispatchQueue.main) { (result) in
                switch result {
                case .success(let vms):
                    handler(vms, nil)
                case .failure(let error):
                    handler(nil, error)
                }
            }
        }
        
        func addNewGIFViewController(observer: GIFCreateObserver) -> UIViewController {
            let presenter = GIFCreateViewController.Presenter.init(observer: observer)
            presenter.dataStore = dataStore
            return GIFCreateViewController.Factory.viewController(presenter: presenter)
        }
        
        func detailsViewController(gifID: String) -> UIViewController {
            let vc = GIFDetailsViewController.init(gifID: gifID)
            vc.presenter = GIFDetailsViewController.Presenter(dataStore: self.dataStore)
            return vc
        }
    }
    

    class MockDataPresenter: GIFWalletPresenterType {
                
        var delaySeconds: Int = 1
        
        func fetchData(handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delaySeconds)) {
                handler(MockLoader.mockCellVM(), nil)
            }
        }
        func addNewGIFViewController(observer: GIFCreateObserver) -> UIViewController {
            let presenter = GIFCreateViewController.MockPresenter(observer: observer)
            return GIFCreateViewController.Factory.viewController(presenter: presenter)
        }
        
        func detailsViewController(gifID: String) -> UIViewController {
            let vc = GIFDetailsViewController(gifID: gifID)
            vc.presenter = GIFDetailsViewController.MockDataPresenter()
            return vc
        }
    }
}

