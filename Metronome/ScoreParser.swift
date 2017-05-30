//
//  ScoreParser.swift
//  Metronome
//
//  Created by James Bean on 5/30/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import Rhythm

class ScoreParser {
    
    enum Error: Swift.Error {
        case illFormedMeter(String)
    }

    /// Creates `Meter` value with the given `string`. 
    ///
    /// The string must be in the format: `beats / subdivision`.
    ///
    ///     3/4 -> Meter(3,4)
    ///     12/13 -> fatalError
    ///     3,4 -> Error.illFormedMeter
    ///
    ///
    /// - Returns: Meter value
    /// - Throws: ScoreParser.Error
    /// - Warning: The Meter initializer will crash if given a non-power-of-two subdivision.
    static func parseMeter(_ string: String) throws -> Meter {
        
        let components = string.components(separatedBy: "/")
        
        guard
            let beatsString = components[safe: 0],
            let subdivisionString = components[safe: 1],
            let beats = Int(beatsString),
            let subdivision = Int(subdivisionString)
        else {
            throw Error.illFormedMeter(string)
        }
        
        return Meter(beats, subdivision)
    }
}

