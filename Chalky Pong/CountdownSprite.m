//
//  CountdownSprite.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 19/07/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "CountdownSprite.h"

@implementation CountdownSprite

- (id)init {
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        frames = [NSMutableArray array];
        
        for (int i = 0; i <= 49; i++) {
            [frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Countdown_%d.png",i]]];
        }
        
        anim = [CCAnimation animationWithSpriteFrames:frames delay:0.04];
    }
    
    return self;
}

- (void)action
{
    [self runAction:[CCAnimate actionWithAnimation:anim]];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(removeAnim) userInfo:nil repeats:NO];
}

- (void)removeAnim
{
    frames = nil;
    anim = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    [self removeFromParentAndCleanup:YES];
}

@end
