//
//  Created by Pierluigi Cifani on 15/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import Deferred
import GifWalletKit

protocol GIFCreateObserver: class {
    func didCreateGIF()
}

protocol GIFCreatePresenterType {
    init(observer: GIFCreateObserver)
    func createGIF(giphyID: String, title: String, subtitle: String, url: URL, tags: Set<String>)
}

extension GIFCreateViewController {
    
    class Presenter: GIFCreatePresenterType {

        weak var observer: GIFCreateObserver?
        var dataStore: DataStore!
        
        required init(observer: GIFCreateObserver) {
            self.observer = observer
        }
        
        func createGIF(giphyID: String, title: String, subtitle: String, url: URL, tags: Set<String>) {
            let task = dataStore.createGIF(giphyID: giphyID, title: title, subtitle: subtitle, url: url, tags: tags)
            task.uponSuccess(on: .main) { () in
                self.observer?.didCreateGIF()
            }
        }
    }

    class MockPresenter: GIFCreatePresenterType {
        
        var delaySeconds: Int = 1
        
        required init(observer: GIFCreateObserver) {

        }

        func createGIF(giphyID: String, title: String, subtitle: String, url: URL, tags: Set<String>) {

        }
    }
}

