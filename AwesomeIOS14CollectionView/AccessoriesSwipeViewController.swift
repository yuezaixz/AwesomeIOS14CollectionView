//
//  AccessoriesSwipeViewController.swift
//  AwesomeIOS14CollectionView
//
//  Created by 吴迪玮 on 2020/6/27.
//

import UIKit

class AccessoriesSwipeViewController: UIViewController {
    
    typealias Section = Emoji.Category
    
    struct Item: Hashable {
        let title: String
        let emoji: Emoji
        init(emoji: Emoji, title: String) {
            self.emoji = emoji
            self.title = title
        }
        private let identifier = UUID()
    }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureNavItem()
        configureHierarchy()
        configureDataSource()
        applyInitialSnapshots()
        updateBarButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = self.collectionView.indexPathsForSelectedItems?.first {
            if let coordinator = self.transitionCoordinator {
                coordinator.animate(alongsideTransition: { context in
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                }) { (context) in
                    if context.isCancelled {
                        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    }
                }
            } else {
                self.collectionView.deselectItem(at: indexPath, animated: animated)
            }
        }
    }
    
    private var isEditingCollection: Bool = false
        
    @objc
    private func editAction() {
        isEditingCollection = !isEditingCollection
        collectionView.isEditing = isEditing
        updateBarButtonItem()
    }
    
    private func updateBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: isEditingCollection ? "完成" : "编辑", style: .plain, target: self, action: #selector(editAction))
    }
}

extension AccessoriesSwipeViewController {
    
    func configureNavItem() {
        navigationItem.title = "Emoji Explorer - List"
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    func leadingSwipeActionConfigurationForListCellItem(_ item: Emoji) -> UISwipeActionsConfiguration? {
        let isStarred = item.category == .recents
        let starAction = UIContextualAction(style: .normal, title: nil) {
            (_, _, completion) in
            
            completion(true)
        }
        starAction.image = UIImage(systemName: isStarred ? "star.slash" : "star.fill")
        starAction.backgroundColor = .systemBlue
        let destructiveAction = UIContextualAction(style: .destructive, title: "删除") { (_, _, completion) in
            completion(true)
        }
        starAction.backgroundColor = .systemPink
        return UISwipeActionsConfiguration(actions: [starAction, destructiveAction])
    }
    
    func configureDataSource() {

        // list cell
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Emoji> { (cell, indexPath, emoji) in
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = emoji.text
            contentConfiguration.secondaryText = String(describing: emoji.category)
            cell.contentConfiguration = contentConfiguration
            
            cell.leadingSwipeActionsConfiguration = self.leadingSwipeActionConfigurationForListCellItem(emoji)
            cell.accessories = [.disclosureIndicator(), .delete(displayed: .always)]
        }
        
        // data source
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item.emoji)
        }
    }
    
    func applyInitialSnapshots() {

        for category in Emoji.Category.allCases.reversed() {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            let items = category.emojis.map { Item(emoji: $0, title: String(describing: category)) }
            sectionSnapshot.append(items)
            dataSource.apply(sectionSnapshot, to: category, animatingDifferences: false)
        }
    }
}

extension AccessoriesSwipeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
            collectionView.deselectItem(at: indexPath, animated: true)
    }
}

struct Emoji: Hashable {

    enum Category: CaseIterable, CustomStringConvertible {
        case recents, smileys, nature, food, activities, travel, objects, symbols
    }
    
    let text: String
    let title: String
    let category: Category
    private let identifier = UUID()
}

extension Emoji.Category {
    
    var description: String {
        switch self {
        case .recents: return "Recents"
        case .smileys: return "Smileys"
        case .nature: return "Nature"
        case .food: return "Food"
        case .activities: return "Activities"
        case .travel: return "Travel"
        case .objects: return "Objects"
        case .symbols: return "Symbols"
        }
    }
    
    var emojis: [Emoji] {
        switch self {
        case .recents:
            return [
                Emoji(text: "🤣", title: "Rolling on the floor laughing", category: self),
                Emoji(text: "🥃", title: "Whiskey", category: self),
                Emoji(text: "😎", title: "Cool", category: self),
                Emoji(text: "🏔", title: "Mountains", category: self),
                Emoji(text: "⛺️", title: "Camping", category: self),
                Emoji(text: "⌚️", title: " Watch", category: self),
                Emoji(text: "💯", title: "Best", category: self),
                Emoji(text: "✅", title: "LGTM", category: self)
            ]

        case .smileys:
            return [
                Emoji(text: "😀", title: "Happy", category: self),
                Emoji(text: "😂", title: "Laughing", category: self),
                Emoji(text: "🤣", title: "Rolling on the floor laughing", category: self)
            ]
            
        case .nature:
            return [
                Emoji(text: "🦊", title: "Fox", category: self),
                Emoji(text: "🐝", title: "Bee", category: self),
                Emoji(text: "🐢", title: "Turtle", category: self)
            ]
            
        case .food:
            return [
                Emoji(text: "🥃", title: "Whiskey", category: self),
                Emoji(text: "🍎", title: "Apple", category: self),
                Emoji(text: "🍑", title: "Peach", category: self)
            ]
        case .activities:
            return [
                Emoji(text: "🏈", title: "Football", category: self),
                Emoji(text: "🚴‍♀️", title: "Cycling", category: self),
                Emoji(text: "🎤", title: "Singing", category: self)
            ]

        case .travel:
            return [
                Emoji(text: "🏔", title: "Mountains", category: self),
                Emoji(text: "⛺️", title: "Camping", category: self),
                Emoji(text: "🏖", title: "Beach", category: self)
            ]

        case .objects:
            return [
                Emoji(text: "🖥", title: "iMac", category: self),
                Emoji(text: "⌚️", title: " Watch", category: self),
                Emoji(text: "📱", title: "iPhone", category: self)
            ]

        case .symbols:
            return [
                Emoji(text: "❤️", title: "Love", category: self),
                Emoji(text: "☮️", title: "Peace", category: self),
                Emoji(text: "💯", title: "Best", category: self)
            ]

        }
    }
}
