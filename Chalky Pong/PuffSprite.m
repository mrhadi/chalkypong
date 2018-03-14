//
//  PuffSprite.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 21/05/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "PuffSprite.h"

@implementation PuffSprite

- (id)init {
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        frames = [NSMutableArray array];
        
        for (int i = 0; i <= 29; i++) {
            [frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Puff-Gray_%d.png",i]]];
        }
        
        if (animSpeed == 0) {
            animSpeed = 0.04f;
        }
        
        anim = [CCAnimation animationWithSpriteFrames:frames delay:animSpeed];
    }
    
    return self;
}

- (id)initWithSpeed:(float)speed
{
    animSpeed = speed;
    
    self = [self init];
    
    return self;
}

- (void)action
{
    [self runAction:[CCAnimate actionWithAnimation:anim]];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(removeAnim) userInfo:nil repeats:NO];
}

- (void)removeAnim
{
    frames = nil;
    anim = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    [self removeFromParentAndCleanup:YES];
}

@end
