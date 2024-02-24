//
//  CountView.swift
//  AirChecker
//
//  Created by Baiyi Zhang on 2/23/24.
//

import SwiftUI

struct CountView: View {
    @State var boxWidth: CGFloat
    @State var boxHeight: CGFloat
    
    @Binding var count: Int
    
    var stringList = ["Raise your hands.","Higher","Close your rings.","Hold on.","Almost there."]

    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
