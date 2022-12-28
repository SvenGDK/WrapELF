//
//  ViewController.swift
//  SignELF
//
//  Created by Sven on 26/12/2022.
//

import Cocoa
import UniformTypeIdentifiers

class ViewController: NSViewController {

    let elfType = UTType(tag: "elf", tagClass: .filenameExtension, conformingTo: .data)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        }
    }

    @IBOutlet weak var inputELFTextField: NSTextField!
    @IBOutlet weak var outputFolderTextField: NSTextField!
    @IBOutlet weak var selectedKeyComboBox: NSComboBox!
    
    @IBAction func browseELFFile(_ sender: NSButton) {
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [elfType]

        if (openPanel.runModal() ==  NSApplication.ModalResponse.OK) {
            let elfFile = openPanel.url
            inputELFTextField.stringValue = elfFile!.path
        } else {
            return
        }
        
    }
    
    @IBAction func browseOutputFolder(_ sender: NSButton) {
        
        let openPanel = NSOpenPanel()
        let elfFileName = (inputELFTextField.stringValue as NSString).lastPathComponent
        let kelfFileName = (elfFileName as NSString).deletingPathExtension + ".KELF"

        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false

        if (openPanel.runModal() ==  NSApplication.ModalResponse.OK) {
            let outputFolder = openPanel.url
            outputFolderTextField.stringValue = outputFolder!.path + "/" + kelfFileName
        } else {
            return
        }
        
    }
    
    @IBAction func signELFFile(_ sender: NSButton) {
        
        let SCEDoormatNoME = Bundle.main.path(forResource: "SCEDoormat_NoME", ofType: "")
        
        let selectedELF = inputELFTextField.stringValue
        let selectedOutputFolder = outputFolderTextField.stringValue
        let selectedKey = selectedKeyComboBox.stringValue
        
        let allKey = Bundle.main.path(forResource: "KRYPTO(All).KHN", ofType: "")
        let cexKey = Bundle.main.path(forResource: "KRYPTO(CEX).KHN", ofType: "")
        let psxKey = Bundle.main.path(forResource: "KRYPTO(PSX).KHN", ofType: "")
        
        let task = Process()
        
        task.launchPath = "/bin/sh"
        
        if selectedKey == "PS2 (CEX & DEX) + PSX" {
            //Swift compiler...
            let command = "'" + SCEDoormatNoME! + "' '" + selectedELF + "' "
            let command2 = "'" + selectedOutputFolder + "' '" + allKey! + "'"
            task.arguments = ["-c", command + command2]
        }
        else if selectedKey == "PS2 (CEX)" {
            let command = "'" + SCEDoormatNoME! + "' '" + selectedELF + "' "
            let command2 = "'" + selectedOutputFolder + "' '" + cexKey! + "'"
            task.arguments = ["-c", command + command2]
        }
        else if selectedKey == "PSX (DVR)" {
            let command = "'" + SCEDoormatNoME! + "' '" + selectedELF + "' "
            let command2 = "'" + selectedOutputFolder + "' '" + psxKey! + "'"
            task.arguments = ["-c", command + command2]
        }

        let outpipe = Pipe()
        task.standardOutput = outpipe
        task.launch()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outdata, as: UTF8.self)

        task.waitUntilExit()
            
        print(output)
            
        let successAlert = NSAlert()
        successAlert.messageText = "ELF signed"
        successAlert.informativeText = "Open output folder?"
        successAlert.addButton(withTitle: "Open")
        successAlert.addButton(withTitle: "Close")
            
        if successAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            let outputFolder = (outputFolderTextField.stringValue as NSString).deletingLastPathComponent
            NSWorkspace.shared.open(URL(fileURLWithPath: outputFolder))
        }
    
    }
    
}

