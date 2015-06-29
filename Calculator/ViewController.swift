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
    }
    
    // エラー種類。エラー時に表示する文字列も一緒に定義。
    enum ErrorType {
        case ZeroDivide
        case Overflow
        func toString() -> String {
            switch self {
            case .ZeroDivide:
                return "エラー:0除算"
            case .Overflow:
                return "エラー:オーバーフロー"
            }
        }
    }

    //----- field -----//
    // 初期状態は第1数入力中
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
            } else {
                result = first / second
            }
            break
        default:
            break
        }

        if result >= DBL_MAX {
            showError(ErrorType.Overflow)
        } else {
            display.text = hoge(result)
        }

        // 現在の表示を第1オペランドに
        val1str = display.text!
    }

    func hoge(var value:Double) -> String {
        if value >= 1.0e+10 {
            var i: Int
            for i = 0; value >= 10.0; i++ {
                value /= 10
            }
            let str = cutoff(String("\(value)"), needRound:true) + String("e+\(i)")
            println(str)
            return str
        } else if value <= 1.0e-8 {
            var i: Int
            for i = 0; value < 1.0; i++ {
                value *= 10
            }
            let str = cutoff(String("\(value)"), needRound:true) + String("e-\(i)")
            println("hoge: value:\(value)")
            println("hoge: \(str)")
            return str
        }
        return cutoff(String("\(value)"), needRound:false)
    }

    func cutoff(var text: String, needRound: Bool) -> String {
        if let r = text.rangeOfString(".") {
            let idx = advance(r.startIndex, 1)
            if atoi(text.substringFromIndex(idx)) == 0 {
                // 小数点以下が値を持たない場合、整数部だけの文字列に
                let integerIdx = advance(r.startIndex, 0)
                return text.substringToIndex(integerIdx)
            } else if needRound {
                // 10の累乗表示する場合、小数点以下6桁で値を丸める
                let ORDER_OF_DISP = 1000000.0
                var num = round(atof(text) * ORDER_OF_DISP) / ORDER_OF_DISP
                println("num:\(num)")
                return String("\(num)")
            }
        }
        return text
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

