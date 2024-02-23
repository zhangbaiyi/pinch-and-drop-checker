//
//  Statistics.swift
//  AirChecker
//
//  Created by Baiyi Zhang on 2/23/24.
//

import Foundation


class Statistics: ObservableObject{
    @Published var currentRound: Int = 0
    @Published var currentCount: Int = 0
    @Published var currentProgressOne: CGFloat = 0.0
    @Published var currentProgressTwo: CGFloat = 0.0
    @Published var currentProgressThree: CGFloat = 0.0
    
 
}
