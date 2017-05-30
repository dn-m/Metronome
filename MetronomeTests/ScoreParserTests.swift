//
//  ScoreParserTests.swift
//  Metronome
//
//  Created by James Bean on 5/30/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import XCTest
import Rhythm
@testable import Metronome

class ScoreParserTests: XCTestCase {
    
    func testParseMeter() {
        let strings = ["4/4", "9/16", "13/128"]
        let expected = [Meter(4,4), Meter(9,16), Meter(13,128)]
        
        zip(strings, expected).forEach { string, meter in
            XCTAssertEqual(try! ScoreParser.parseMeter(string), meter)
        }
    }
}
