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
    
    // /images/vnikki13@gmail.com_profile_picture.png
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    /// Uploads picture to firestore
//    var urlStrings = [String]()
    
    
//    public func uploadProfilePicture(with dataList: [Data], filename: String, completion: @escaping UploadPictureCompletion) {
//        
//        var urlString = String()
//        var count = 0
//        for data in dataList { (data: Data) -> String in
//            count += 1
//            storage.child("images/vnikki13@gmail.com/_\(count)_\(filename)").putData(data, metadata: nil, completion: { metadata, error in
//                guard error == nil else {
//                    // failed to upload
//                    print("Failed to upload photo data to firebase")
//                    completion(.failure(StorageErrors.failedToUpload))
//                    return
//                }
//                
//                print("this is a break")
//                
//                let fileReference = self.storage.child("images/vnikki13@gmail.com/_\(count)_\(filename)")
//                fileReference.downloadURL(completion: { url, error in
//                    guard let url = url?.absoluteString, error == nil else {
//                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
//                        return
//                    }
//                    
//                    print("URL STRING")
//                    urlString = url
//                })
//                
//            })
//            return "hello world"
//        })
//        
//        print("writing data to firebase")
//        completion(.success(urlStrings))
//        
//        
//        var allPhotoUrls = [String]
//        
//        // wating for this
//        let downloadGroup = DispatchGroup()
//        // loop through data list
//        for data in dataList {
//            
//            downloadGroup.enter()
//            
//            let fileReference = self.storage.child("images/vnikki13@gmail.com/_\(count)_\(filename)")
//            let photo: String = data.downloadURL(completion: { url, error in
//                guard let url = url?.absoluteString, error == nil else {
//                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
//                    return
//                }
//                
//                downloadGroup.leave()
//            })
//            allPhotoUrls.append(photo)
//        }
//        
//    }
        
        
//        // Go through list of data and upload each one
//        var urlStrings = [String]()
//
//        let completeIsh: [String] = dataList.compactMap(
//            count += 1
//            storage.child("images/vnikki13@gmail.com/_\(count)_\(filename)").putData(data, metadata: nil, completion: { metadata, error in
//                guard error == nil else {
//                    // failed to upload
//                    print("Failed to upload photo data to firebase")
//                    completion(.failure(StorageErrors.failedToUpload))
//                    return
//                }
//                //                print(metadata)
//                print("this is shit")
//
//                let fileReference = self.storage.child("images/vnikki13@gmail.com/_\(count)_\(filename)")
//                fileReference.downloadURL(completion: { url, error in
//                    guard let url = url?.absoluteString, error == nil else {
//                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
//                        return
//                    }
//
//                    print("URL STRING")
//                    urlStrings.append(url)
//                    return url
//                })
//
//            })
//            print("does this print mutlit times")
//        )
//
//        print(completeIsh)
//        print("returning completion")
//        completion(.success(urlStrings))
//    }
    
    
    //        print("reading data from firebase")
    //        // read from storage folder to get a list of urls
    //        storage.child("images/vnikki13@gmail.com").listAll(completion: { result, error in
    //            guard error == nil else {
    //                // failed to download
    //                print("Failed to get a collection of files from firebase storage")
    //                completion(.failure(StorageErrors.failedToGetDownloadUrl))
    //                return
    //            }
    //
    //            print("these are the result items")
    //            print(result.items)
    //
    //            let urlStrings: [String] = result.items.compactMap({ item in
    //                var urlString: String?
    //                item.downloadURL(completion: { url, error in
    //                    guard error == nil else {
    //                        print("Failed to download photo url from firebase")
    //                        return
    //                    }
    //
    //                    urlString = url?.absoluteString
    //                    print("url absolute string")
    //                    print(urlString)
    //                })
    //                return urlString
    //            })
    //            completion(.success(urlStrings))
    //        })
    
    
//    public func getPhotoUrls(from email: String, completion: @escaping (Result<[String], Error>) -> Void) {
//        storage.child("images/\(email)").listAll(completion: { result, error in
//            guard error == nil else {
//                // failed to download
//                print("Failed to get a collection of files from firebase storage")
//                completion(.failure(StorageErrors.failedToGetDownloadUrl))
//                return
//            }
//
//            print(result.items)
//            completion(.success(["hello World"]))
//        })
//    }
    
    
    
    
//    public func reUploadProfilePicture(with dataList: [Data], filename: String, completion: @escaping UploadPictureCompletion) {
//
//        var count = 0
//        for data in dataList {
//            count += 1
//
//            storage.child("images/vnikki13@gmail.com/_\(count)\(filename)").putData(data, metadata: nil, completion: { metadata, error in
//                guard error == nil else {
//                    // failed
//                    print("failed to upload data to firebase for picture")
//                    completion(.failure(StorageErrors.failedToUpload))
//                    return
//                }
//
//                let storageReference = self.storage.child("images/vnikki13@gmail.com")
//
//                storageReference.listAll( completion: { result, error in
//                    if let error = error {
//                      print("An error occured referencing storage: \(error)")
//                    }
////                    for item in result.items {
////                        print("These are the Items")
////                        print(item)
////
////                        item.downloadURL(completion: { url, error in
////                            guard let url = url else {
////                                print("Failed to get download url")
////                                completion(.failure(StorageErrors.failedToGetDownloadUrl))
////                                return
////                            }
////
////                            self.urlStrings.append(url.absoluteString)
////                            let urlString = url.absoluteString
////                            print("Download url returned: \(urlString)")
////
////                        })
////                    }
//
//
//                    let allUrlStrings: [String] = result.items.compactMap({ item in
//                        var urlString = String()
//                        item.downloadURL(completion: { url, error in
//                            guard let url = url else {
//                                print("Failed to download url: \(error!)")
//                                return
//                            }
//
//                            print(url.absoluteString)
//                            urlString = url.absoluteString
//
//                        })
//
//                        return urlString
//                    })
//                    print("+++++++")
//                    print("List of all Photos: \(allUrlStrings)")
//                })
//
//
//
//
//
//                self.storage.child("images/vnikki13@gmail.com/_\(count)\(filename)").downloadURL(completion: { url, error in
//                    guard let url = url else {
//                        print("Failed to get download url")
//                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
//                        return
//                    }
//
//                    self.urlStrings.append(url.absoluteString)
//                    let urlString = url.absoluteString
//                    print("Download url returned: \(urlString)")
//
//                })
//            })
//        }
//        print("list of url string: \(urlStrings)")
//        completion(.success(urlStrings))
//    }
    
    public func uploadPicture(with data: Data, filename: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(filename)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                // failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
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
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
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


