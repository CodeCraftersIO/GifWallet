//
//  Created by Jordi Serra i Font on 18/3/18.
//  Copyright © 2018 Code Crafters. All rights reserved.
//

import UIKit
import FLAnimatedImage

protocol GIFSearchDelegate: class {
    func didSelectGIF(id: String, url: URL)
}

final class GIFSearchViewController: UIViewController {

    private enum Constants {
        static let cellHeight: CGFloat = 200
    }

    var searchController: UISearchController!

    var collectionView: UICollectionView!
    var collectionViewLayout: UICollectionViewFlowLayout!
    var dataSource: CollectionViewStatefulDataSource<GIFCollectionViewCell>!
    let presenter: GIFSearchPresenterType

    weak var delegate: GIFSearchDelegate?

    init(presenter: GIFSearchPresenterType = MockDataPresenter()) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(self.navigationController != nil)

        view.backgroundColor = .white

        setup()
        layout()
    }

    private func setup() {
        setupCollectionView()
        setupSearchBar()

        dataSource = CollectionViewStatefulDataSource<GIFCollectionViewCell>(
            state: .loading,
            collectionView: collectionView)

        fetchData()
    }

    private func fetchData() {
        let searchTerm = self.searchController.searchBar.text ?? ""

        self.dataSource.state = .loading
        if searchTerm.isEmpty {
            presenter.trendingGifs { (results, error) in
                if let error = error {
                    self.dataSource.state = .failure(error: error)
                } else {
                    self.dataSource.state = .loaded(data: results!)
                }
            }
        }
        else {
            presenter.searchGifs(term: searchTerm) { (results, error) in
                if let error = error {
                    self.dataSource.state = .failure(error: error)
                } else {
                    self.dataSource.state = .loaded(data: results!)
                }
            }
        }
    }

    private func setupCollectionView() {
        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.addSubview(collectionView)
        collectionView.pinToSuperview()
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        configureCollectionViewLayout(
            forHorizontalSizeClass: self.traitCollection.horizontalSizeClass,
            targetSize: self.view.frame.size
        )
    }

    private func configureCollectionViewLayout(
        forHorizontalSizeClass horizontalSizeClass: UIUserInterfaceSizeClass,
        targetSize: CGSize) {
        let numberOfColumns: Int
        switch horizontalSizeClass {
        case .regular:
            numberOfColumns = (targetSize.width > targetSize.height) ? 3 : 2
        default:
            numberOfColumns = 1
        }
        collectionViewLayout.itemSize = CGSize(
            width: self.view.frame.width / CGFloat(numberOfColumns),
            height: Constants.cellHeight
        )
    }

    private func setupSearchBar() {
        searchController = UISearchController(searchResultsController: nil)

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search a GIF..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = true
    }

    private func layout() {
        view.addAutolayoutView(collectionView)
        collectionView.pinToSuperview()
    }
}

extension GIFSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        fetchData()
    }
}

extension GIFSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case .loaded(let data) = self.dataSource.state else {
            return
        }
        let gifVM = data[indexPath.item]
        delegate?.didSelectGIF(id: gifVM.id, url: gifVM.url)
        self.closeViewController(sender: nil)
    }
}
