//
//  IntervalRelation.swift
//  ArithmeticTools
//
//  Created by James Bean on 2/10/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

/// Implementation of
/// [Allen's Interval Algebra](https://en.wikipedia.org/wiki/Allen%27s_interval_algebra).
///
/// ## Background
///
/// From [Thomas A. Alspaugh](http://www.ics.uci.edu/~alspaugh/cls/shr/allen.html#Allen1983-mkti):
/// > In 1983 James F. Allen published a paper in which he proposed thirteen basic relations
/// between time intervals that are **distinct**, **exhaustive**, and **qualitative**.
///
/// > - **Distinct** because no pair of definite intervals can be related by
/// more than one of the relationships
/// > - **Exhaustive** because any pair of definite intervals are described by
/// one of the relations
/// > - **Qualitative** (rather than quantitative) because no numeric time spans are considered
///
/// The naming conventions used in this implementation are those of
/// [Allen](https://en.wikipedia.org/wiki/James_F._Allen), refined by
/// [Krokhin et al.](http://www.ics.uci.edu/~alspaugh/cls/shr/allen.html#Allen1983-mkti).
///
public struct IntervalRelation: InvertibleOptionSet {
    
    // MARK: - Cases
    
    /// `x` _precedes_ `y`
    ///
    ///     x: |---|
    ///     y:       |---|
    ///
    public static var precedes = IntervalRelation(rawValue: 1 << 0)
    
    /// `x` _meets_ `y`
    ///
    ///     x: |----|
    ///     y:      |----|
    ///
    public static var meets = IntervalRelation(rawValue: 1 << 1)
    
    /// `x` _overlaps_ `y`
    ///
    ///     x: |------|
    ///     y:    |------|
    ///
    public static var overlaps = IntervalRelation(rawValue: 1 << 2)
    
    /// `x` _is finished by_ `y`
    ///
    ///     x: |---------|
    ///     y:      |----|
    ///
    public static var finishedBy = IntervalRelation(rawValue: 1 << 3)
    
    /// `x` _contains_ `y`
    ///
    ///     x: |----------|
    ///     y:    |----|
    ///
    public static var contains = IntervalRelation(rawValue: 1 << 4)
    
    /// `x` _starts_ `y`
    ///
    ///     x: |-----|
    ///     y: |----------|
    ///
    public static var starts = IntervalRelation(rawValue: 1 << 5)
    
    /// `x` _equals_ `y`
    ///
    ///     x: |----------|
    ///     y: |----------|
    ///
    public static var equals = IntervalRelation(rawValue: 1 << 6)
    
    /// `x` _is started by_ `y`
    ///
    ///     x: |----------|
    ///     y: |-----|
    ///
    public static var startedBy = IntervalRelation(rawValue: 1 << 7)
    
    /// `x` _is contained by_ `y`
    ///
    ///
    ///     x:    |----|
    ///     y: |----------|
    ///
    public static var containedBy = IntervalRelation(rawValue: 1 << 8)
    
    /// `x` _finishes_ `y`
    ///
    ///     x:      |-----|
    ///     y: |----------|
    ///
    public static var finishes = IntervalRelation(rawValue: 1 << 9)
    
    /// `x` _is overlapped by_ `y`
    ///
    ///     x:    |------|
    ///     y: |------|
    ///
    public static var overlappedBy = IntervalRelation(rawValue: 1 << 10)
    
    /// `x` _is met by_ `y`
    ///
    ///     x:      |----|
    ///     y: |----|
    ///
    public static var metBy = IntervalRelation(rawValue: 1 << 11)
    
    /// `x` _is preceded by_ `y`
    ///
    ///     x:       |---|
    ///     y: |---|
    ///
    public static var precededBy = IntervalRelation(rawValue: 1 << 12)
    
    // MARK - Instance Properties
    
    /// Amount of options contained herein.
    public var optionsCount: Int {
        return 13
    }
    
    /// Raw value.
    public let rawValue: Int
    
    // MARK - Initializers
    
    /// Create an IntervalRelationship with `rawValue`.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension IntervalRelation: CustomStringConvertible {
    
    // MARK: - CustomStringConvertible
    
    /// Printed description.
    public var description: String {
        switch rawValue {
        case 1 << 0:
            return "precedes"
        case 1 << 1:
            return "meets"
        case 1 << 2:
            return "overlaps"
        case 1 << 3:
            return "finishedBy"
        case 1 << 4:
            return "contains"
        case 1 << 5:
            return "starts"
        case 1 << 6:
            return "equals"
        case 1 << 7:
            return "startedBy"
        case 1 << 8:
            return "during"
        case 1 << 9:
            return "finishes"
        case 1 << 10:
            return "overlappedBy"
        case 1 << 11:
            return "metBy"
        case 1 << 12:
            return "precededBy"
        default:
            return "\(rawValue)"
        }
    }
}

/// Interface retroactively unifying `ClosedRange` and `CountableClosedRange`, which are, for
/// some reason, not unified by a common super-protocol.
public protocol ClosedRangeProtocol: Semigroup {
    
    /// Type of bounds.
    associatedtype Bound: Comparable
    
    /// Lower bound.
    var lowerBound: Bound { get }
    
    /// Upper bound.
    var upperBound: Bound { get }
    
    /// Create a `ClosedRangeProtocol` type with the given `uncheckedBounds`.
    init(uncheckedBounds: (lower: Bound, upper: Bound))
}

/// Retroactively model `ClosedRange` as conforming to `ClosedRangeProtocol`.
extension ClosedRange: ClosedRangeProtocol { }

/// Retroactively model `CountableClosedRange` as conforming to `ClosedRangeProtocol`.
extension CountableClosedRange: ClosedRangeProtocol { }

extension ClosedRangeProtocol {
    
    /// - returns: Union of two `ClosedRangeProtocol`-conforming types.
    public static func + (lhs: Self, rhs: Self) -> Self {
        let lower = min(lhs.lowerBound, rhs.upperBound)
        let upper = max(lhs.lowerBound, rhs.upperBound)
        return Self(uncheckedBounds: (lower: lower, upper: upper))
    }
    
    /// - returns: `IntervalRelationship` between this `ClosedRangeProtocol`-conform type and
    /// another.
    public func relation(with range: Self) -> IntervalRelation {
        
        if upperBound < range.lowerBound {
            return .precedes
        } else if upperBound == range.lowerBound {
            return .meets
        } else if lowerBound < range.lowerBound && range.openContains(upperBound) {
            return .overlaps
        } else if upperBound == range.upperBound && openContains(range.lowerBound) {
            return .finishedBy
        } else if openContains(range.lowerBound) && openContains(range.upperBound) {
            return .contains
        } else if lowerBound == range.lowerBound && range.openContains(upperBound) {
            return .starts
        } else if lowerBound == range.lowerBound && openContains(range.upperBound) {
            return .startedBy
        } else if range.openContains(lowerBound) && range.openContains(upperBound) {
            return .containedBy
        } else if upperBound == range.upperBound && range.openContains(lowerBound) {
            return .finishes
        } else if upperBound > range.upperBound && range.openContains(lowerBound) {
            return .overlappedBy
        } else if lowerBound == range.upperBound {
            return .metBy
        } else if lowerBound > range.upperBound {
            return .precededBy
        }
        
        return .equals
    }
    
    /// - returns: `true` if the given `value` is greater than the `lowerBound` and
    /// `upperBound`. Otherwise, `false`.
    private func openContains(_ value: Bound) -> Bool {
        return value > lowerBound && value < upperBound
    }
}
