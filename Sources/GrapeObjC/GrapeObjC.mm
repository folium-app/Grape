//
//  GrapeObjC.mm
//  Grape
//
//  Created by Jarrod Norwell on 8/8/2024.
//

#import "GrapeObjC.h"

#include "core.h"
#include "defines.h"
#include "settings.h"
#include "common/nds_icon.h"
#include "common/screen_layout.h"

#include <cstdint>
#include <vector>

std::unique_ptr<Core> grapeEmulator;
ScreenLayout layout;
std::condition_variable cv;
std::mutex mx;

@implementation GrapeObjC
-(GrapeObjC *) init {
    if (self = [super init]) {
        NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSURL *grapeDirectory = [documentsDirectory URLByAppendingPathComponent:@"Grape"];
        
        std::string basePath = [grapeDirectory.path UTF8String];
        Settings::basePath = basePath;
        Settings::bios9Path = basePath + "/sysdata/bios9.bin";
        Settings::bios7Path = basePath + "/sysdata/bios7.bin";
        Settings::firmwarePath = basePath + "/sysdata/firmware.bin";
        Settings::gbaBiosPath = basePath + "/sysdata/gba_bios.bin";
        Settings::sdImagePath = basePath + "/sysdata/sd.img";
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        Settings::directBoot = [defaults boolForKey:@"grape.directBoot"];
        Settings::threaded2D = [[NSNumber numberWithInteger:[defaults integerForKey:@"grape.threaded2D"]] intValue];
        Settings::threaded3D = [[NSNumber numberWithInteger:[defaults integerForKey:@"grape.threaded3D"]] intValue];
        Settings::dsiMode = [[NSNumber numberWithInteger:[defaults integerForKey:@"grape.dsiMode"]] intValue];
        
        ScreenLayout::addSettings();
        Settings::save();
    } return self;
}

+(GrapeObjC *) sharedInstance {
    static GrapeObjC *sharedInstance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(uint32_t*) iconForCartridge:(NSURL *)url {
    NdsIcon icon([url.path UTF8String]);
    uint32_t* data = new uint32_t[32 * 32];
    memcpy(data, icon.getIcon(), 32 * 32 * sizeof(uint32_t));
    return data;
}

-(NSString *) titleForCartridge:(NSURL *)url {
    FILE* rom = fopen([url.path UTF8String], "rb");
    
    uint32_t iconTitleOffset = 0;
    fseek(rom, 0x68, SEEK_SET);
    fread(&iconTitleOffset, sizeof(uint32_t), 1, rom);
    
    uint16_t title[128] = {0};
    fseek(rom, iconTitleOffset + 0x340, SEEK_SET);
    fread(title, sizeof(uint16_t), 128, rom);
    fclose(rom);

    // Create an NSString from the UTF-16 title
    NSString *string = [NSString stringWithCharacters:(const unichar*)title length:128];
    return string;
}

-(CartridgeType) insertCartridge:(NSURL *)url {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    Settings::directBoot = [defaults boolForKey:@"grape.directBoot"];
    Settings::threaded2D = [[NSNumber numberWithBool:[defaults boolForKey:@"grape.threaded2D"]] intValue];
    Settings::threaded3D = [[NSNumber numberWithBool:[defaults boolForKey:@"grape.threaded3D"]] intValue];
    Settings::dsiMode = [[NSNumber numberWithInteger:[defaults integerForKey:@"grape.dsiMode"]] intValue];
    
    if (grapeEmulator)
        grapeEmulator.reset();
    
    self->url = url;
    
    
    isGBA = [url.pathExtension.lowercaseString isEqualToString:@"gba"];
    if (isGBA)
        grapeEmulator = std::make_unique<Core>("", [url.path UTF8String]);
    else
        grapeEmulator = std::make_unique<Core>([url.path UTF8String], "");
    
    NSURL *directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    grapeEmulator->saveStates.setPath([[[[directory URLByAppendingPathComponent:@"Grape"] URLByAppendingPathComponent:@"states"] URLByAppendingPathComponent:[[[url lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathComponent:@".state"]].path UTF8String], isGBA);
    
    return isGBA ? GBA : NDS;
}

-(void) updateScreenLayout:(CGSize)size {
    layout.update(size.width, size.height, isGBA);
}

-(void) stopCore:(BOOL)full {
    {
        std::lock_guard<std::mutex> guard(mx);
        isRunning = false;
        cv.notify_one();
    }
    
    // Wait for the core thread to stop
    if (coreThread)
    {
        coreThread->join();
        delete coreThread;
        coreThread = nullptr;
    }
    
    // Wait for the save thread to stop
    if (saveThread)
    {
        saveThread->join();
        delete saveThread;
        saveThread = nullptr;
    }
    
    if (full) {
        if (grapeEmulator) {
            grapeEmulator.reset();
        }
    }
}

-(void) startCore:(BOOL)full {
    if (full) {
        [self stopCore:full];
        
        try {
            isGBA = [url.pathExtension.lowercaseString isEqualToString:@"gba"];
            if (isGBA)
                grapeEmulator = std::make_unique<Core>("", [url.path UTF8String]);
            else
                grapeEmulator = std::make_unique<Core>([url.path UTF8String], "");
        } catch (CoreError error) {
            NSLog(@"error = %u", error);
        }
    }
    
    if (grapeEmulator) {
        isRunning = true;
        coreThread = new std::thread([]() {
            while ([[GrapeObjC sharedInstance] running]) {
                grapeEmulator->runFrame();
             
                if (auto buf = [[GrapeObjC sharedInstance] buffer])
                    buf([[GrapeObjC sharedInstance] videoBuffer]);
            }
        });
        
        saveThread = new std::thread([&]() {
            while ([[GrapeObjC sharedInstance] running]) {
                std::unique_lock<std::mutex> lock(mx);
                cv.wait_for(lock, std::chrono::seconds(3), [&]{ return ![[GrapeObjC sharedInstance] running]; });
                grapeEmulator->cartridgeNds.writeSave();
                grapeEmulator->cartridgeGba.writeSave();
            }
        });
    }
}

-(BOOL) running {
    return isRunning;
}

-(void) pause {
    isRunning ? [self stopCore:false] : [self startCore:false];
}

-(void) stop {
    [self stopCore:true];
}

-(void) start {
    [self startCore:true];
}

-(int16_t *) audioBuffer {
    static std::vector<int16_t> buffer(1024 * 2);
    const auto original = grapeEmulator->spu.getSamples(699);
    for (int i = 0; i < 1024; i++) {
        uint32_t sample = original[i * 699 / 1024];
        buffer[i * 2 + 0] = sample >>  0;
        buffer[i * 2 + 1] = sample >> 16;
    }
    delete[] original;
    return buffer.data();
}

-(void) microphoneBuffer:(int16_t *)buffer {
    grapeEmulator->spi.sendMicData(buffer, 1024, 48000);
}

-(uint32_t *) videoBuffer {
    static std::vector<uint32_t> framebuffer;
    if (isGBA)
        framebuffer.resize(240 * 160);
    else
        framebuffer.resize(256 * 192 * 2);
    grapeEmulator->gpu.getFrame(framebuffer.data(), isGBA);
    
    return framebuffer.data();
}

-(CGSize) videoBufferSize {
    if (isGBA)
        return {240, 160};
    else
        return {256, 192};
}

-(void) loadState {
    switch (grapeEmulator->saveStates.checkState()) {
        case STATE_SUCCESS:
            NSLog(@"[%s] success", __FUNCTION__);
            break;
        case STATE_FILE_FAIL:
            NSLog(@"[%s] file fail", __FUNCTION__);
            break;
        case STATE_FORMAT_FAIL:
            NSLog(@"[%s] format fail", __FUNCTION__);
            break;
        case STATE_VERSION_FAIL:
            NSLog(@"[%s] version fail", __FUNCTION__);
            break;
    }
    
    [self stopCore:false];
    grapeEmulator->saveStates.loadState();
    [self startCore:false];
}

-(void) saveState {
    switch (grapeEmulator->saveStates.checkState()) {
        case STATE_SUCCESS:
            NSLog(@"[%s] success", __FUNCTION__);
            break;
        case STATE_FILE_FAIL:
            NSLog(@"[%s] file fail", __FUNCTION__);
            break;
        case STATE_FORMAT_FAIL:
            NSLog(@"[%s] format fail", __FUNCTION__);
            break;
        case STATE_VERSION_FAIL:
            NSLog(@"[%s] version fail", __FUNCTION__);
            break;
    }
    
    [self stopCore:false];
    grapeEmulator->saveStates.saveState();
    [self startCore:false];
}

-(void) touchBeganAtPoint:(CGPoint)point {
    grapeEmulator->input.pressScreen();
    
    auto x = layout.getTouchX(point.x, point.y);
    auto y = layout.getTouchY(point.x, point.y);
    
    grapeEmulator->spi.setTouch(x, y);
}

-(void) touchEnded {
    grapeEmulator->input.releaseScreen();
    grapeEmulator->spi.clearTouch();
}

-(void) touchMovedAtPoint:(CGPoint)point {
    auto x = layout.getTouchX(point.x, point.y);
    auto y = layout.getTouchY(point.x, point.y);
    
    grapeEmulator->spi.setTouch(x, y);
}

-(void) virtualControllerButtonDown:(int)button {
    grapeEmulator->input.pressKey(button);
}

-(void) virtualControllerButtonUp:(int)button {
    grapeEmulator->input.releaseKey(button);
}

-(void) updateSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    Settings::directBoot = [defaults boolForKey:@"grape.directBoot"];
    Settings::threaded2D = [[NSNumber numberWithInteger:[defaults integerForKey:@"grape.threaded2D"]] intValue];
    Settings::threaded3D = [[NSNumber numberWithInteger:[defaults integerForKey:@"grape.threaded3D"]] intValue];
    Settings::dsiMode = [[NSNumber numberWithInteger:[defaults integerForKey:@"grape.dsiMode"]] intValue];
}
@end
