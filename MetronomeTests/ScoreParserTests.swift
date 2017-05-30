//
//  ScoreParserTests.swift
//  Metronome
//
//  Created by James Bean on 5/30/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import XCTest
import Rhythm
import Yams
@testable import Metronome

class ScoreParserTests: XCTestCase {
    
    func testParseMeter() {
        let strings = ["4/4", "9/16", "13/128"]
        let expected = [Meter(4,4), Meter(9,16), Meter(13,128)]
        
        zip(strings, expected).forEach { string, meter in
            XCTAssertEqual(try! ScoreParser.parseMeter(string), meter)
        }
    }
    
    func testParseIllFormedScore() {
        let yamlString = "key: value"
        let yaml = try! Yams.load(yaml: yamlString) as Any
        XCTAssertThrowsError(try ScoreParser(yaml: yaml))
    }
    
    func testParseMeters() {
        let yamlString = "- 4/4\n- 9/16\n- 13/128"
        let yaml = try! Yams.load(yaml: yamlString) as Any
        let scoreParser = try! ScoreParser(yaml: yaml)
        let _ = try! scoreParser.parse()
        XCTAssertEqual(scoreParser.meters, [Meter(4,4), Meter(9,16), Meter(13,128)])
    }
    
    func testParseMetersMany() {
        let yamlString = "- 4/4\n- 9/16 x 10 \n- 13/128"
        let yaml = try! Yams.load(yaml: yamlString) as Any
        let scoreParser = try! ScoreParser(yaml: yaml)
        let meterStructure = try! scoreParser.parse()
        XCTAssertEqual(
            meterStructure.meters,
            [
                Meter(4,4),
                Meter(9,16),
                Meter(9,16),
                Meter(9,16),
                Meter(9,16),
                Meter(9,16),
                Meter(9,16),
                Meter(9,16),
                Meter(9,16),
                Meter(9,16),
                Meter(9,16),
                Meter(13,128)
            ]
        )
    }
    
    func testParseMeterWithTempoOnDownbeat() {
        let yamlString = "- 4/4:\n  tempo: 120"
        let yaml = try! Yams.load(yaml: yamlString) as Any
        let scoreParser = try! ScoreParser(yaml: yaml)
        let meterStructure = try! scoreParser.parse()
        print(meterStructure)
    }
}
