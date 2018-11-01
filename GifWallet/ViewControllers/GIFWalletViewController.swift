//
//  Created by Pierluigi Cifani on 02/03/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//
import UIKit
import SDWebImage

class GIFWalletViewController: UIViewController, UICollectionViewDataSource {

    var presenter: GIFWalletPresenterType = GIFWalletViewController.MockDataPresenter()

    private var collectionView: UICollectionView!
    private var collectionViewLayout: UICollectionViewFlowLayout!
    private var data: [GIFCollectionViewCell.VM]?
    
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
    
    private func fetchData() {
        self.data = presenter.fetchData()
    }
    
    private func setupCollectionView() {
        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.addSubview(collectionView)
        collectionView.pinToSuperview()
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        
        collectionView.register(GIFCollectionViewCell.self, forCellWithReuseIdentifier: "GIFCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GIFCollectionViewCell", for: indexPath) as? GIFCollectionViewCell else {
            fatalError()
        }
        cell.configureFor(vm: data![indexPath.item])
        return cell
    }

}
