//
//  ViewController.swift
//  miniBootcampChallenge
//

import UIKit

class ViewController: UICollectionViewController {
    
    private struct Constants {
        static let title = "Mini Bootcamp Challenge"
        static let cellID = "imageCell"
        static let cellSpacing: CGFloat = 1
        static let columns: CGFloat = 3
        static var cellSize: CGFloat?
    }
    
    private lazy var urls: [URL] = URLProvider.urls
    private var downloadedImages: [UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        loadImages()
    }
    
    private func showLoader() {
        let loader = Loader(frame: CGRect.zero)
        loader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loader)
        
        NSLayoutConstraint.activate([
            loader.topAnchor.constraint(equalTo: view.topAnchor),
            loader.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loader.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        loader.activityIndicator.startAnimating()
    }
    
    private func hideLoader() {
        view.subviews.forEach { view in
            if view is Loader {
                view.removeFromSuperview()
            }
        }
    }
    
    private func loadImages() {
        showLoader()
        downloadedImages = Array<UIImage?>(repeating: nil, count: urls.count)
        let dispatchGroup = DispatchGroup()
        for (index, url) in urls.enumerated() {
            loadImage(url, dispatchGroup: dispatchGroup) { [weak self] image in
                if let image {
                    self?.downloadedImages[index] = image
                }
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.hideLoader()
            self?.collectionView.reloadData()
        }
    }
    
    private func loadImage(_ url: URL, dispatchGroup: DispatchGroup?, completion: @escaping (UIImage?) -> ()) {
        dispatchGroup?.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
                completion(nil)
                dispatchGroup?.leave()
                return
            }
            completion(image)
            dispatchGroup?.leave()
        }
    }

}


// TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way

// TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.


// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        downloadedImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        
        let image = downloadedImages[indexPath.row]
        cell.display(image)
        
        return cell
    }
}


// MARK: - UICollectionView FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Constants.cellSize == nil {
          let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (Constants.columns * Constants.cellSpacing - 1)
            Constants.cellSize = (view.frame.size.width - emptySpace) / Constants.columns
        }
        return CGSize(width: Constants.cellSize!, height: Constants.cellSize!)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
}
