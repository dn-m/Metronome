//
//  ScoreParser.swift
//  Metronome
//
//  Created by James Bean on 5/30/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import Foundation
import ArithmeticTools
import Rhythm

class ScoreParser {
    
    /// Things that can go wrong when parsing a score.
    enum Error: Swift.Error {
        case illFormedScore(Any)
        case illFormedScoreElement(Any)
        case illFormedMeter(String)
        case illFormedTempo(Any)
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
    
    // TODO: Rename to findMeter?
    static func extractMeter(from yaml: [String: Any]) -> Meter? {
        
        for (key, _) in yaml {
            if let meter = try? parseMeter(key) {
                return meter
            }
        }
        
        return nil
    }
    
    // TODO: Rename to findTempo?
    static func extractTempo(from yaml: [String: Any], subdivision: Subdivision)
        throws -> (Tempo, Bool)?
    {
        
        for (key, value) in yaml where key == "tempo" || key == "tempo_change" {
        
            var bpm: Double? {
                switch value {
                case let double as Double:
                    return double
                case let float as Float:
                    return Double(float)
                case let int as Int:
                    return Double(int)
                case let string as String:
                    return Double(string)
                default:
                    return nil
                }
            }
            
            guard let beatsPerMinute = bpm else {
                throw Error.illFormedTempo(yaml)
            }
            
            let tempo = Tempo(beatsPerMinute, subdivision: subdivision)
            let interpolating = key == "tempo_change"
            return (tempo, interpolating)
        }
        
        return nil
    }
    
    // - TODO: Rename to findOffsetDuration
    static func extractOffsetDuration(from yaml: [String: Any], subdivision: Subdivision)
        -> MetricalDuration?
    {
        for (key, _) in yaml {
            if let meter = try? ScoreParser.parseMeter(key) {
                return meter.metricalDuration
            } else if let beats = Int(key) {
                return MetricalDuration(beats, subdivision)
            }
        }
        return nil
    }
    
    private var meterOffset: MetricalDuration = .zero
    
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
    
    private func prepare() {
        meterOffset = .zero
        meters = []
        tempoStratumBuilder = Tempo.Stratum.Builder()
    }
    
    func parse() throws -> Meter.Structure {
        
        // Ensure clean state
        prepare()
        
        // Do our best to parse each element
        try score.forEach(parseScoreElement)
        
        // Compile the tempo stratum, and combine with meters
        return Meter.Structure(meters: meters, tempi: tempoStratumBuilder.build())
    }
    
    func parseScoreElement(_ yaml: Any) throws {
        
        switch yaml {
            
        // Declarations of a single meter (e.g., 4/4) or a count of meters (e.g., 4/4 x 8)
        // without tempo changes
        case let meter as String:
            try parseMeterOneOrMany(meter)
            
        // Declarations of a single meter with tempo changes
        case let meterWithTempoChanges as [String: Any]:
            try parseScoreElementWithAttributes(meterWithTempoChanges)
            
        // Something went wrong
        default:
            throw Error.illFormedScoreElement(yaml)
        }
    }
    
    // - FIXME: This requires some beautification.
    func parseScoreElementWithAttributes(_ yaml: [String: Any]) throws {
        
        guard let meter = ScoreParser.extractMeter(from: yaml) else {
            throw Error.illFormedScoreElement(yaml)
        }

        var tempoChanges: [(Tempo, MetricalDuration, Bool)] = []

        if let (downbeatTempo, interpolating) = try ScoreParser.extractTempo(
            from: yaml,
            subdivision: meter.denominator
        )
        {
            tempoChanges.append((downbeatTempo, meterOffset, interpolating))
        }

        // TODO: break up at each stage of organization
        for (_, value) in yaml {
            
            if let offsetAttributes = value as? [[String: Any]] {

                for offsetAttribute in offsetAttributes {
                    
                    guard
                        let beatOffset = ScoreParser.extractOffsetDuration(
                            from: offsetAttribute,
                            subdivision: meter.denominator
                        )
                    else {
                        throw Error.illFormedScoreElement(yaml)
                    }
                    
                    if let (offsetTempo, interpolating) = try ScoreParser.extractTempo(
                        from: offsetAttribute,
                        subdivision: meter.denominator
                    )
                    {
                        let info = (offsetTempo, meterOffset + beatOffset, interpolating)
                        tempoChanges.append(info)
                    }
                }
            }
        }
        
        tempoChanges.forEach(add)
        add(meter: meter)
    }
    
    func parseMeterOneOrMany(_ string: String) throws {
        
        let components = string.components(separatedBy: " ")
        
        switch components.count {
        
        // Single meter, such as: 19/64
        case 1:
            add(meter: try ScoreParser.parseMeter(string))
            
        // Many meters (e.g., 4/4 x 13)
        case 3:
            let meter = try ScoreParser.parseMeter(components[0])
            guard let count = Int(components[2]) else { throw Error.illFormedMeter(string) }
            add(meter: meter, count: count)
            
        // Something went wrong
        default:
            throw Error.illFormedMeter(string)
        }
    }
    
    private func add(meter: Meter, count: Int = 1) {
        (0..<count).forEach { _ in
            self.meters.append(meter)
            self.meterOffset += meter.metricalDuration
        }
    }
    
    private func add(tempo: Tempo, at offset: MetricalDuration, interpolating: Bool) {
        tempoStratumBuilder.add(tempo, at: offset, interpolating: interpolating)
    }
}

