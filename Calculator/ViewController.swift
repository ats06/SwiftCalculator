//
//  ViewController.swift
//  Calculator
//
//  Created by Atsushi on 2015/06/17.
//  Copyright (c) 2015年 atsushi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // 計算機状態定義
    enum CalcState {
        case DuringInput1
        case FinishInput1
        case DuringInput2
        case Calculated
    }

    // 初期状態は第1数入力中
    var state = CalcState.DuringInput1

    // 数字キー
    @IBOutlet weak var display: UILabel!
    @IBAction func buttonDigit(sender: UIButton) {
        switch state {
        case .DuringInput1:
            if display.text == "0" {
                display.text = sender.currentTitle!
            } else {
                display.text = addDigitString(display.text!, add:sender.currentTitle!)
//                display.text = display.text! + sender.currentTitle!
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
//            display.text = display.text! + sender.currentTitle!
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
    var operatorType: String = ""
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
    
    var val1str: String = ""
    var val2str: String = ""
    
    func str2value() -> Double {
        return atof(display.text!)
    }


    func showError() {
        display.text = "エラー"
    }
    
    func Calculate() {
        // doubleの有効桁数は15桁程度
        // -> http://www.cc.kyoto-su.ac.jp/~yamada/programming/float.html#double
        var first: Double = atof(val1str)
        var second: Double = atof(val2str)

        switch operatorType {
        case "+":
            display.text = String("\(first + second)")
            break
        case "-":
            display.text = String("\(first - second)")
            break
        case "×":
            display.text = String("\(first * second)")
            break
        case "÷":
            if second == 0 {
                showError()
            } else {
                display.text = String("\(first / second)")
            }
            break
        default:
            break
        }

        display.text = cutoff(display.text!)

        // 現在の表示を第1オペランド、
        val1str = display.text!
        println("calc: val1str:\(val1str) display:\(display.text!)")
    }

    func cutoff(text: String) -> String {
        let r = text.rangeOfString(".");
        let idx = advance(r!.startIndex, 1)
        if atoi(text.substringFromIndex(idx)) == 0 {
            let integerIdx = advance(r!.startIndex, 0)
            return text.substringToIndex(integerIdx)
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

