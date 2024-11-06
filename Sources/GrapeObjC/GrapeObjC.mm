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

@implementation GrapeObjC
-(GrapeObjC *) init {
    if (self = [super init]) {
        NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSURL *grapeDirectory = [documentsDirectory URLByAppendingPathComponent:@"Grape"];
        
        if (!Settings::load([grapeDirectory.path UTF8String])) {
            ScreenLayout::addSettings();
            Settings::save();
        } else {
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
        }
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

-(uint32_t*) iconForGameAtURL:(NSURL *)url {
    NdsIcon icon([url.path UTF8String]);
    uint32_t* data = new uint32_t[32 * 32];
    memcpy(data, icon.getIcon(), 32 * 32 * sizeof(uint32_t));
    return data;
}

-(NSString *) titleForGameAtURL:(NSURL *)url {
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

-(void) insertGame:(NSURL *)url {
    NSURL *savesDirectory = [[[url URLByDeletingLastPathComponent] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"saves"];
    NSString *gameName = [url.lastPathComponent stringByReplacingOccurrencesOfString:url.pathExtension withString:@"sav"];
    const char* saveName = [[savesDirectory URLByAppendingPathComponent:gameName].path UTF8String];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    Settings::directBoot = [defaults boolForKey:@"grape.directBoot"];
    Settings::threaded2D = [[NSNumber numberWithBool:[defaults boolForKey:@"grape.threaded2D"]] intValue];
    Settings::threaded3D = [[NSNumber numberWithBool:[defaults boolForKey:@"grape.threaded3D"]] intValue];
    
    if (grapeEmulator)
        grapeEmulator.reset();
    
    isGBA = [url.pathExtension.lowercaseString isEqualToString:@"gba"];
    if (url && [url.pathExtension.lowercaseString isEqualToString:@"nds"]) {
        grapeEmulator = std::make_unique<Core>([url.path UTF8String]);
    } else if (url && [url.pathExtension.lowercaseString isEqualToString:@"gba"]) {
        grapeEmulator = std::make_unique<Core>("", [url.path UTF8String]);
    } else {
        grapeEmulator = std::make_unique<Core>("", "");
    }
    
    stop_run = false;
    pause_emulation = false;
}

-(void) updateScreenLayout:(CGSize)size {
    layout.update(size.width, size.height, isGBA);
}

-(BOOL) togglePause {
    pause_emulation = !pause_emulation;
    return pause_emulation;
}

-(void) stop {
    stop_run = true;
    pause_emulation = true;
}

-(void) step {
    if (!pause_emulation) {
        grapeEmulator->runFrame();
        if (isGBA)
            grapeEmulator->cartridgeGba.writeSave();
        else
            grapeEmulator->cartridgeNds.writeSave();
    }
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
