//
//  RationalTests.swift
//  ArithmeticTools
//
//  Created by James Bean on 1/2/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import XCTest
import ArithmeticTools

class RationalTests: XCTestCase {

    struct R: Rational {
        
        var numerator: Int
        var denominator: Int

        init(_ numerator: Int, _ denominator: Int) {
            
            guard denominator != 0 else {
                fatalError("Cannot have Rational with denominator of 0")
            }
            
            self.numerator = numerator
            self.denominator = denominator
        }
    }
    
    func testInit() {
        _ = R(1,1)
    }
    
    func testEqualsSame() {
        let a = R(1,2)
        let b = R(1,2)
        XCTAssertEqual(a,b)
    }
    
    func testEqualsNotSimplified() {
        let a = R(3,16)
        let b = R(9,48)
        XCTAssertEqual(a,b)
    }
    
    func testNotEqual() {
        let a = R(1,16)
        let b = R(2,16)
        XCTAssertNotEqual(a,b)
    }
    
    func testFloatValueOne() {
        let r = R(1,1)
        XCTAssertEqual(r.floatValue, 1)
    }
    
    func testFloatValueDecimal() {
        let r = R(1,3)
        XCTAssertEqual(r.floatValue, 1/3)
    }
    
    func testFloatValueNegative() {
        let r = R(-1,5)
        XCTAssertEqual(r.floatValue, -(1/5))
    }
    
    func testInverseNil() {
        let r = R(0,1)
        XCTAssertNil(r.inverse)
    }
    
    func testInverse() {
        let r = R(1,13)
        XCTAssertEqual(r.inverse!, R(13,1))
    }
    
    func testInverseNegative() {
        let r = R(1,-13)
        XCTAssertEqual(r.inverse!, R(-13,1))
    }
    
    func testComparableSameDenominator() {
        let a = R(1,2)
        let b = R(2,3)
        XCTAssert(a < b)
        XCTAssert(b > a)
    }
    
    func testComparableSameNumerator() {
        let a = R(2,5)
        let b = R(2,17)
        XCTAssert(b < a)
        XCTAssert(a > b)
    }
    
    func testComparableHarder() {
        let a = R(13,19)
        let b = R(7,21)
        XCTAssert(b < a)
        XCTAssert(a > b)
    }
    
    func testHashValueEqual() {
        let a = R(1,2)
        let b = R(3,6)
        XCTAssertEqual(a.hashValue, b.hashValue)
    }
    
    func testHashValueNotEqual() {
        let a = R(1,13)
        let b = R(11,10948)
        XCTAssertNotEqual(a.hashValue, b.hashValue)
    }
    
    func testRespellWithNumeratorEqualToSelfValid() {
        let original = R(1,13)
        let new = original.respelling(numerator: 1)!
        XCTAssertEqual(new.numerator, 1)
        XCTAssertEqual(new.denominator, 13)
    }
    
    func testRespellWithNumeratorGreaterThanValid() {
        let original = R(1,13)
        let new = original.respelling(numerator: 3)!
        XCTAssertEqual(new.numerator, 3)
        XCTAssertEqual(new.denominator, 39)
    }
    
    func testRespellWithNumeratorLessThanValid() {
        let original = R(5,15)
        let new = original.respelling(numerator: 1)!
        XCTAssertEqual(new.numerator, 1)
        XCTAssertEqual(new.denominator, 3)
    }
    
    func testRespellWithDenominatorEqualToSelfValid() {
        let original = R(1,13)
        let new = original.respelling(denominator: 13)!
        XCTAssertEqual(new.numerator, 1)
        XCTAssertEqual(new.denominator, 13)
    }
    
    func testRespellWithDenominatorLessThanValid() {
        let original = R(5,10)
        let new = original.respelling(denominator: 6)!
        XCTAssertEqual(new.numerator, 3)
        XCTAssertEqual(new.denominator, 6)
    }
    
    func testRespellWithDenominatorGreaterThanValid() {
        let original = R(3,12)
        let new = original.respelling(denominator: 48)!
        XCTAssertEqual(new.numerator, 12)
        XCTAssertEqual(new.denominator, 48)
    }
    
    func testRespellWithDenominatorLessThanNil() {
        let original = R(3,7)
        XCTAssertNil(original.respelling(denominator: 6))
    }
    
    func testRespellWithDenominatorGreaterThanNil() {
        let original = R(3,7)
        XCTAssertNil(original.respelling(denominator: 8))
    }
    
    // MARK: - Arithmetic
    
    func testReciprocal() {
        XCTAssertEqual(R(1,5).reciprocal, R(5,1))
    }
    
    func testAddSameDenominator() {
        
        let a = R(2,5)
        let b = R(4,5)
        
        XCTAssertEqual(a + b, R(6,5))
    }
    
    func testAddSameDenominatorAndAssign() {
        
        var a = R(2,5)
        let b = R(4,5)
        a += b
        
        XCTAssertEqual(a, R(6,5))
    }
    
    func testAddDifferentDenominators() {
        
        let a = R(2,5) // 14/35
        let b = R(2,7) // 10/35
        
        XCTAssertEqual(a + b, R(24,35))
    }
    
    func testSubtractSameDenominator() {
        
        let a = R(2,5)
        let b = R(4,5)
        
        XCTAssertEqual(a - b, R(-2,5))
    }
    
    func testSubtractDifferentDenominators() {
        
        let a = R(2,5) // 14/35
        let b = R(2,7) // 10/35
        
        XCTAssertEqual(a - b, R(4,35))
    }
    
    func testSubtractDifferentDenominatorsAndAssign() {
        
        var a = R(2,5) // 14/35
        let b = R(2,7) // 10/35
        a -= b
        
        XCTAssertEqual(a, R(4,35))
    }
    
    func testMultiplySameDenominators() {
        
        let a = R(3,4)
        let b = R(12,4)
        
        XCTAssertEqual(a * b, R(36,16))
    }
    
    func testMultitplyDifferentDenominators() {
        
        let a = R(2,5) // 14/35
        let b = R(2,7) // 10/35
        
        XCTAssertEqual(a * b, R(4,35))
    }
    
    func testMultitplyDifferentDenominatorsAndAssign() {
        
        var a = R(2,5) // 14/35
        let b = R(2,7) // 10/35
        a *= b
        
        XCTAssertEqual(a, R(4,35))
    }
    
    func testDivideDifferentDenominators() {
        
        let a = R(4,7)
        let b = R(3,11)
        
        XCTAssertEqual(a / b, R(44,21))
    }
    
    func testDivideDifferentDenominatorsAndAssign() {
        
        var a = R(4,7)
        let b = R(3,11)
        a /= b
        
        XCTAssertEqual(a, R(44,21))
    }
}
