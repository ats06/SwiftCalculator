//
//  CalcModel.swift
//  Calculator
//
//  Created by Atsushi on 2015/07/02.
//  Copyright (c) 2015年 atsushi. All rights reserved.
//

import Foundation

// doubleの有効桁数は15桁程度
// -> http://www.cc.kyoto-su.ac.jp/~yamada/programming/float.html#double

class CalcModel {
    // エラー種類。エラー時に表示する文字列も一緒に定義。
    enum ErrorType {
        case Ok
        case ZeroDivide
        case Overflow
        case Underflow
        
        func toString() -> String {
            switch self {
            case .Ok:
                return ""
            case .ZeroDivide:
                return "Error:Zero divide"
            case .Overflow:
                return "Error:Overflow"
            case .Underflow:
                return "Error:Underflow"
            }
        }
    }

    //----- field -----//
    var operand1: String = "0"
    var operand2: String = "0"
    var operatorType: String = ""

    func calculate() -> (result: String, error: ErrorType) {

        let val1 = atof(operand1)
        let val2 = atof(operand2)
        var result: Double = 0.0
        var errorType = ErrorType.Ok
        
        switch operatorType {
        case "+":
            result = val1 + val2
            break
        case "-":
            result = val1 - val2
            break
        case "×":
            result = val1 * val2
            break
        case "÷":
            if Int(val2) == 0 {
                errorType = ErrorType.ZeroDivide
            } else {
                result = val1 / val2
            }
            break
        default:
            break
        }

        if result >= DBL_MAX {
            errorType = ErrorType.Overflow
        } else if 0.0 < result && result <= DBL_MIN {
            errorType = ErrorType.Underflow
        }

        if errorType != ErrorType.Ok {
            return (errorType.toString(), errorType)
        } else {
            return (makeTextForDisp(result), errorType)
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

    
}
