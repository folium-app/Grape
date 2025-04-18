// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import GrapeObjC

public struct Grape : @unchecked Sendable {
    public static let shared = Grape()
    
    fileprivate let emulator = GrapeObjC.shared()
    
    public func information(for cartridge: URL) -> (icon: UnsafeMutablePointer<UInt32>, title: String) {
        (emulator.iconForCartridge(at: cartridge), emulator.titleForCartridge(at: cartridge))
    }
    
    public func insertCartridge(from url: URL) -> CartridgeType {
        emulator.insertCartridge(at: url)
    }
    
    public func updateScreenLayout(with size: CGSize) {
        emulator.updateScreenLayout(size)
    }
    
    public func pause() {
        emulator.pause()
    }
    
    public func stop() {
        emulator.stop()
    }
    
    public func start() { emulator.start() }
    
    public func running() -> Bool { emulator.running() }
    
    public func audioBuffer() -> UnsafeMutablePointer<Int16> {
        emulator.audioBuffer()
    }
    
    public func microphoneBuffer(with buffer: UnsafeMutablePointer<Int16>) {
        emulator.microphoneBuffer(buffer)
    }
        
    public func fbs(_ buf: @escaping (UnsafeMutablePointer<UInt32>, UnsafeMutablePointer<UInt32>) -> Void) { emulator.fbs = buf }
    
    public func videoBufferSize() -> CGSize {
        emulator.videoBufferSize()
    }
    
    public func touchBegan(at point: CGPoint) {
        emulator.touchBegan(at: point)
    }
    
    public func touchEnded() {
        emulator.touchEnded()
    }
    
    public func touchMoved(at point: CGPoint) {
        emulator.touchMoved(at: point)
    }
    
    public func input(_ button: Int32, _ pressed: Bool) {
        if pressed {
            emulator.virtualControllerButtonDown(button)
        } else {
            emulator.virtualControllerButtonUp(button)
        }
    }
    
    public func updateSettings() {
        emulator.updateSettings()
    }
    
    public func loadState(_ completionHandler: @escaping (Bool) -> Void) { completionHandler(emulator.loadState()) }
    public func saveState(_ completionHandler: @escaping (Bool) -> Void) { completionHandler(emulator.saveState()) }
}
