//
//  Created by Jordi Serra i Font on 18/3/18.
//  Copyright © 2018 Code Crafters. All rights reserved.
//

import Deferred
import GifWalletKit

protocol GIFSearchPresenterType {
    func trendingGifs(handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void)
    func searchGifs(term: String, handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void)
}

extension GIFSearchViewController {

    class Presenter: GIFSearchPresenterType {
        
        let apiClient = GiphyAPIClient()

        func trendingGifs(handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void) {
            performRequest(.trending, handler: handler)
        }
        
        func searchGifs(term: String, handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void) {
            performRequest(.search(term: term), handler: handler)
        }
        
        private enum Request {
            case trending
            case search(term: String)
        }
        
        private func performRequest(_ request: Request, handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void) {
            let task: Task<Giphy.Responses.Page> = {
                switch request {
                case .trending:
                    return self.apiClient.fetchTrending()
                case .search(let term):
                    return self.apiClient.searchGif(term: term)
                }
            }()
            let vmTask: Task<[GIFCollectionViewCell.VM]> = task.map(upon: .main, transform: { (page)  in
                return page.data.compactMap({ (gif)  in
                    return GIFCollectionViewCell.VM(id: gif.id, title: gif.title, url: gif.url)
                })
            })
            vmTask.upon(.main) { (result) in
                switch result {
                case .failure(let error):
                    handler(nil, error)
                case .success(let value):
                    handler(value, nil)
                }
            }
        }
    }
    
    class MockDataPresenter: GIFSearchPresenterType {

        var delaySeconds: Int = 1

        func trendingGifs(handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delaySeconds)) {
                handler(MockLoader.mockCellVM(), nil)
            }
        }

        func searchGifs(term: String, handler: @escaping ([GIFCollectionViewCell.VM]?, Swift.Error?) -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delaySeconds)) {
                handler(MockLoader.mockCellVM(), nil)
            }
        }
    }
}
