//
//  JetSprite.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 27/06/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "JetSprite.h"

@implementation JetSprite

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        frames = [NSMutableArray array];
        
        for (int i = 0; i <= 20; i++) {
            [frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_%d.png", name, i]]];
        }
        
        anim = [CCAnimation animationWithSpriteFrames:frames delay:0.015f];
        anim.loops = -1;
    }
    
    return self;
}

- (void)action
{
    [self runAction:[CCAnimate actionWithAnimation:anim]];
}

- (void)removeAnim
{
    frames = nil;
    anim = nil;
    
    [self removeAllChildrenWithCleanup:YES];
    [self removeFromParentAndCleanup:YES];
}

@end
