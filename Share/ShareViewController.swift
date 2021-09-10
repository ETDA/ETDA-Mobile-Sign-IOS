//
//  ShareViewController.swift
//  Share
//
//  Created by Pawan Pankhao on 6/9/2564 BE.
//

import UIKit
import MobileCoreServices

@objc(ShareExtensionViewController)
class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleSharedFile()
      }
      
      private func handleSharedFile() {
        print("inputItem : \(String(describing: self.extensionContext?.inputItems.first))")
          let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        print("attachments = \(attachments)")
          let contentType = kUTTypeData as String
          for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(contentType) {
              provider.loadItem(forTypeIdentifier: contentType,
                                options: nil) { [unowned self] (data, error) in
              guard error == nil else { return }

                if let url = data as? URL {
                    if url.absoluteString.uppercased().hasSuffix(".P12") || url.absoluteString.uppercased().hasSuffix(".PFX"){
                        print("url = \(url.absoluteString)")
                        if let fileData = try? Data(contentsOf: url) {
                            self.save(fileData, key: "fileData", value: fileData)
                            showAlertWith(title: "File has been shared with TEDA Sign app.")
                        }
                    } else {
                        showAlertWith(title: "TEDA Sign not support this file.")
                    }
              } else {
                showAlertWith(title: "Something went wrong, please try again.")
              }
            }}
          }
      }

    private func save(_ data: Data, key: String, value: Any) {
      let userDefaults = UserDefaults(suiteName: "group.th.or.tedasign")!
      userDefaults.set(data, forKey: key)
    }
    
    private func showAlertWith(title: String){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                let onOk = UIAlertAction(title: "OK", style: .default) { alert in
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
            alertController.addAction(onOk)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
