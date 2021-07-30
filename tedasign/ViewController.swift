//
//  ViewController.swift
//  tedasign
//
//  Created by Mee on 28/6/2564 BE.
//

import UIKit
import Security
import MobileCoreServices
import LocalAuthentication
import GoogleAPIClientForREST

class ViewController: UIViewController {
    var mListKey:[String] = []
    
    // check authen
    let context = LAContext()
    var error: NSError?
    var isDocumentPickerPresented = false
    private var registeredToBackgroundEvents = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backButtonDisplayMode = .minimal
        
    }
    
    private func supportedBiometricType ()
    {
        let popUp = PopUpWithImageView(imageName: "checkmark_circle", title: "Please use biometrics to authentication.", okButtonString: "Go to setting") {
                DispatchQueue.main.async {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
//            }
        }
        let context = LAContext()
        if(!checkFirst()){
            print("context.invalidate()" ,context)
            context.touchIDAuthenticationAllowableReuseDuration = 10;
            var error: NSError?
            
            let userdefaults = UserDefaults.standard
            print("userdefaults.isAuthFirst" ,userdefaults.bool(forKey: "isAuthFirst"))
            print("userdefaults.isAuth" ,userdefaults.bool(forKey: "isAuth"))

            print("canEvaluatePolicy" ,context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error))
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
              {
                if(!userdefaults.bool(forKey: "isAuthFirst")){
                    userdefaults.set(true,forKey: "isAuth")
                    AppDelegate.isAuth = true
                }
            } else {
                
                popUp.show();
                print("none")
            }
        }
        

    }
       
    private func checkFace(){
        let popUp = PopUpWithImageView(imageName: "checkmark_circle", title: "Please use biometrics to authentication.", okButtonString: "Go to setting") {
            if let url = URL(string: "App-Prefs:root=TOUCHID_PASSCODE") {
//                    UIApplication.shared.openURL(url)
                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
        }
        let context = LAContext()
        print("context=",context.biometryType)
        context.touchIDAuthenticationAllowableReuseDuration = 10;
        var error: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
          {
         
            if (context.biometryType == LABiometryType.faceID)
             {
//                AppDelegate.isFirst = false;
                print("faceID")

             }
            else if context.biometryType == LABiometryType.touchID
             {
//                AppDelegate.isFirst = false;
                print("touchID")

             } else {
                popUp.show()
                print("none")

            }
        } else {
            popUp.show()
            print("none")

        }
         
    }
    
    
    
    /// register to back from backround event
    private func registerToBackFromBackground() {
        if(!registeredToBackgroundEvents) {
            NotificationCenter.default.addObserver(self,
            selector: #selector(viewDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
            registeredToBackgroundEvents = true
        }
    }
    
    /// unregister from back from backround event
    private func unregisterFromBackFromBackground() {
        if(registeredToBackgroundEvents) {
            NotificationCenter.default.removeObserver(self,
            name: UIApplication.didBecomeActiveNotification, object: nil)
            registeredToBackgroundEvents = false
        }

    }
    @objc func viewDidBecomeActive(){
        //DispatchQueue.main.async {
        //    self.supportedBiometricType()
        //}
        print("viewDidBecomeActive ")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ViewController viewWillAppear")
        super.viewWillAppear(animated)
        registerToBackFromBackground()
        navigationController?.setNavigationBarHidden(true, animated: animated)
//        supportedBiometricType()
        DispatchQueue.main.async {
            self.supportedBiometricType()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterFromBackFromBackground()
        if !isDocumentPickerPresented {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        checkFace()
//        checkFace()

    }
    
    public func checkFirst() -> Bool{
        var returnVal = false
        mListKey = SelectAllKey()
        print("mList item : \(mListKey.count)")
        if(!mListKey.isEmpty){
            returnVal = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "MainController") as! MainController;
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
//                self.navigationController?.setViewControllers([vc], animated: false)
            }
        }
        return returnVal
    }

    @IBAction func btnRestore(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "RestoreViewController") as! RestoreViewController;
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
//           self.present(vc, animated: true, completion: nil)
          
        }
        
    }
    
    
    @IBAction func btnAction(_ sender: Any) {
        let supportedTypes: [String] = [kUTTypePKCS12 as String,kUTTypeFolder as String]
        let documentPicker = UIDocumentPickerViewController(documentTypes: supportedTypes, in: .import)
        documentPicker.delegate = self
        documentPicker.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        isDocumentPickerPresented = true
       present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func btnSigning(_ sender: Any) {
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let vc = storyboard.instantiateViewController(withIdentifier: "QRScannerViewController") as! QRScannerViewController;
//
//        DispatchQueue.main.async {
//           self.present(vc, animated: true, completion: nil)
//        }
        
    }
    
    

}

extension ViewController: UIDocumentPickerDelegate {
   
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            print("error")
            return
        }
        
        print("Browse File Success")
        documentFromURL(pickedURL: url)
        isDocumentPickerPresented = false
        controller.dismiss(animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        isDocumentPickerPresented = false
        controller.dismiss(animated: true)
    }
    
    private func documentFromURL(pickedURL: URL) {
        let p12Data : NSData = NSData(contentsOf: pickedURL)!
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "ImportKeyViewController") as! ImportKeyViewController;
//        vc.modalPresentationStyle = .fullScreen
        vc.dataImport = p12Data
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
//           self.present(vc, animated: true, completion: nil)
          
        }
    }
}

