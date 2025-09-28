//
//  TestData.swift
//  Markey
//
//  Created by Kerstin Haustein on 27/09/2025.
//

import Testing
@testable import Markey

public struct TestData<InputData, OutputData> {
    let inputData: InputData
    let expectedResult: OutputData
    let description: String
}

extension TestData: CustomTestStringConvertible {
    public var testDescription: String {
        description
    }
}

extension Array: @retroactive CustomTestStringConvertible where Element == TestData<[MarketPrice], [MarketRowViewModel]> {
    public var testDescription: String {
        let typeDescription = self.map{ $0.description }.joined(separator: ", ")
        return typeDescription.isEmpty ? "Array of market prices" : typeDescription
    }
}
