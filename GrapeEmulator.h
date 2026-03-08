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

@interface GrapeEmulator : NSObject
@property (nonatomic, strong, nullable) void (^audioCallback) (int16_t*, NSInteger);
@property (nonatomic, strong, nullable) void (^videoCallback) (uint32_t*, uint32_t*);

+(GrapeEmulator *) sharedInstance NS_SWIFT_NAME(shared());

-(void) insertCartridge:(NSURL *)url NS_SWIFT_NAME(insert(cartridge:));
-(uint32_t*) icon:(NSURL *)url NS_SWIFT_NAME(icon(cartridge:));

-(void) pause;
-(void) start;
-(void) stop;
-(void) unpause;

-(BOOL) isPaused NS_SWIFT_NAME(paused());
-(BOOL) isRunning NS_SWIFT_NAME(running());

-(void) touchBegan:(CGPoint)point NS_SWIFT_NAME(touchBegan(point:));
-(void) touchEnded;
-(void) touchMoved:(CGPoint)point NS_SWIFT_NAME(touchMoved(point:));

-(void) press:(uint32_t)button;
-(void) release:(uint32_t)button;

-(void) load:(NSURL *)url NS_SWIFT_NAME(load(state:));
-(void) save:(NSURL *)url NS_SWIFT_NAME(save(state:));
@end

NS_ASSUME_NONNULL_END
