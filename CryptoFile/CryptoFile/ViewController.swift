//
//  ViewController.swift
//  CryptoFile
//
//  Created by hanwe on 2021/01/25.
//

import Cocoa

class ViewController: NSViewController {
    
    //MARK: interface builder
    @IBOutlet weak var inputPathTextField: NSTextField!
    @IBOutlet weak var outputPathTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    //MARK: property
    
    var originFileName: String = ""
    
    //MARK: life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //MARK: function
    
    func initUI() {
        self.inputPathTextField.isEnabled = false
        self.outputPathTextField.isEnabled = false
        self.indicator.isHidden = true
    }
    
    func searchFilePath(searchDir: Bool,completeHandler: @escaping (String) -> ()) {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose a file| Our Code World"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = searchDir ? true : false
        dialog.canChooseFiles = searchDir ? false : true

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            if let dir = dialog.url {
                let path: String = dir.path
                completeHandler(path)
            }
        } else {
            
            return
        }
    }
    
    func showAlert(title: String = "오류", message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.addButton(withTitle: "확인")

            alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            })
        }
    }

    //MARK: action
    @IBAction func searchInputPathAction(_ sender: Any) {
        self.searchFilePath(searchDir: false, completeHandler: { [weak self] path in
            self?.inputPathTextField.stringValue = path
        })
    }
    
    @IBAction func searchOutputPathAction(_ sender: Any) {
        self.searchFilePath(searchDir: true, completeHandler: { [weak self] path in
            self?.outputPathTextField.stringValue = path
        })
    }
    
    @IBAction func encFileAction(_ sender: Any) {
        if self.inputPathTextField.stringValue == "" || self.outputPathTextField.stringValue == "" || self.passwordTextField.stringValue == "" {
            showAlert(message: "somthing is blank")
            return
        }
        
        let fileManager: FileManager = FileManager.default
        
        if let originData: Data = fileManager.contents(atPath: self.inputPathTextField.stringValue) {
            guard let pwData: Data = self.passwordTextField.stringValue.data(using: .utf8) else { showAlert(message: "str to data fail") ; return }
            let outputFileName = ((self.inputPathTextField.stringValue as NSString).deletingPathExtension as NSString).lastPathComponent
            let destinationPath = self.outputPathTextField.stringValue
            guard let encodedPath = destinationPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { showAlert(message: "str to url fail") ; return }
            let outputUrl = URL(fileURLWithPath: encodedPath)
            let metaData: MetaDataModel = MetaDataModel(originalFileName: (self.inputPathTextField.stringValue as NSString).lastPathComponent, fileEncDate: Date(), originHash: CryptoUtil().sha512(data: pwData).base64EncodedString())
            DispatchQueue.global().async {
                let encData = HWAESCryption.aesShortEncrypt(data: originData, key: pwData, aesType: .aes256)
                let writeStr: String = metaData.toJson() + CommonDefine.seperator + encData!.base64EncodedString()
                let writeData: Data = writeStr.data(using: .utf8)!
                do {
                    try writeData.write(to: outputUrl.appendingPathComponent(outputFileName + "." +  CommonDefine.myExtension))
                    DispatchQueue.main.async {
                        self.indicator.stopAnimation(nil)
                        self.indicator.isHidden = true
                        self.showAlert(title: "성공", message: "경로 : \( "\(self.outputPathTextField.stringValue)" + "/" + outputFileName + "." +  CommonDefine.myExtension)")
                    }
                } catch let error as NSError {
                    self.showAlert(message: "Error access directory: \(error.localizedDescription)")
                    self.indicator.isHidden = false
                    self.indicator.startAnimation(nil)
                }
            }
            self.indicator.isHidden = false
            self.indicator.startAnimation(nil)
        }
        else {
            showAlert(message: "file to data fail")
        }
    }
    
    @IBAction func decFileAction(_ sender: Any) {
        if self.inputPathTextField.stringValue == "" || self.outputPathTextField.stringValue == "" || self.passwordTextField.stringValue == "" {
            showAlert(message: "somthing is blank")
            return
        }
        
        let fileManager: FileManager = FileManager.default
        
        if let originData: Data = fileManager.contents(atPath: self.inputPathTextField.stringValue) {
            DispatchQueue.global().async {
                guard let originDataStr: String = String.init(data: originData, encoding: .utf8) else {
                    self.showAlert(message: "data to string fail")
                    return
                }
                let seperatedArr = originDataStr.components(separatedBy: CommonDefine.seperator)
                if seperatedArr.count < 2 {
                    self.showAlert(message: "invalid data")
                    return
                }
                guard let model: MetaDataModel = MetaDataModel.fromJson(jsonData: seperatedArr[0].data(using: .utf8), object: MetaDataModel()) else {
                    self.showAlert(message: "invalid data")
                    return
                }
                
                guard let sourceData: Data = Data(base64Encoded: seperatedArr[1]) else {
                    self.showAlert(message: "invalid data")
                    return
                }
                
                if model.modelVersion > CommonDefine.modelVersion {
                    self.showAlert(message: "상위버전에서 암호화된 파일입니다.")
                    return
                }
                
                guard let pwData = self.passwordTextField.stringValue.data(using: .utf8) else { self.showAlert(message: "str to data fail") ; return }
                if CryptoUtil().sha512(data: pwData).base64EncodedString() != model.originHash {
                    self.showAlert(message: "비밀번호가 틀렸습니다.")
                    return
                }
                let destinationPath = self.outputPathTextField.stringValue
                guard let decodedPath = destinationPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { self.showAlert(message: "str to url fail") ; return }
                
                guard let decData = HWAESCryption.aesShortDecrypt(encData: sourceData, key: pwData, aesType: .aes256) else {
                    print("invalid data")
                    return
                }
                let outputUrl = URL(fileURLWithPath: decodedPath)
                do {
                    try decData.write(to: outputUrl.appendingPathComponent(model.originalFileName))
                    DispatchQueue.main.async {
                        self.indicator.stopAnimation(nil)
                        self.indicator.isHidden = true
                        self.showAlert(title: "성공", message: "경로 : \( "\(self.outputPathTextField.stringValue)" + "/" + model.originalFileName)")
                    }
                } catch let error as NSError {
                    self.showAlert(message: "Error access directory: \(error.localizedDescription)")
                    self.indicator.stopAnimation(nil)
                    self.indicator.isHidden = true
                }
            }
            self.indicator.isHidden = false
            self.indicator.startAnimation(nil)
        }
        else {
            showAlert(message: "file to data fail")
        }
    }
    
}

