//
//  Grape.swift
//  Grape
//
//  Created by Jarrod Norwell on 4/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation

@objcMembers
public class GrapeCommon : NSObject {
    public static var documentDirectoryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    public static var grapeDirectoryURL: URL? {
        if let documentDirectoryURL {
            documentDirectoryURL.appending(component: "Grape")
        } else {
            nil
        }
    }
    
    public static var savesDirectoryURL: URL? {
        if let grapeDirectoryURL {
            grapeDirectoryURL.appending(component: "saves")
        } else {
            nil
        }
    }
    
    public static var sysdataDirectoryURL: URL? {
        if let grapeDirectoryURL {
            grapeDirectoryURL.appending(component: "sysdata")
        } else {
            nil
        }
    }
}

public struct AudioObject : @unchecked Sendable {
    public var buffer: UnsafeMutablePointer<Int16>
    public var samples: Int
}

public struct IconObject : @unchecked Sendable {
    public var buffer: UnsafeMutablePointer<UInt32>
}

public actor Grape {
    public let emulator: GrapeEmulator = GrapeEmulator.shared()
    
    public init() {}
    
    
    public func insert(cartridge: URL) {
        emulator.insert(cartridge: cartridge)
    }
    
    public func icon(cartridge: URL) -> IconObject {
        IconObject(buffer: emulator.icon(cartridge: cartridge))
    }
    
    
    public func pause() {
        emulator.pause()
    }
    
    public func start() {
        emulator.start()
    }
    
    public func stop() {
        emulator.stop()
    }
    
    public func unpause() {
        emulator.unpause()
    }
    
    
    public var paused: Bool {
        emulator.paused()
    }
    
    public var running: Bool {
        emulator.running()
    }
    
    
    public func touchBegan(point: CGPoint) {
        emulator.touchBegan(point: point)
    }
    
    public func touchEnded() {
        emulator.touchEnded()
    }
    
    public func touchMoved(point: CGPoint) {
        emulator.touchMoved(point: point)
    }
    
    
    public func press(button: UInt32) {
        emulator.press(button)
    }
    
    public func release(button: UInt32) {
        emulator.release(button)
    }
    
    
    public func load(state: URL) {
        emulator.load(state: state)
    }
    
    public func save(state: URL) {
        emulator.save(state: state)
    }
    
    
    public func audioCallback(output: @escaping (UnsafeMutablePointer<Int16>, Int) -> Void) {
        emulator.audioCallback = output
    }
    
    public func videoCallback(output: @escaping (UnsafeMutablePointer<UInt32>, UnsafeMutablePointer<UInt32>) -> Void) {
        emulator.videoCallback = output
    }
}
