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

public actor Grape {
    public let emulator: GrapeEmulator = GrapeEmulator.shared()
    
    public init() {}
    
    
    public func insert(cartridge: URL) {
        emulator.insert(cartridge: cartridge)
    }
    
    public func icon(cartridge: URL) throws -> [UInt32] {
        let data = try Data(contentsOf: cartridge)
        
        func readU32(_ offset: Int) -> UInt32 {
            data.withUnsafeBytes { $0.load(fromByteOffset: offset, as: UInt32.self) }
        }
        
        let bannerOffset = Int(readU32(0x68))
        
        // palette (16 colors BGR555)
        var palette: [UInt32] = Array(repeating: 0, count: 16)
        
        for i in 0..<16 {
            let color: UInt16 = data.withUnsafeBytes {
                $0.load(fromByteOffset: bannerOffset + 0x220 + i*2, as: UInt16.self)
            }
            
            let r = UInt32((color >> 0) & 0x1F)
            let g = UInt32((color >> 5) & 0x1F)
            let b = UInt32((color >> 10) & 0x1F)
            
            let r8 = (r * 255) / 31
            let g8 = (g * 255) / 31
            let b8 = (b * 255) / 31
            
            palette[i] = 0xFF000000 | (r8 << 16) | (g8 << 8) | b8
        }
        
        let iconData = data.subdata(in: bannerOffset + 0x20 ..< bannerOffset + 0x20 + 512)
        
        var pixels = [UInt32](repeating: 0, count: 32 * 32)
        
        for tileY in 0..<4 {
            for tileX in 0..<4 {
                for y in 0..<8 {
                    for x in 0..<8 {
                        
                        let tileIndex = tileY * 4 + tileX
                        let tileOffset = tileIndex * 32
                        let byteIndex = tileOffset + y * 4 + x / 2
                        
                        let byte = iconData[byteIndex]
                        
                        let paletteIndex =
                        (x % 2 == 0) ? Int(byte & 0x0F) : Int(byte >> 4)
                        
                        let px = tileX * 8 + x
                        let py = tileY * 8 + y
                        
                        pixels[py * 32 + px] = palette[paletteIndex]
                    }
                }
            }
        }
        
        return pixels
    }
    
    // public func icon(cartridge: URL) -> UnsafePointer<UInt32> {
    //     emulator.icon(cartridge: cartridge)
    // }
    
    
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
