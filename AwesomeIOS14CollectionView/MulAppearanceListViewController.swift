//
//  MulAppearanceListViewController.swift
//  AwesomeIOS14CollectionView
//
//  Created by 吴迪玮 on 2020/6/27.
//

import UIKit

extension UICollectionLayoutListConfiguration.Appearance: CustomStringConvertible {
    public var description: String {
        var title: String = ""
        switch self {
        case .plain: title = "Plain"
        case .sidebarPlain: title = "Sidebar Plain"
        case .sidebar: title = "Sidebar"
        case .grouped: title = "Grouped"
        case .insetGrouped: title = "Inset Grouped"
        default: break
        }
        return title
    }
}

class MulAppearanceListViewController: UIViewController {
    
    private struct Item: Hashable {
        let title: String?
        private let identifier = UUID()
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Item>! = nil
    private var collectionView: UICollectionView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "List Appearances"
        configureHierarchy()
        configureDataSource()
    }
    
    private let appearances: [UICollectionLayoutListConfiguration.Appearance] = [.plain, .grouped, .insetGrouped, .sidebar, .sidebarPlain]
    
    private func appearance(_ section: Int) -> UICollectionLayoutListConfiguration.Appearance {
        section < appearances.count ? appearances[section] : .plain
    }
}

extension MulAppearanceListViewController {
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: self.appearance(section))
            config.headerMode = .firstItemInSection
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
}

extension MulAppearanceListViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            
            var content = cell.defaultContentConfiguration()
            if indexPath.section == 1 || indexPath.section == 2 { // .grouped, .insetGrouped:
                content.text = item.title?.localizedUppercase
            } else {
                content.text = item.title
            }
            cell.contentConfiguration = content
            
            cell.accessories = [.outlineDisclosure()]
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            
            if indexPath.section == 3 || indexPath.section == 4 { // .sidebar, .sidebarPlain:
                cell.accessories = []
            } else {
                cell.accessories = [.disclosureIndicator()]
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            if indexPath.item == 0 {
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        let sections = Array(0..<appearances.count)
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        for section in sections {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            let headerItem = Item(title: "Section \(appearance(section)) at \(section)")
            sectionSnapshot.append([headerItem])
            let items = Array(0..<3).map { Item(title: "Item \($0)") }
            sectionSnapshot.append(items, to: headerItem)
            sectionSnapshot.expand([headerItem])
            dataSource.apply(sectionSnapshot, to: section)
        }
    }
}
