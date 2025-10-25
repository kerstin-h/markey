//
//  StringProtocol+replacing.swift
//  Markey
//
//  Created by Kerstin Haustein on 25/10/2025.
//

extension StringProtocol {
    var spacesUnderscored: any StringProtocol {
        self.replacingOccurrences(of: " ", with: "_")
    }
}
