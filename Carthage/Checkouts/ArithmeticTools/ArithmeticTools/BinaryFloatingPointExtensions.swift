//
//  BinaryFloatingPointExtensions.swift
//  ArithmeticTools
//
//  Created by James Bean on 5/7/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import Foundation

extension BinaryFloatingPoint {
    
    /// Scales a `BinaryFloatingPoint` from the given `sourceRange` to the given
    /// `destinationRange`.
    public mutating func scale(
        from source: ClosedRange<Self>,
        to destination: ClosedRange<Self>
    ) -> Self
    {
        let sourceWidth = source.upperBound - source.lowerBound
        let destinationWidth = destination.upperBound - destination.lowerBound
        let position = (self - source.lowerBound) / sourceWidth
        return position * destinationWidth + destination.lowerBound
    }
    
    /// - returns: A `BinaryFloatingPoint` value scaled from the given `sourceRange` to the
    /// given `destinationRange`.i
    public func scaled(
        from sourceRange: ClosedRange<Self>,
        to destinationRange: ClosedRange<Self>
    ) -> Self
    {
        var copy = self
        return copy.scale(from: sourceRange, to: destinationRange)
    }
}
