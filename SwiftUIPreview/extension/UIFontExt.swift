//
//  UIFontExt.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/10/10.
//

import UIKit

extension UIFont {
    
    static func CustomFont(name: String, size: CGFloat) -> UIFont {
        UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func PoppinsLatinBold(size: CGFloat) -> UIFont {
        UIFont(name: "PoppinsLatin-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func PoppinsLatinExtraBold(size: CGFloat) -> UIFont {
        UIFont(name: "PoppinsLatin-ExtraBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func PoppinsLatinExtraLight(size: CGFloat) -> UIFont {
        UIFont(name: "PoppinsLatin-ExtraLight", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func PoppinsLatinLight(size: CGFloat) -> UIFont {
        UIFont(name: "PoppinsLatin-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func PoppinsLatinMedium(size: CGFloat) -> UIFont {
        UIFont(name: "PoppinsLatin-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func PoppinsLatin(size: CGFloat) -> UIFont {
        UIFont(name: "PoppinsLatin-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func VAGRoundedNextBlack(size: CGFloat) -> UIFont {
        UIFont(name: "VAGRoundedNext-Black", size: size) ?? UIFont.systemFont(ofSize: size)
    }

}
