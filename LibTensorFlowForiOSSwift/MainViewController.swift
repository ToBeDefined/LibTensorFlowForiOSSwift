//
//  MainViewController.swift
//  LibTensorFlowForiOSSwift
//
//  Created by 邵伟男 on 2017/7/13.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    static let NoDataStringValue: String = "无输入或无返回数据"
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var runBtn: UIButton!
    @IBOutlet weak var outputTextView: UITextView!
    
    
    let operation: RunInferenceOperation = RunInferenceOperation.sharedInstance()
    var lastFire: Date = Date()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        operation.initModel()
        
        self.inputTextField.returnKeyType = .go
        self.inputTextField.clearButtonMode = .always
        self.inputTextField.delegate = self
        self.inputTextField.addTarget(self,
                                      action: #selector(textFieldDidEdit(_:)),
                                      for: UIControlEvents.editingChanged)
        
        self.runBtn.layer.cornerRadius = 3
        self.runBtn.layer.borderWidth = 2
        self.runBtn.layer.borderColor = UIColor.brown.cgColor
        
        self.outputTextView.layer.borderWidth = 1
        self.outputTextView.layer.borderColor = UIColor.orange.cgColor
        self.outputTextView.layer.cornerRadius = 4
        let tap = UITapGestureRecognizer.init(target: self,
                                              action: #selector(resignTextFieldFirstResponder))
        self.outputTextView.addGestureRecognizer(tap)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.inputTextField.resignFirstResponder()
    }
    
    @objc func resignTextFieldFirstResponder() {
        self.inputTextField.resignFirstResponder()
    }
    
    @IBAction func runModelBtnClicked(_ sender: Any) {
        self.inputTextField.resignFirstResponder()
        runModel(with: self.inputTextField.text)
    }
    
    func runModel(with text: String?) {
        let string = text ?? ""
        if string == "" {
            self.outputTextView.text = MainViewController.NoDataStringValue
            return
        }
        let resultArray = operation.runModel(with: string)
        self.outputTextView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        self.outputTextView.text = getString(with: resultArray)
    }
    
}

extension MainViewController {
    func getString(with array: [EmojiValue]?) -> String {
        guard let array = array, array.count > 0 else {
            return MainViewController.NoDataStringValue
        }
        
        var resultString: String = ""
        for emojiValue in array {
            let emojiString = emojiValue.emoji
            let confidenceString = String.init(format: "%.5f", emojiValue.confidence)
            let string = emojiString + " : " + confidenceString + "\n"
            resultString.append(string)
        }
        return resultString
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        runModel(with: textField.text)
        return true
    }
    
    @objc func textFieldDidEdit(_ textField: UITextField) {
        if textField.text == nil || textField.text == "" {
            self.outputTextView.text = MainViewController.NoDataStringValue
            return
        }
        
        let now = Date()
        if now.timeIntervalSince(self.lastFire) >= 0.2 {
            runModel(with: textField.text)
            self.lastFire = now
        }
    }
}


