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
    // Array of downloaded images
    private lazy var images: [UIImage] = []
    // instance of url Array
    private lazy var urls: [URL] = URLProvider.urls
    // Create a dispatch group to track when all images have been downloaded
    private  let group = DispatchGroup()
    // activity Indicator
    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        showActivityIndicator()
        downloadImages(urls: urls) { images in
            self.images = images // set the downloaded images on your data source
            self.collectionView.reloadData() // reload the collection view to display the images
        }
    }
    
    
}


// TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way
extension ViewController {
    func downloadImages(urls: [URL], completion: @escaping ([UIImage]) -> Void) {
        // Download each image asynchronously and add it to the images array
        for url in urls {
            self.group.enter()
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { self.group.leave() }
                
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("Error creating image from data")
                    return
                }
                
                self.images.append(image)
            }.resume()
        }
        
        // Notify the completion block when all images have been downloaded
        self.group.notify(queue: DispatchQueue.main) {
            
            completion(self.images)
            self.collectionView.reloadData()
            self.activityIndicatorView.stopAnimating()
        }
    }
}

// TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.
extension ViewController{
    
    func showActivityIndicator() {
        activityIndicatorView.color = .blue
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicatorView.startAnimating()
       }// Create a dispatch group to track when all images have been downloaded
}


// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        urls.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        self.group.wait()
        let image = images[indexPath.item]
        cell.imageView.image = image
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
func downloadImages(urls: [URL], completion: @escaping ([UIImage]) -> Void) {
    // Create a dispatch group to track when all images have been downloaded
    let group = DispatchGroup()
    
    var images: [UIImage] = []
    
    // Download each image asynchronously and add it to the images array
    for url in urls {
        group.enter()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { group.leave() }
            
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Error creating image from data")
                return
            }
            
            images.append(image)
        }.resume()
    }
    
    // Notify the completion block when all images have been downloaded
    group.notify(queue: DispatchQueue.main) {
        completion(images)
    }
}
