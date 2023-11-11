//
//  RemoteFileManager.swift
//  Networking
//
//  Created by Mithesh on 11/11/23.
//

import Foundation

extension Notification.Name {
    static let fileDownloadCompleted = Notification.Name("file_download_completed")
}

class RemoteFileManager: NSObject {
    
    static var shared = RemoteFileManager()
    
    typealias DownloadFile = (url: String, fileName: String)

    private var pendingDownloads: [DownloadFile] = []
    
    private lazy var operationQueue: OperationQueue = {
        var operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 5
        return operationQueue
    }()
    
    func downloadFromURL(url: String,fileName: String) {
        
        pendingDownloads.append(DownloadFile(url,fileName))
        
        guard let url = URL(string: url) else { return }
        let urlSession = prepareURLSession(with: url.absoluteString)
        
        var urlRequest = URLRequest(url: url)
        urlSession.downloadTask(with: urlRequest).resume()
    }
    
    private func prepareURLSession(with identifier: String?) -> URLSession {
        if let uniqueIdentifier = identifier {
            let configuration = URLSessionConfiguration.background(withIdentifier: uniqueIdentifier)
            let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
            return urlSession
        }
        return URLSession.shared
    }
}

extension RemoteFileManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("location \(location)")
        
        let originalURL = downloadTask.originalRequest?.url?.absoluteString ?? ""
        
        guard let fileName = pendingDownloads.first(where: {$0.url == originalURL })?.fileName else {
            print("File not found")
            return
        }
        
        let attachmentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LOGIN_101")
            .appendingPathComponent("Attachment_Documents")
        
        if !FileManager.default.fileExists(atPath: attachmentDirectory.path) {
            do {
                try FileManager.default.createDirectory(atPath: attachmentDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Couldn't create document directory")
                return
            }
        }
        
        let destinationURL = attachmentDirectory.appendingPathComponent(fileName)

        try? FileManager.default.removeItem(at: destinationURL)

        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
        } catch {
            print("Copy Error: \(error.localizedDescription)")
            return
        }

        let userInfo: [String: Any] = [
            "location": destinationURL
        ]
        
        NotificationCenter.default.post(name: .fileDownloadCompleted, object: nil, userInfo: userInfo)
        pendingDownloads.removeAll()
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("Invalid")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Error: \(error?.localizedDescription ?? "Error")")
    }
}
