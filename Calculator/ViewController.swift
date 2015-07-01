//
//  ViewController.swift
//  Calculator
//
//  Created by Atsushi on 2015/06/17.
//  Copyright (c) 2015年 atsushi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //----- enum -----//
    // 計算機状態定義
    enum CalcState {
        case DuringInput1   // 第1オペランド入力中
        case FinishInput1   // 第1オペランド入力終了(第2オペランドの入力開始を知るための状態)
        case DuringInput2   // 第2オペランド入力中
        case Calculated     // 計算結果表示中
        case ShowingError   // エラー表示中
    }
    
    // エラー種類。エラー時に表示する文字列も一緒に定義。
    enum ErrorType {
        case ZeroDivide
        case Overflow
        case Underflow

        func toString() -> String {
            switch self {
            case .ZeroDivide:
                return "Error:0 divide"
            case .Overflow:
                return "Error:Overflow"
            case .Underflow:
                return "Error:Underflow"
            }
        }
    }

    //----- field -----//
    // 初期状態は第1オペランド入力中
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
            display.text = "" + sender.currentTitle!
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

    // display Labelにエラー文字列をセットして表示
    func showError(errorType: ErrorType) {
        display.text = errorType.toString()
        firstOperandLabel.text = ""
        operatorLabel.text = ""
    }

    // これまでの入力値から計算 -> 値の保持とセットで別クラスに切り出したい。余裕あればやる。
    func Calculate() {
        // doubleの有効桁数は15桁程度
        // -> http://www.cc.kyoto-su.ac.jp/~yamada/programming/float.html#double
        let first: Double = atof(val1str)
        let second: Double = atof(val2str)
        var result: Double = 0.0

        switch operatorType {
        case "+":
            result = first + second
            break
        case "-":
            result = first - second
            break
        case "×":
            result = first * second
            break
        case "÷":
            if second == 0 {
                showError(ErrorType.ZeroDivide)
                setErrorState()
                return
            } else {
                result = first / second
            }
            break
        default:
            break
        }

        if result >= DBL_MAX {
            showError(ErrorType.Overflow)
            setErrorState()
        } else if 0.0 < result && result <= DBL_MIN {
            showError(ErrorType.Underflow)
            setErrorState()
        } else {
            display.text = makeTextForDisp(result)
            // 現在の表示を第1オペランドに
            val1str = display.text!
            firstOperandLabel.text = ""
        }
    }

    func makeTextForDisp(var value:Double) -> String {
        var valueStr = cutoffDecimalZero(String("\(value)"))  // ".0"落とす
        if !isInCapacity(valueStr) {
            // 10桁超えた場合は指数表示にして丸める
            valueStr = "".stringByAppendingFormat("%e", value)
            let r = valueStr.rangeOfString("e")
            let idx = advance(r!.startIndex, 0)
            let editedStr = cutoffDecimalZero(valueStr.substringToIndex(idx)) + valueStr.substringFromIndex(idx)
            return editedStr
        }
        return valueStr
    }

    // 小数点以下の余分な'0'を切り落とし
    func cutoffDecimalZero(var text: String) -> String {
        text = "".stringByAppendingFormat("%.10g", atof(text))
        return text
    }

    func setErrorState() {
        val1str = ""
        val2str = ""
        state = CalcState.ShowingError
    }
    
    func setup() {
        display.text = "0"
        display.layer.borderColor = UIColor.blackColor().CGColor
        display.layer.borderWidth = 0.5
        display.layer.cornerRadius = 5

        firstOperandLabel.text = ""
        operatorLabel.text = ""
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

