//
//  GameDelegate.swift
//  AirChecker
//
//  Created by Baiyi Zhang on 2/25/24.
//

import Foundation

protocol GameDelegate: AnyObject {
    func removeChecker(row: Int, col: Int, completion: @escaping () -> Void)
}
