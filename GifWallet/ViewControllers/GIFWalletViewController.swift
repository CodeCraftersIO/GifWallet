//
//  Created by Pierluigi Cifani on 02/03/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//
import UIKit
import SDWebImage

class GIFWalletViewController: UIViewController {

    var presenter: GIFWalletPresenterType = GIFWalletViewController.MockDataPresenter()

    var collectionView: UICollectionView!
    var dataSource: CollectionViewStatefulDataSource<GIFCollectionViewCell>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        assert(self.navigationController != nil)
        title = "Your GIFs"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewGif))
        setupCollectionView()
        fetchData()
    }
    
    @objc func addNewGif() {
        let createVC = GIFCreateViewController.Factory.viewController()
        self.present(createVC, animated: true, completion: nil)
    }
    
    private func setupCollectionView() {
        let collectionViewLayout = ColumnFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.addSubview(collectionView)
        collectionView.pinToSuperview()
        collectionView.backgroundColor = .white
        dataSource = CollectionViewStatefulDataSource<GIFCollectionViewCell>(
            state: .loading,
            collectionView: collectionView
        )
    }
    
    private func fetchData() {
        dataSource.state = .loading
        self.presenter.fetchData { (data, error) in
            guard error == nil, let data = data else {
                self.dataSource.state = .failure(error: error!)
                return
            }
            self.dataSource.state = .loaded(data: data)
        }
    }
}
