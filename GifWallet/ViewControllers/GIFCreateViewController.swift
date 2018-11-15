//
//  Created by Pierluigi Cifani on 01/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import UIKit
import GifWalletKit

class GIFCreateViewController: UIViewController, UITableViewDataSource {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let saveButton = SaveButton()
    
    private let formValidator = GIFCreateFormValidator()
    private var lastValidationErrors: Set<GIFCreateFormValidator.ValidationError> = [] {
        didSet {
            saveButton.isEnabled = lastValidationErrors.isEmpty
        }
    }

    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(self.navigationController != nil)
        setup()
        layout()
    }

    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onSave() {
        self.dismissViewController()
    }
    
    //MARK: Private
    
    private func setup() {
        setupTableView()
        saveButton.addTarget(self, action: #selector(onSave), for: .touchDown)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissViewController))
    }
    
    private func setupTableView() {
        view.addAutolayoutView(tableView)
        tableView.pinToSuperview()
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(FormTableViewCell<GIFInputView>.self)
        tableView.registerReusableCell(FormTableViewCell<TextInputView>.self)
        tableView.registerReusableCell(FormTableViewCell<TagsInputView>.self)
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

    private func reloadSection(sectionToReload: GIFCreateFormValidator.Section) {
        guard let sectionToReloadIndex = formValidator.requiredSections.index(of: sectionToReload) else {
            return
        }
        tableView.performBatchUpdates({
            tableView.reloadSections([sectionToReloadIndex], with: .automatic)
        }, completion: nil)
    }

    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return formValidator.requiredSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = formValidator.requiredSections[indexPath.section]
        let tableViewCell: UITableViewCell = {
            switch section {
            case .gifURL:
                let shouldShowWarning = lastValidationErrors.contains(.gifNotProvided)
                let cell: FormTableViewCell<GIFInputView> = tableView.dequeueReusableCell(indexPath: indexPath)
                cell.configureFor(vm: FormTableViewCell<GIFInputView>.VM(inputVM: GIFInputView.VM(id: formValidator.form.gifID, url: formValidator.form.gifURL), showsWarning: shouldShowWarning))
                cell.formInputView.delegate = self
                return cell
            case .title:
                let shouldShowWarning = lastValidationErrors.contains(.titleNotProvided)
                let cell: FormTableViewCell<TextInputView> = tableView.dequeueReusableCell(indexPath: indexPath)
                cell.configureFor(vm: FormTableViewCell<TextInputView>.VM(inputVM: TextInputView.VM(text: self.formValidator.form.title), showsWarning: shouldShowWarning))
                cell.formInputView.placeholder = "Enter the Title"
                cell.formInputView.delegate = self
                cell.formInputView.tag = TextInputTags.title.rawValue
                return cell
            case .subtitle:
                let shouldShowWarning = lastValidationErrors.contains(.subtitleNotProvided)
                let cell: FormTableViewCell<TextInputView> = tableView.dequeueReusableCell(indexPath: indexPath)
                cell.configureFor(vm: FormTableViewCell<TextInputView>.VM(inputVM: TextInputView.VM(text: self.formValidator.form.subtitle), showsWarning: shouldShowWarning))
                cell.formInputView.placeholder = "Enter the Subtitle"
                cell.formInputView.delegate = self
                cell.formInputView.tag = TextInputTags.subtitle.rawValue
                return cell
            case .tags:
                let shouldShowWarning = lastValidationErrors.contains(.tagsNotProvided)
                let cell: FormTableViewCell<TagsInputView> = tableView.dequeueReusableCell(indexPath: indexPath)
                cell.configureFor(vm: FormTableViewCell<TagsInputView>.VM(inputVM: TagsInputView.VM(tags: formValidator.form.tags), showsWarning: shouldShowWarning))
                cell.formInputView.delegate = self
                return cell
            }
        }()
        return tableViewCell

    }
}
    
extension GIFCreateViewController {
    enum Factory {
        static func viewController() -> UIViewController {
            let createVC = GIFCreateViewController()
            let navController = UINavigationController(rootViewController: createVC)
            navController.modalPresentationStyle = .formSheet
            return navController
        }
    }

    enum TextInputTags: Int {
        case title = 100
        case subtitle = 101
    }
}

extension GIFCreateViewController: GIFInputViewDelegate, TextInputViewDelegate, TagsInputViewDelegate, GIFSearchDelegate {
    
    func didModifyText(text: String, textInputView: TextInputView) {
        guard let textInput = TextInputTags(rawValue: textInputView.tag) else { return }
        let sectionToReload: GIFCreateFormValidator.Section
        switch textInput {
        case .title:
            formValidator.form.title = text
            sectionToReload = .title
        case .subtitle:
            formValidator.form.subtitle = text
            sectionToReload = .subtitle
        }
        updateErrors()
        reloadSection(sectionToReload: sectionToReload)
    }

    func didAddTag(newTag: String, tagsInputView: TagsInputView) {
        let cleanTag = newTag.trimmingCharacters(in: [" "])
        guard !cleanTag.isEmpty else { return }
        formValidator.form.tags.append(cleanTag)
        updateErrors()
        reloadSection(sectionToReload: .tags)
    }

    func didSelectGIF(id: String, url: URL) {
        formValidator.form.gifURL = url
        formValidator.form.gifID = id
        updateErrors()
        reloadSection(sectionToReload: .gifURL)
    }

    func didTapGIFInputView(_ inputView: GIFInputView) {
        let searchVC = GIFSearchViewController()
        searchVC.delegate = self
        show(searchVC, sender: nil)
    }

    private func updateErrors() {
        if case .error(let errors) = self.formValidator.validateForm() {
            lastValidationErrors = errors
        } else {
            lastValidationErrors.removeAll()
        }
    }
}
