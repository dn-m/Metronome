//
//  ScoreParser.swift
//  Metronome
//
//  Created by James Bean on 5/30/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import Rhythm

class ScoreParser {
    
    /// Things that can go wrong when parsing a score.
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
    
    /// Meters to be created during the parsing process
    internal var meters: [Meter] = []
    
    /// Builder to create the tempo stratum
    internal var tempoStratumBuilder = Tempo.Stratum.Builder()
    
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

        return Meter.Structure()
    }
    
    func parseScoreElement(_ yaml: Any) throws {
        
        print("parse score element: \(yaml)")
        
        if let meter = yaml as? String {
            
            // Either meter: 4/4, or
            // 4/4 x 8
            try parseMeterOneOrMany(meter)
            
        } else {
            
            // 4/4:
            //  offset, or
            // 4/4:
            // tempo:
        }
    }
    
    func parseMeterOneOrMany(_ string: String) throws {
        
        let components = string.components(separatedBy: " ")
        
        switch components.count {
        
        // Single meter, such as: 19/64
        case 1:
            add(meter: try ScoreParser.parseMeter(string))
            
        // Many meters, such as: 4/4 x 13
        case 3:
            
            let meter = try ScoreParser.parseMeter(components[0])
            
            guard let count = Int(components[2]) else {
                throw Error.illFormedMeter(string)
            }
            
            add(meter: meter, count: count)
            
        // Something went wrong
        default:
            throw Error.illFormedMeter(string)
        }
    }
    
    private func add(meter: Meter, count: Int = 1) {
        (0..<count).forEach { _ in self.meters.append(meter) }
    }
}

