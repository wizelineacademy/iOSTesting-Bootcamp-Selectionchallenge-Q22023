//
//  ViewController.swift
//  miniBootcampChallenge
//

import UIKit

class ViewController: UICollectionViewController {
    
    var activityView: UIActivityIndicatorView?
    
    private struct Constants {
        static let title = "Mini Bootcamp Challenge"
        static let cellID = "imageCell"
        static let cellSpacing: CGFloat = 1
        static let columns: CGFloat = 3
        static var cellSize: CGFloat?
    }
    
//    private lazy var urls: [URL] = URLProvider.urls
    ///This manager will help us to download the data of all the images from the web
    var manager = ImagesManager()
    
    /// - This array will save all images and will help to load the collection with the images
    var images: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        
        ///- Option 1 with delegation pattern and async await
//        manager.delegate = self
//        getImages()
        
        ///- Option 2 with escaping closure
        getImagesWithClosure()
        
    }
    
    private func getImages(){
        ///- Show activity indicator
        self.showActivityIndicator()
        Task {
            await manager.getImages()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "OK", style: .default) { _ in
            //Do something -
        }
        alert.addAction(acceptAction)
        present(alert, animated: true)
    }

}


// TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way
// MARK:  Extension to download all images with URLSession of native way
extension UIImageView {
    func loadFrom(url: URL) {
        
        let session = URLSession(configuration: .default)
        
        let tarea = session.dataTask(with: url) { datos, _, error in
            if let datosSeguros = datos {
                if let loadedImage = UIImage(data: datosSeguros) {
                    DispatchQueue.main.async {
                        self.image = loadedImage
                    }
                }
            }
        }
        tarea.resume()
    }
}


///- We can use two ways in the solution 2 to download the data and this is option 1
extension ViewController: ImageManagerDelegate {
    func showImages(listOfImages: [String]) {
        self.images = listOfImages
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            /// - Hide the loader
            self.hideActivityIndicator()
        }
    }
    
    func showError(wichError: Errors) {
        DispatchQueue.main.async {
            self.showAlert(title: "Error", message: wichError.localizedDescription)
        }
    }
}


// TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.

///- Loader with UIActivityIndicatorView
extension ViewController {
    
    ///- This function implements an escaping closure to download the images and it return 2 optionals ; list of urls and posible error
    private func getImagesWithClosure(){
        ///- Show the loader
        self.showActivityIndicator()
        ///weak self to avoid retain cycles
        manager.getImagesClosure { [weak self] listOfImages, error in
            ///Handle possible errors
            if let error = error {
                ///- If there are an error, will show it
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
            
            if let listOfImages = listOfImages {
                ///- It assign the list to the array
                self?.images = listOfImages
                DispatchQueue.main.async {
                    ///- Reload the collection with the fresh data on the main thread to avoid screen freeze
                    self?.collectionView.reloadData()
                    ///Hide the loader
                    self?.hideActivityIndicator()
                }
            }
            
            
        }
    }
    
    func showActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    func hideActivityIndicator(){
        if (activityView != nil){
            activityView?.stopAnimating()
        }
    }
}

// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /// - Total of images saved in array
        images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        
        ///- Solution 1:
        /// - * select the URL and it will send to func of extension wich will return the image
        //let url = urls[indexPath.row]
        //cell.imageView.loadFrom(url: url)
        
        /// - Use the extension to send the url and it will return us the downloaded image
        cell.imageView.loadFrom(URLAddress: images[indexPath.row])
        
        return cell
    }
}

// MARK:  Extension to download all images with URLSession of native way
extension UIImageView {
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let tarea = session.dataTask(with: url) { datos, _, error in
            if let datosSeguros = datos {
                if let loadedImage = UIImage(data: datosSeguros) {
                    DispatchQueue.main.async {
                        self.image = loadedImage
                    }
                }
            }
        }
        tarea.resume()
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
