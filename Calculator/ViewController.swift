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
    }

    //----- field -----//
    var calcModel: CalcModel = CalcModel()

    // 計算機状態管理
    var state = CalcState.DuringInput1

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
        case .FinishInput1:
            display.text = sender.currentTitle!
            state = CalcState.DuringInput2
            break
        case .Calculated:
            display.text = sender.currentTitle!
            calcModel.operand1 = ""
            calcModel.operand2 = ""
            operatorLabel.text = ""
            state = CalcState.DuringInput1
            break
        default:
            if display.text == "0" {
                display.text = sender.currentTitle!
            } else {
                display.text = addDigitString(display.text!, add:sender.currentTitle!)
            }
            break
        }
    }

    // 表示文字列に押された数値を追加
    func addDigitString(base: String, add:String) -> String {
        let appendedStr = base + add
        if calcModel.isInCapacity(appendedStr) {
            return appendedStr
        }
        return base
    }

    // + - * / オペレーターボタン
    @IBAction func buttonOperator(sender: UIButton) {
        if state == CalcState.DuringInput2 {
            calcModel.operand2 = display.text!
            Calculate()
        }
        
        calcModel.operand1 = display.text!
        calcModel.operand2 = ""
        operatorLabel.text = sender.currentTitle

        firstOperandLabel.text = calcModel.operand1
        state = CalcState.FinishInput1
    }

    // '='ボタン
    @IBAction func button_equal(sender: AnyObject) {
        switch state {
        case .DuringInput2:
            calcModel.operand2 = display.text!
            Calculate()
            state = CalcState.Calculated
            break
        case .Calculated:
            calcModel.operand1 = display.text!
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
            calcModel.operand1 = ""
            firstOperandLabel.text = ""
            operatorLabel.text = ""
            state = CalcState.DuringInput1
        }
        display.text = "0"
    }

    // '.'ボタン
    @IBAction func buttonComma(sender: UIButton) {
        if display.text?.rangeOfString(".") == nil && display.text?.rangeOfString("e") == nil {
            display.text = display.text! + "."
        }
    }

    // 'TAX'ボタン
    @IBAction func buttonTax(sender: AnyObject) {
        calcModel.operand1 = display.text!
        calcModel.operand2 = String("\((100.0 + atof(taxTextField.text!)) / 100.0)")
        operatorLabel.text = "×"
        Calculate()
    }

    // これまでの入力値から計算
    func Calculate() {
        calcModel.operatorType = operatorLabel.text!
        
        let out = calcModel.calculate()
        display.text = out.result

        if out.error == CalcModel.ErrorType.Ok {
            calcModel.operand1 = display.text!
            firstOperandLabel.text = ""
        } else {
            calcModel.operand1 = ""
            calcModel.operand2 = ""
            firstOperandLabel.text = ""
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

