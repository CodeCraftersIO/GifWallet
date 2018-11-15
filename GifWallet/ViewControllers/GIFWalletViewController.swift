//
//  Created by Pierluigi Cifani on 02/03/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//
import UIKit
import SDWebImage

class GIFWalletViewController: UIViewController {
    
    private enum Constants {
        static let cellHeight: CGFloat = 200
    }

    var presenter: GIFWalletPresenterType = GIFWalletViewController.MockDataPresenter()

    var collectionView: UICollectionView!
    var dataSource: CollectionViewStatefulDataSource<GIFCollectionViewCell>!
    
    init(presenter: GIFWalletPresenterType = MockDataPresenter()) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        assert(self.navigationController != nil)
        title = "Your GIFs"
        setup()
        fetchData()
    }

    private func setup() {
        setupCollectionView()
        dataSource = CollectionViewStatefulDataSource<GIFCollectionViewCell>(
            state: .loading, collectionView: collectionView
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewGif))
    }
    
    @objc func addNewGif() {
        let createVC = presenter.addNewGIFViewController(observer: self)
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
        self.dataSource.state = .loading
        presenter.fetchData { [weak self] (results, error) in
            guard let `self` = self else { return }
            guard error == nil else {
                self.dataSource.state = .failure(error: error!)
                return
            }
            
            self.dataSource.state = .loaded(data: results!)
        }
    }
}

extension GIFWalletViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case .loaded(let data) = self.dataSource.state else {
            return
        }
        let gifVM = data[indexPath.item]
        let vc = GIFDetailsViewController(gifID: gifVM.id)
        self.show(vc, sender: nil)
    }
}

extension GIFWalletViewController: GIFCreateObserver {
    func didCreateGIF() {
        self.dismiss(animated: true) {
            self.fetchData()
        }
    }
}
