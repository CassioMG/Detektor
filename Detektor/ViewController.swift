//
//  ViewController.swift
//  Detektor
//
//  Created by Cássio Marcos Goulart on 11/06/19.
//  Copyright © 2019 CMG Solutions. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import SwiftDate

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // TODO: set your Blue Mix API here (blueMixAPI)
    private let blueMixAPI = ""
    private let blueMixVersion = Date().toFormat("yyyy-MM-dd")
    private let imagePicker = UIImagePickerController()
    private let kMaxImageSize = 10000000 // 10MB
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }

    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
        self.navigationItem.title = "This is a ...?"
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            imagePicker.dismiss(animated: true, completion: nil)
            
            SVProgressHUD.show(withStatus: "Classifying image...")
            self.searchButton.isEnabled = false
            self.cameraButton.isEnabled = false
            
            var compressionQuality: CGFloat = 1.0
            guard var imageData = userPickedImage.jpegData(compressionQuality: compressionQuality) else {
                fatalError("Error creating image JPEG data.")
            }
          
            for _ in 1...50 {
                
                if (imageData.count > kMaxImageSize) {
                
                    compressionQuality *= 0.75
                    imageData = userPickedImage.jpegData(compressionQuality: compressionQuality)!
                    
                    print("=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=")
                    print("There were \(imageData.count) bytes")
                    let bcf = ByteCountFormatter()
                    bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
                    bcf.countStyle = .file
                    let string = bcf.string(fromByteCount: Int64(imageData.count))
                    print("formatted result: \(string)")
                    print("=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=")
                
                } else { break }
            }
            
            // Use the code below to write the compressed image to a file:
            // let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            // let imageURL = documentsURL.appendingPathComponent("tempImage.jpg")
            // try? imageData?.write(to: imageURL)
            
            let visualRecognition = VisualRecognition(version: self.blueMixVersion, apiKey: self.blueMixAPI)
            visualRecognition.classify(imagesFile: imageData, imagesFilename: nil , imagesFileContentType: nil, url: nil, threshold: 0.0, owners: nil, classifierIDs: nil, acceptLanguage: nil, headers: nil) { (response, error) in

                if error != nil {
                    print("Visual Recognition Response ERROR:", error!)
                }
                
                guard let classifiedImages = response?.result else {
                    fatalError("Failed to classify the image.")
                }
                print("======================================================================")
                print("CLASSIFIED IMAGES:", classifiedImages)
                print("======================================================================")
                
                var classesResult = classifiedImages.images.first!.classifiers.first!.classes
                
                // Use the code below to sort the classes by score:
                // classesResult.sort(by: { (class1, class2) -> Bool in
                //     class1.score > class2.score
                // })
                
                var classNamesResult: [String] = []
                
                for index in 0..<classesResult.count {
                    classNamesResult.append(classesResult[index].className)
                }
                
                print("======================================================================")
                print("CLASS NAMES RESULT: \(classNamesResult)")
                print("======================================================================")
                
                DispatchQueue.main.async {
                    self.navigationItem.title = "This is a \(classNamesResult.first!)!"
                    self.searchButton.isEnabled = true
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                }
            }
            
        } else {
            print("Error picking original image from user info.")
            self.navigationItem.title = "Error picking image, try again..."
        }
    }
    

}
