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

    //MARK: action
    @IBAction func searchInputPathAction(_ sender: Any) {
        self.searchFilePath(searchDir: false, completeHandler: { [weak self] path in
//            self?.originFileName = (path as NSString).lastPathComponent
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
            print("somthing is blank")
            return
        }
        
        let fileManager: FileManager = FileManager.default
        
        do {
            if let originData: Data = fileManager.contents(atPath: self.inputPathTextField.stringValue) {
                guard let sourceStr = self.passwordTextField.stringValue.data(using: .utf8) else { print("str to data fail ") ; return }
                let outputFileName = ((self.inputPathTextField.stringValue as NSString).deletingPathExtension as NSString).lastPathComponent
                let destinationPath = self.outputPathTextField.stringValue
                guard let encoded = destinationPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { print("str to url fail") ; return }
                let outputUrl = URL(fileURLWithPath: encoded)

                let encData = HWAESCryption.aesEncrypt(originalData: originData, iv: CryptoUtil().sha256(data: sourceStr), key: CryptoUtil().sha256(data: sourceStr), aesType: .aes256)
                try encData.write(to: outputUrl.appendingPathComponent(outputFileName + "." +  CommonDefine.myExtension))
            }
            else {
                print("file to data fail")
            }
        } catch let error as NSError {
            print("Error access directory: \(error)")
        }
    }
    
    @IBAction func decFileAction(_ sender: Any) {
    }
    
}

