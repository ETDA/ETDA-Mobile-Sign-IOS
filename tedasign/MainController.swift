//
//  MainController.swift
//  tedasign
//
//  Created by Mee on 1/7/2564 BE.
//

import UIKit
import MobileCoreServices
import LocalAuthentication
import GoogleAPIClientForREST
import Security
import AVFoundation
class MainController: UIViewController,UITableViewDataSource ,UITableViewDelegate {
  

    @IBOutlet weak var bottombar: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var isDocumentPickerPresented = false
    private var registeredToBackgroundEvents = false
    var detectSharePopUpAreShowing = false
    var mListKey:[String] = []
    
    func barbuttomStyle() {
        bottombar.layer.cornerRadius = 10

        // border
        bottombar.layer.borderWidth = 1.0
        bottombar.layer.borderColor = UIColor.clear.cgColor

        // shadow
        bottombar.layer.shadowColor = UIColor.black.cgColor
        bottombar.layer.shadowOffset = CGSize(width: 3, height: 3)
        bottombar.layer.shadowOpacity = 0.7
        bottombar.layer.shadowRadius = 4.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barbuttomStyle()
        self.tableView.delegate = self
           self.tableView.dataSource = self
        self.navigationItem.backButtonDisplayMode = .minimal
        print("MainViewLoad")

        //loadListKey()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("MainViewWillAppear")
        super.viewWillAppear(animated)
        registerToBackFromBackground()
        loadListKey()
        self.tableView.reloadData()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        DispatchQueue.main.async {
            self.supportedBiometricType()
        }
        checkQR()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterFromBackFromBackground()
        if !isDocumentPickerPresented {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    @IBAction func btnImport(_ sender: Any) {
        let supportedTypes: [String] = [kUTTypePKCS12 as String,kUTTypeFolder as String]
        let documentPicker = UIDocumentPickerViewController(documentTypes: supportedTypes, in: .import)
        documentPicker.delegate = self
        documentPicker.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        isDocumentPickerPresented = true
       present(documentPicker, animated: true, completion: nil)
        
    }

    
    @IBAction func btnSign(_ sender: Any) {
        checkCamera()
        
        
    }
    
    
    @IBAction func btnRestore(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "RestoreViewController") as! RestoreViewController;
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
//           self.present(vc, animated: true, completion: nil)
          
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mListKey.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
              
              // set the text from the data model
        let split = self.mListKey[indexPath.row].split(separator: "_")
        
                       if(split.count>2){
                        let newString = self.mListKey[indexPath.row].replacingOccurrences(of: "_"+split[split.count-1], with: "", options: .literal, range: nil)
                        cell.textLabel?.text = newString
                       }else{
                        let s: String = String(split[0])
                        cell.textLabel?.text = s
                       }
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        
        let boldText  = "Last update: "
        let normalText = getDate(tagKeyName: self.mListKey[indexPath.row])
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 11)]
        let attributedString = NSMutableAttributedString(string:normalText)
        let boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
        boldString.append(attributedString)
        cell.detailTextLabel?.attributedText = boldString
        // cell.detailTextLabel?.text = "Last update: "+getDate(tagKeyName: self.mListKey[indexPath.row])
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        alertConfirmDelete(index: indexPath)
      }
    }
    
    func loadListKey() {
        mListKey = SelectAllKey().sorted() { $0 > $1 }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func alertConfirmDelete(index:IndexPath){
//        let alert = UIAlertController(title: "Warning!", message: "Do you want to delete?", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "CONFIRM", style: .default, handler: { action in
//       
//            deleteKey(name: self.mListKey[index.row])
//            self.mListKey.remove(at: index.row)
//            self.tableView.deleteRows(at: [index], with: .automatic)
//            
//            if(self.mListKey.count < 1) {
//                self.navigationController?.popViewController(animated: true)
//            }else{
//                self.tableView.reloadData()
//            }
//            
//        }))
//        
//        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { action in
//            //to import key
//       
//            self.dismiss(animated: true, completion: {
//                
//            })
//            
//        }))
//
//        self.present(alert, animated: true)
        
        let popUp = PopUpTwoButton(imageName: nil, title: "Warning!", message: "Do you want to delete?", acceptButtonString: "CONFIRM", cancelButtonString: "CANCEL") {
            
            deleteKey(name: self.mListKey[index.row])
            self.mListKey.remove(at: index.row)
            self.tableView.deleteRows(at: [index], with: .automatic)
            print("--------mListKey-------")
            print(self.mListKey.count)
            print("--------mListKey-------")

            if(self.mListKey.count == 0) {
                DispatchQueue.main.async {
                    //self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                self.tableView.reloadData()
            }
        } touchCancel: {
            
        }
        
        popUp.show()
        
        // .End conform message
    }
}

extension MainController: UIDocumentPickerDelegate {
   
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
    
    func checkCameraBecomeActive(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .denied:
                print("Denied, request permission from settings")
//                alertPromptToAllowCameraAccessViaSetting()
            case .restricted:
                print("Restricted, device owner must approve")
            case .authorized:
                print("Authorized, proceed")
            case .notDetermined:
                print("notDetermined")
            }
    }
    func checkCamera() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "QRScannerViewController") as! QRScannerViewController;
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .denied:
                print("Denied, request permission from settings")
                alertPromptToAllowCameraAccessViaSetting();
            case .restricted:
                print("Restricted, device owner must approve")
            case .authorized:
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "QRScannerViewController") as! QRScannerViewController;
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                print("Authorized, proceed")
            case .notDetermined:
                print("notDetermined")
                AVCaptureDevice.requestAccess(for: .video) { success in
                    if success {
                        
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                        print("Permission granted, proceed")
                    } else {
                        
                    }
                }
            }
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
 
        let popUp = PopUpWithImageView(imageName: "warning", title: "We need to access your camera for scanning QR code.", okButtonString: "Go to setting") {
            DispatchQueue.main.async {
                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
        }
        popUp.show()
    }
    
    
    private func supportedBiometricType ()
    {
        let popUp = PopUpWithImageView(imageName: "warning", title: "Please use biometrics to authentication.", okButtonString: "Go to setting") {
                DispatchQueue.main.async {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
//            }
        }
        let context = LAContext()
            print("context.invalidate()" ,context)
            context.touchIDAuthenticationAllowableReuseDuration = 10;
            var error: NSError?
            
            let userdefaults = UserDefaults.standard
            print("userdefaults.isAuthFirst" ,userdefaults.bool(forKey: "isAuthFirst"))
            print("userdefaults.isAuth" ,userdefaults.bool(forKey: "isAuth"))

            print("canEvaluatePolicy" ,context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error))
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
              {
                if(!AppDelegate.isAuthFirst){
                    userdefaults.set(true,forKey: "isAuth")
                    AppDelegate.isAuth = true
                }
            } else {
                
                popUp.show();
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
        DispatchQueue.main.async {
            self.supportedBiometricType()
        }
        print("MainViewDidBecomeActive ")
        checkQR()
        processShareFile()
    }
    
    func checkQR() {
        let qr = AppDelegate.qrcode
        if qr.count >= 1 {
            processQR(qr: qr)
            AppDelegate.qrcode = ""
        }
    }
    
    func processQR(qr:String) {
        print("QR = \(qr)")
        let strQRValArr =  qr.components(separatedBy: ";")
        if(strQRValArr.count >= 3){
        let str_ref_number =  strQRValArr[3]
        print("QR = \(strQRValArr)")
        let popUp = PopUpTwoButton(imageName: nil, title: "ข้อมูลเอกสารที่ลงนาม", message: "หมายเลข Reference : "+str_ref_number, acceptButtonString: "CONFIRM", cancelButtonString: "CANCEL") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ListKeyViewController") as! ListKeyViewController;
            vc.qrcode = qr
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } touchCancel: {
            print("user cancel")
            
        }
            popUp.show()
        }
    }
    
    func processShareFile(){
        if !detectSharePopUpAreShowing {
            let shareUserDefaults = UserDefaults(suiteName: "group.th.or.etda.tedasign")!
            if shareUserDefaults.value(forKey: "fileData") != nil {
                if let data = shareUserDefaults.value(forKey: "fileData") as? Data {
                    try? data.write(to: AppDelegate.shareFilePath)
                    print("saved share file to \(AppDelegate.shareFilePath)")
                    shareUserDefaults.removeObject(forKey: "fileData")
                }
            }

            if FileManager.default.fileExists(atPath: AppDelegate.shareFilePath.path) {
                detectSharePopUpAreShowing = true
                let popUp = PopUpTwoButton(imageName: nil, title: "ตรวจพบไฟล์ p12/pfx ใหม่ในระบบ", message: "ต้องการ import key จากไฟล์นี้หรือไม่", acceptButtonString: "IMPORT KEY", cancelButtonString: "CANCEL") {
                    self.detectSharePopUpAreShowing = false
                    AppDelegate.importingKeyFromShareFile = true
                    self.documentFromURL(pickedURL: AppDelegate.shareFilePath)
                } touchCancel: {
                    self.detectSharePopUpAreShowing = false
                    try? FileManager.default.removeItem(atPath: AppDelegate.shareFilePath.path)
                }
                popUp.show()
            }
        }
    }
}
