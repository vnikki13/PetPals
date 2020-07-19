//
//  StorageManager.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/14/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias DownloadPictureCompletion = (Result<String, Error>) -> Void
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func uploadPicture(with data: Data, filename: String, completion: @escaping (Bool) -> Void) {
        storage.child("images/\(filename)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                // failed
                print("Failed to upload data to firebase for picture")
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    public func downloadPicture(from filename: String, completion: @escaping DownloadPictureCompletion) {
        self.storage.child("images/\(filename)").downloadURL(completion: { url, error in
            guard let url = url else {
                print("Failed to get download url")
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }

            let urlString = url.absoluteString
            print("download url returned: \(urlString)")
            completion(.success(urlString))
        })
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        })
    }
}


