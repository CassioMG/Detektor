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
    private let kMaxImageSize = 10_000_000 // 10MB
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
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
            
            SVProgressHUD.show(withStatus: "Classifying image...")
            self.searchButton.isEnabled = false
            self.cameraButton.isEnabled = false
            self.shareButton.isHidden = true
            
            imagePicker.dismiss(animated: true, completion: nil)
            
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
                    self.shareButton.isHidden = false
                    SVProgressHUD.dismiss()
                }
            }
            
        } else {
            print("Error picking original image from user info.")
            self.navigationItem.title = "Error picking image, try again..."
        }
    }
    

}

extension ViewController: UIActivityItemSource {
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
        let customActivity = DetektorActivity(title: "Try me!", image: UIImage(named: "aImage")) { sharedItems in
            
            for item in sharedItems {
                print("Here's the item: \(item)")
                
                if let itemArray = item as? [Any] {
                    for subItem in itemArray {
                        print("Here's the SUB item: \(subItem)")
                    }
                }
            }
        }
        
        let items: [Any] = [self, imageView.image!.resized(toWidth: 200.0)!] // Resize image so that it's accepted on any social media like twitter, facebook or instagram.
        let ac = UIActivityViewController(activityItems: items, applicationActivities: [customActivity])
        present(ac, animated: true)
        
        // TODO: implement for iPad
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Here goes the subject"
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage(named: "placeholder") ?? "Here goes the placeholder"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        switch activityType ?? UIActivity.ActivityType(rawValue: "") {
            
        case .postToFacebook: // Remove url from text when sharing to facebook to avoid getting rid of the content image.
            return "Watson says \(navigationItem.title!)"
        
        case DetektorActivity.activityType: // Adds 2 items to test custom DetektorActivity class closure.
            return ["Sharing content for \(activityType!.rawValue)", "Watson says \(navigationItem.title!)\nCheck out more on https://www.ibm.com/watson/about"]
            
        default:
            
            // Remove entire text when sharing to WhatsApp to avoid getting rid of the content image.
            if activityType!.rawValue.contains("whats") {
                return nil
            }
            
            return "Watson says \(navigationItem.title!)\nCheck out more on https://www.ibm.com/watson/about"
        }
    }
    

}

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    
}
