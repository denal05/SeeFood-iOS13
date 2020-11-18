//
//  ViewController.swift
//  SeeFood-iOS13
//
//  Created by Denis Aleksandrov on 11/17/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        //imagePicker.sourceType = .photoLibrary
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false // Set to true if you want cropping
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError(#function + ": Could not convert the user-picked UI image to CI image!")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let inceptionv3Model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError(#function + ": Loading CoreML model \"Inceptionv3\" into Vision failed!")
        }
        
        let request = VNCoreMLRequest(model: inceptionv3Model) { (vnCoreMLRequest, error) in
            guard let results = vnCoreMLRequest.results as? [VNClassificationObservation] else {
                fatalError(#function + ": Model failed to process image!")
            }
            print(#function + ": Results: \(results)")
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(#function + ": Error: \(error)")
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }

}

