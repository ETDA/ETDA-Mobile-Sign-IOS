//
//  QRScannerViewController.swift
//  tedamobilesigning
//
//  Created by Prawit Phiwhom on 24/2/2564 BE.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    private var registeredToBackgroundEvents = false
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var deniAV:Int = 0;
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backButtonDisplayMode = .minimal
        self.title = "Scan QR Code"
        //Check Allow camera
//        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
//           print("already authorized")
//        } else {
//            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
//                if granted {
//                    print("access allowed")
//                } else {
//                    print("access denied")
//
//                    //Close
//                    //self.dismiss(animated: true, completion: nil)
//                }
//            })
//        }
        
                
        
        checkCamera()
        
        // Get the back-facing camera for capturing videos
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession.commitConfiguration()
            captureSession.startRunning()
            
            // Move the message label and top bar to the front
//            view.bringSubviewToFront(messageLabel)
//            view.bringSubviewToFront(topbar)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()

            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print("If any error occurs, simply print it out and don't continue any more.")
            print(error)
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
         
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        registerToBackFromBackground()
        if(captureSession.isRunning == false) {
            captureSession.commitConfiguration()
            captureSession.startRunning()
        }
    }

     
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterFromBackFromBackground()
        print("viewWillDisappear")
        if captureSession.isRunning == true {
            captureSession.stopRunning()
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
        checkCameraBecomeActive()
        print("viewDidBecomeActive ")
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
//            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

//        if metadataObjects.first
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
                if captureSession.isRunning == true {
                    captureSession.stopRunning()
                }
                
                let result = metadataObj.stringValue ?? ""
             
                    let strQRValArr =  result.components(separatedBy: ";")
                if(strQRValArr.count>=3){
                    let str_ref_number =  strQRValArr[3]
                    
//                    let popUp = PopUpWithImageView(title: "หมายเลข Reference : "+str_ref_number, okButtonString: "OK") {
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//                        let vc = storyboard.instantiateViewController(withIdentifier: "ListKeyViewController") as! ListKeyViewController;
//                        vc.qrcode = result
//                        DispatchQueue.main.async {
//                            self.navigationController?.pushViewController(vc, animated: true)
//
//                        }
//                    }
//                    popUp.show()
                    
                    let popUp = PopUpTwoButton(imageName: nil, title: "ข้อมูลเอกสารที่ลงนาม", message: "หมายเลข Reference : "+str_ref_number, acceptButtonString: "CONFIRM", cancelButtonString: "CANCEL") {
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil);
                        let vc = storyboard.instantiateViewController(withIdentifier: "ListKeyViewController") as! ListKeyViewController;
                        vc.qrcode = result
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }
                    } touchCancel: {
                        if(self.captureSession.isRunning == false) {
                            self.captureSession.commitConfiguration()
                            self.captureSession.startRunning()
                        }
                    }
                    
                    popUp.show()
                    
                    
//                    let alert = UIAlertController(title: "หมายเลข Reference : "+str_ref_number, message: "", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//                        let vc = storyboard.instantiateViewController(withIdentifier: "ListKeyViewController") as! ListKeyViewController;
//                        vc.qrcode = result
//                        DispatchQueue.main.async {
//                            self.navigationController?.pushViewController(vc, animated: true)
//
//                        }
//                    }))
//                    DispatchQueue.main.async {
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }else{
//                    let alert = UIAlertController(title: "QrCode Invalid", message: "", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler:{_ in
//                        if(self.captureSession.isRunning == false) {
//                            self.captureSession.commitConfiguration()
//                            self.captureSession.startRunning()
//                        }
//                    }))
//                    DispatchQueue.main.async {
//                        self.present(alert, animated: true, completion: nil)
//                    }
                    let popUp = PopUpWithImageView(imageName: "checkmark_circle", title: "QrCode Invalid", okButtonString: "CLOSE") {
                        if(self.captureSession.isRunning == false) {
                            self.captureSession.commitConfiguration()
                            self.captureSession.startRunning()
                        }
                    }
                    popUp.show()
                }
                  
              
            }
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func checkCameraBecomeActive(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .denied:
                print("Denied, request permission from settings")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .restricted:
                print("Restricted, device owner must approve")
            case .authorized:
                print("Authorized, proceed")
            case .notDetermined:
                print("notDetermined")
            }
    }
    func checkCamera() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .denied:
                print("Denied, request permission from settings")
                alertPromptToAllowCameraAccessViaSetting();
            case .restricted:
                print("Restricted, device owner must approve")
            case .authorized:
                print("Authorized, proceed")
            case .notDetermined:
                print("notDetermined")
                AVCaptureDevice.requestAccess(for: .video) { success in
                    if success {
                        print("Permission granted, proceed")
                    } else {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
    }

    func alertToEncourageCameraAccessInitially() {
//        let alert = UIAlertController(
//            title: "IMPORTANT",
//            message: "We need to access your camera for scanning QR code.",
//            preferredStyle: UIAlertController.Style.alert
//        )
//        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {_ in
//            DispatchQueue.main.async {
//                self.navigationController?.popViewController(animated: true)
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
//            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
//        }))
//        present(alert, animated: true, completion: nil)
        
        let popUp = PopUpTwoButton(imageName: "ic_camera", message: "อนุญาตให้ ETDA Sign ถ่ายภาพและบันทึกวิดีโอไหม?", acceptButtonString: "อนุญาต", cancelButtonString: "ปฏิเสธ") {
            print("accept")
            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        } touchCancel: {
            print("cancel")
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        popUp.show()
    }

    func alertPromptToAllowCameraAccessViaSetting() {

//        let alert = UIAlertController(
//            title: "IMPORTANT",
//            message: "We need to access your camera for scanning QR code.",
//            preferredStyle: UIAlertController.Style.alert
//        )
//        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { alert in
//            DispatchQueue.main.async {
////                self.navigationController?.popViewController(animated: true)
//                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
//            }
//            }
//        )
//        present(alert, animated: true, completion: nil)
        
        let popUp = PopUpWithImageView(imageName: "checkmark_circle", title: "We need to access your camera for scanning QR code.", okButtonString: "Go to setting") {
            DispatchQueue.main.async {
                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
        }
        popUp.show()
    }

}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {

}

