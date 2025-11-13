//
//  CollectionViewController.swift
//  ZoomTransitionIssue
//
//  Created by Thomas Heß on 13.11.25.
//

import UIKit

class CollectionViewController: UICollectionViewController {
	nonisolated enum Section {
		case main
	}
	
	nonisolated struct Item: Hashable {
		var identifier = UUID().uuidString

		func hash(into hasher: inout Hasher) {
			hasher.combine(identifier)
		}
		
		static func == (lhs: Item, rhs: Item) -> Bool {
			return lhs.identifier == rhs.identifier
		}
	}
	
	typealias ItemType = Item

	let reuseIdentifier = "Cell"
	var dataSource: UICollectionViewDiffableDataSource<Section, ItemType>! = nil
	var currentItems:[ItemType] = []

	let padding = CGFloat(20)
    let cellSize = CGFloat(100)

    required init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func loadView() {

        let layout = UICollectionViewCompositionalLayout { [weak self] section, environment in
            self?.layoutSection(sectionIndex: section, environment: environment)
        }

        collectionView = .init(frame: .zero, collectionViewLayout: layout)
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		
        collectionView.contentInset = .init(top: padding, left: padding, bottom: padding, right: padding)

		configureDataSource()
	}

	// MARK: - Layout

    private func layoutSection(sectionIndex: Int, // swiftlint:disable:this function_body_length
                               environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(cellSize),
                                              heightDimension: .absolute(cellSize))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10

        return section
    }

	// MARK: - Data Source
	
	func configureDataSource() {
		
		dataSource = UICollectionViewDiffableDataSource<Section, ItemType>(collectionView: collectionView) {
			(collectionView: UICollectionView, indexPath: IndexPath, item: ItemType) -> UICollectionViewCell? in
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath)
			
			var config = UIListContentConfiguration.cell()
			
			config.text = "Cell"
			config.textProperties.alignment = .center

			cell.contentConfiguration = config
			
			var bg = UIBackgroundConfiguration.listCell()
			bg.cornerRadius = CGFloat(8)
			bg.backgroundColor = .systemFill
			cell.backgroundConfiguration = bg
			
			return cell
		}
		
		collectionView.dataSource = dataSource
		
		refresh()
	}
		
	func snapshot() -> NSDiffableDataSourceSectionSnapshot<ItemType> {
		var snapshot = NSDiffableDataSourceSectionSnapshot<ItemType>()
		
		for _ in 0 ..< 9 {
			currentItems.append(ItemType())
		}

		snapshot.append(currentItems)
		
		return snapshot
	}
	
	func refresh() {
		guard let dataSource = collectionView.dataSource as? UICollectionViewDiffableDataSource<Section, ItemType> else { return }
		
		dataSource.apply(snapshot(), to: .main, animatingDifferences: false)
	}

    // MARK: - Selection

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = UIViewController()
        viewController.preferredTransition = .zoom(sourceViewProvider: { context in
            collectionView.cellForItem(at: indexPath)
        })
        present(viewController, animated: true)
    }
}
