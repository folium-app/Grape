//
//  Grape.swift
//  Grape
//
//  Created by Jarrod Norwell on 4/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

public enum NDSKey : UInt32 {
    case a = 1
    case b = 2
    case x = 1024
    case y = 2048
    case select = 4
    case start = 8
    case right = 16
    case left = 32
    case up = 64
    case down = 128
    case l = 512
    case r = 256
}

public class Grape {
    public var emulator: GrapeEmulator = .shared()
    
    public init() {}
    
    public func insert(_ cartridge: URL) {
        emulator.insert(cartridge)
    }
    
    public func icon(_ cartridge: URL) -> UnsafeMutablePointer<UInt32> {
        emulator.icon(cartridge)
    }
    
    public func start() {
        emulator.start()
    }
    
    public func stop() {
        emulator.stop()
    }
    
    public var isPaused: Bool {
        get {
            emulator.isPaused()
        }
        set {
            pause(newValue)
        }
    }
    
    public func pause(_ pause: Bool) {
        emulator.pause(pause)
    }
    
    public func ab(_ buffer: @escaping (UnsafeMutablePointer<Int16>, Int32) -> Void) {
        emulator.ab = buffer
    }
    
    public func fbs(_ buffers: @escaping (UnsafeMutablePointer<UInt32>, UnsafeMutablePointer<UInt32>) -> Void) {
        emulator.fbs = buffers
    }
    
    public func touchBegan(at point: CGPoint) {
        emulator.touchBegan(point)
    }
    
    public func touchEnded() {
        emulator.touchEnded()
    }
    
    public func touchMoved(at point: CGPoint) {
        emulator.touchMoved(point)
    }
    
    public func button(button: NDSKey, pressed: Bool) {
        emulator.button(button.rawValue, pressed: pressed)
    }
    
    public func loadState(_ completionHandler: @escaping (Bool) -> Void) {
        completionHandler(emulator.loadState())
    }
    
    public func saveState(_ completionHandler: @escaping (Bool) -> Void) {
        completionHandler(emulator.saveState())
    }
    
    public func load(state url: URL) {
        emulator.load(url)
    }
    
    public func save(state url: URL) {
        emulator.save(url)
    }
    
    public func updateSettings() {
        emulator.updateSettings()
    }
}
