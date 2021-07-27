//
//  UIApplication.swift
//  iOS Example
//
//  Created by Johann Fong  on 25/7/21.
//

import Foundation
import SwiftUI

extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
