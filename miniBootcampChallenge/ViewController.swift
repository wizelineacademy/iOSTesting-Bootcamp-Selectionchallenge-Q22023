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
    // Array of downloaded imagesvar images: [UIImage] = []
    private lazy var images: [UIImage] = []
    // instance of url Array
    private lazy var urls: [URL] = URLProvider.urls
    // Create a dispatch group to track when all images have been downloaded
    private  let group = DispatchGroup()
    // activity Indicator
    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .large)
     
     override func viewDidLoad()   {
         print(" aqui entro")
        super.viewDidLoad()
        title = Constants.title
        showActivityIndicator()
         Task{
              
              await downloadImages(urls: urls)
             func notifyCollectionView()-> Bool{
                 true
         }
         }
    }
    
}


// TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way
extension ViewController {
    
    func downloadImages(urls: [URL]) async  -> Void {
        self.group.enter()
        print("si me llamaron")
        // Download each image asynchronously and add it to the images array
        
        for url in urls {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    print("Error creating image from data")
                    continue
                }
                self.images.append(image)
            } catch {
                print("Error downloading image: \(error.localizedDescription)")
                
            }
            print("apenas termine")
            
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
        

        return urls.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)  -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        let image = self.images[indexPath.row]
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

extension ViewController{
    enum FetchError: Error {
        case badID
        case imageNotAbleToRender
    }
}
