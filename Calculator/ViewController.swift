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
        case DuringInput1
        case FinishInput1
        case DuringInput2
        case Calculated
        case ShowingError
    }
    
    // エラー種類。エラー時に表示する文字列も一緒に定義。
    enum ErrorType {
        case ZeroDivide
        case Overflow

        func toString() -> String {
            switch self {
            case .ZeroDivide:
                return "Error:0 divide"
            case .Overflow:
                return "Error:Overflow"
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
            println("\(CalcState.DuringInput1) disp:\(display.text) val1:\(val1str) val2:\(val2str)")
            break
        case .FinishInput1:
            val1str = display.text!
            display.text = "" + sender.currentTitle!
            state = CalcState.DuringInput2
            println("\(CalcState.FinishInput1) disp:\(display.text) val1:\(val1str) val2:\(val2str)")
            break
        case .DuringInput2:
            display.text = addDigitString(display.text!, add:sender.currentTitle!)
            println("\(CalcState.DuringInput2) disp:\(display.text) val1:\(val1str) val2:\(val2str)")
            break
        case .Calculated:
            val1str = ""
            val2str = ""
            display.text = sender.currentTitle!
            state = CalcState.DuringInput1
            println("\(CalcState.Calculated) disp:\(display.text) val1:\(val1str) val2:\(val2str)")
            break
        default:
            break
        }
    }

    // 表示文字列に押された数値を追加
    func addDigitString(base: String, add:String) -> String {
        let NUM_OF_DIGIT_MAX = 10
        if let r = base.rangeOfString(".") {
            if base.utf16Count < (NUM_OF_DIGIT_MAX + 1) {
                return base + add
            }
        } else {
            if base.utf16Count < NUM_OF_DIGIT_MAX {
                return base + add
            }
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
            val1str = display.text!
            val2str = ""
        default:
            break
        }
        state = CalcState.FinishInput1
        operatorType = sender.currentTitle!
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
        if display.text == "0" {
            val1str = ""
            state = CalcState.DuringInput1
        } else {
            val2str = ""
            display.text = "0"
        }
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
        } else {
            display.text = hoge(result)
            // 現在の表示を第1オペランドに
            val1str = display.text!
        }
    }

    func hoge(var value:Double) -> String {
        var valueStr = cutoff(String("\(value)"))  // ".0"落とす
        if countElements(valueStr) > 10 {
            // 10桁(符号、小数点含む...)超えた場合は指数表示にして丸める
            valueStr = "".stringByAppendingFormat("%e", value)
            let r = valueStr.rangeOfString("e")
            let idx = advance(r!.startIndex, 0)
            let editedStr = cutoff(valueStr.substringToIndex(idx)) + valueStr.substringFromIndex(idx)
            return editedStr
        }
        return cutoff(String("\(value)"))
    }

    func cutoff(var text: String) -> String {
        if let r = text.rangeOfString(".") {
            let idx = advance(r.startIndex, 1)
            if atoi(text.substringFromIndex(idx)) == 0 {
                // 小数点以下が値を持たない場合、整数部だけの文字列に
                let integerIdx = advance(r.startIndex, 0)
                return text.substringToIndex(integerIdx)
            }
        }
        return text
    }
    
    func setErrorState() {
        val1str = ""
        val2str = ""
        state = CalcState.ShowingError
    }
    
    func setup() {
        display.text = "0"
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

