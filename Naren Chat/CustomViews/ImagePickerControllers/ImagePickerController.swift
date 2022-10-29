//
//  ImagePickerController.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 30/10/22.
//

import UIKit

protocol ImagePickerControllerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}

class ImagePickerController: NSObject, UINavigationControllerDelegate {

    private var pickerController = UIImagePickerController()
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerControllerDelegate?

    init(delegate: ImagePickerControllerDelegate?) {
        super.init()
        self.delegate = delegate
        configureProperties()
    }
    
    private func configureProperties() {
        pickerController.allowsEditing = true
        pickerController.delegate      = self
        pickerController.mediaTypes    = ["public.image"]
    }
    
    func setPresentationViewController(VC: UIViewController?) {
        presentationController = VC
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            DispatchQueue.main.async {
                self.presentationController?.present(self.pickerController, animated: true)
            }
        }
    }

    func present(from sourceView: UIView?) {
        guard let sourceView else { return }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Saved photos") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        DispatchQueue.main.async {
            self.presentationController?.present(alertController, animated: true)
        }
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image)
    }
}

extension ImagePickerController: UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
           return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

