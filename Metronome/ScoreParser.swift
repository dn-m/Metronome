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
        case illFormedScore(Any)
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
    
    // TODO: Meter with multiplier
    
    /// Meters to be created during the parsing process
    private var meters: [Meter] = []
    
    /// Builder to create the tempo stratum
    private var tempoStratumBuilder = Tempo.Stratum.Builder()
    
    /// Data to be parsed
    private let score: [Any]
    
    // MARK: - Initializers
    
    /// Creates a `ScoreParser` with the given `yaml` structure.
    ///
    /// - Throws: ScoreParser.Error if the given `yaml` is not a `[Any]`.
    ///
    public init(yaml: Any) throws {
        
        guard let yamlScore = yaml as? [Any] else {
            throw Error.illFormedScore(yaml)
        }

        self.score = yamlScore
    }
    
    func parse() throws -> Meter.Structure {
        try score.forEach(parseScoreElement)

        // let tempoStratum = tempoStratumBuilder.build()
        // return Meter.Structure(meters: meters, tempi: tempoStratum)
        
        fatalError()
    }
    
    func parseScoreElement(_ yaml: Any) throws {
        
        print("parse score element: \(yaml)")
    }
}

