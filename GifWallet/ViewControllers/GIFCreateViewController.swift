//
//  Created by Pierluigi Cifani on 01/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import UIKit

class GIFCreateViewController: UIViewController, UITableViewDataSource {
    
    enum Factory {
        static func viewController() -> UIViewController {
            let createVC = GIFCreateViewController()
            let navController = UINavigationController(rootViewController: createVC)
            navController.modalPresentationStyle = .formSheet
            return navController
        }
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let saveButton = SaveButton()

    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissViewController))
        setupTableView()
        layout()
    }
    
    private func setupTableView() {
        view.addAutolayoutView(tableView)
        tableView.pinToSuperview()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReuseID")
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func layout() {
        view.addAutolayoutView(saveButton)
        NSLayoutConstraint.activate([
            saveButton.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            saveButton.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            saveButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: saveButton.frame.size.height,
            right: 0
        )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseID", for: indexPath)
        cell.textLabel?.text = "Hello world"
        return cell
    }
}
