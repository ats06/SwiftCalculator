//
//  ViewController.swift
//  Calculator
//
//  Created by Atsushi on 2015/06/17.
//  Copyright (c) 2015年 atsushi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    //----- enum -----//
    // 計算機状態定義
    enum CalcState {
        case DuringInput1   // 第1オペランド入力中
        case FinishInput1   // 第1オペランド入力終了(第2オペランドの入力開始を知るための状態)
        case DuringInput2   // 第2オペランド入力中
        case Calculated     // 計算結果表示中
        case ShowingError   // エラー表示中
    }

    //----- field -----//
    var calcModel: CalcModel = CalcModel()

    // 計算機状態管理
    var state = CalcState.DuringInput1

    // 入力(文字列)
    var val1str: String = ""
    var val2str: String = ""
    var operatorType: String = ""

    // 入出力/結果 表示Label
    @IBOutlet weak var display: UILabel!
    // 第1オペランド表示Label
    @IBOutlet weak var firstOperandLabel: UILabel!
    // 選択中のオペレータ表示Label
    @IBOutlet weak var operatorLabel: UILabel!
    // 税率入力
    @IBOutlet weak var taxTextField: UITextField!

    // 数字キー
    @IBAction func buttonDigit(sender: UIButton) {
        switch state {
        case .ShowingError:
            display.text = sender.currentTitle!
            break
        case .DuringInput1:
            if display.text == "0" {
                display.text = sender.currentTitle!
            } else {
                display.text = addDigitString(display.text!, add:sender.currentTitle!)
            }
            break
        case .FinishInput1:
            display.text = sender.currentTitle!
            state = CalcState.DuringInput2
            break
        case .DuringInput2:
            display.text = addDigitString(display.text!, add:sender.currentTitle!)
            break
        case .Calculated:
            val1str = ""
            val2str = ""
            display.text = sender.currentTitle!
            operatorLabel.text = ""
            state = CalcState.DuringInput1
            break
        default:
            break
        }
    }

    // 表示桁数におさまっているか判定
    func isInCapacity(str: String) -> Bool {
        let NUM_OF_DIGIT_MAX = 10
        var isCapa = false
        if let r = str.rangeOfString(".") {
            if countElements(str) <= (NUM_OF_DIGIT_MAX + 1) {
                isCapa = true
            }
        } else if countElements(str) <= NUM_OF_DIGIT_MAX {
            isCapa = true
        }
        return isCapa
    }

    // 表示文字列に押された数値を追加
    func addDigitString(base: String, add:String) -> String {
        var appendedStr = base + add
        if isInCapacity(appendedStr) {
            return appendedStr
        }
        return base
    }

    // + - * / オペレーターボタン
    @IBAction func buttonOperator(sender: UIButton) {
        switch state {
        case .DuringInput2:
            val2str = display.text!
            Calculate()
            break
        case .Calculated:
            val2str = ""
        default:
            break
        }
        
        val1str = display.text!
        firstOperandLabel.text = val1str
        operatorLabel.text = sender.currentTitle
        operatorType = sender.currentTitle!
        state = CalcState.FinishInput1
    }

    // '='ボタン
    @IBAction func button_equal(sender: AnyObject) {
        switch state {
        case .DuringInput2:
            val2str = display.text!
            Calculate()
            state = CalcState.Calculated
            break
        case .Calculated:
            val1str = display.text!
            Calculate()
        default:
            break
        }
    }

    // 'C'ボタン
    @IBAction func buttonClear(sender: AnyObject) {
        if state == CalcState.DuringInput2 {
            state = CalcState.FinishInput1
        } else {
            val1str = ""
            firstOperandLabel.text = ""
            operatorLabel.text = ""
            state = CalcState.DuringInput1
        }
        display.text = "0"
    }

    // '.'ボタン
    @IBAction func buttonComma(sender: UIButton) {
        if display.text == "0" {
            display.text = "0."
        } else if display.text?.rangeOfString(".") == nil {
            display.text = display.text! + "."
        }
    }

    // 'TAX'ボタン
    @IBAction func buttonTax(sender: AnyObject) {
        val1str = display.text!
        val2str = String("\((100.0 + atof(taxTextField.text)) / 100.0)")
        operatorType = "×"
        Calculate()
    }

    // これまでの入力値から計算
    func Calculate() {
        calcModel.operand1 = val1str
        calcModel.operand2 = val2str
        calcModel.operatorType = operatorType
        
        var out = calcModel.calculate()
        display.text = out.result
        if out.error == CalcModel.ErrorType.Ok {
            val1str = display.text!
            firstOperandLabel.text = ""
        } else {
            val1str = ""
            val2str = ""
            firstOperandLabel.text = ""
            state = CalcState.ShowingError
        }
    }

    // text fieldの入力でreturn押されたらキーボード閉じる
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        taxTextField.resignFirstResponder()
        return true
    }
    // text fieldの入力でキーボード外をタッチされたらキーボード閉じる
    @IBAction func tapGestureRecognizer(sender: AnyObject) {
        taxTextField.resignFirstResponder()
    }
    
    func setup() {
        display.text = "0"
        display.layer.borderColor = UIColor.blackColor().CGColor
        display.layer.borderWidth = 0.5
        display.layer.cornerRadius = 5

        firstOperandLabel.text = ""
        operatorLabel.text = ""
        
        taxTextField.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

