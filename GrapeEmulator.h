//
//  GrapeEmulator.h
//  Grape
//
//  Created by Jarrod Norwell on 4/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GrapeEmulator : NSObject {
    uint32_t inputs;
    NSURL *_url;
}

@property (nonatomic, strong, nullable) void (^ab) (int16_t*, int);
@property (nonatomic, strong, nullable) void (^fbs) (uint32_t*, uint32_t*);

+(GrapeEmulator *) sharedInstance NS_SWIFT_NAME(shared());

-(void) insertCartridge:(NSURL *)url NS_SWIFT_NAME(insert(_:));

-(uint32_t*) icon:(NSURL *)url;

-(void) start;
-(void) stop;

-(BOOL) isPaused;
-(void) pause:(BOOL)pause;

-(void) touchBegan:(CGPoint)point;
-(void) touchEnded;
-(void) touchMoved:(CGPoint)point;

-(void) button:(uint32_t)button pressed:(BOOL)pressed;

-(BOOL) loadState;
-(BOOL) saveState;

-(void) load:(NSURL *)url;
-(void) save:(NSURL *)url;

-(void) updateSettings;
@end

NS_ASSUME_NONNULL_END
