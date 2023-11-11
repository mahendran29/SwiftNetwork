//
//  ViewController.swift
//  Networking
//
//  Created by Mithesh on 11/11/23.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return imageView
    }()
    
    private(set) var filePath: URL? {
        didSet {
            loadThumbnail()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addNotificationObserver()
        let image1URL = "https://images.unsplash.com/photo-1575936123452-b67c3203c357?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW1hZ2V8ZW58MHx8MHx8fDA%3D"
        RemoteFileManager.shared.downloadFromURL(url: image1URL, fileName: "Testing")
    }
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(downloadDidCompleted(_:)), name: .fileDownloadCompleted, object: nil)
    }
    
    @objc private func downloadDidCompleted(_ notification: Notification) {
        if let fileLocation = notification.userInfo?["location"] as? URL {
            print("File Location: \(fileLocation)")
            filePath = fileLocation
        }
    }
    
    private func loadThumbnail() {
        
        guard let fileLocalPath = filePath, let imageData = try? Data(contentsOf: fileLocalPath) else {
            return
        }
        DispatchQueue.main.async {[weak self] in
            self?.imageView.image = UIImage(data: imageData)
        }
        
    }
}



