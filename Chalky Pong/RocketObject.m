//
//  RocketObject.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 18/06/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "RocketObject.h"
#import "CCShake.h"

@implementation RocketObject

@synthesize chipmunkObjects;
@synthesize sprite;
@synthesize hit;
@synthesize myDelegate;
@synthesize runCount;

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        chipmunkObjects = [[NSMutableSet alloc] init];
        globals = [GameGlobals sharedGlobal];
        hit = 0;
        runCount = 1;
        runCounter = 0;
        duringCleanup = NO;
        
        PhysicObjectReader *physicObject = [[PhysicObjectReader alloc] initWithFile:@"PhysicShapes" forObject:name withMass:INFINITY];
        
		body = physicObject.body;
		body.data = self;
        body.moment = INFINITY;
        
        sprite = [CCPhysicsSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png", name]];
        sprite.chipmunkBody = body;
        sprite.opacity = 0;
        
        jetAnim = [[JetSprite alloc] initWithName:name];
        [sprite addChild:jetAnim];
        
		[chipmunkObjects addObject:body];
        
        for (ChipmunkShape *shape in physicObject.shapes) {
            shape.friction = 0.1;
            shape.elasticity = 0.8;
            shape.collisionType = @"RocketObject";
            
            [chipmunkObjects addObject:shape];
        }
    }
    return self;
}

- (void)run
{
    [jetAnim action];
    [self goRight];
} 

- (void)sound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"rocket1.mp3"];
}

- (void)goRight
{
    if (runCounter >= runCount) {
        [self removeMe];
        
        return;
    }
    
    runCounter++;
    
    sprite.flipX = NO;
    jetAnim.flipX = NO;
    
    sprite.position = ccp(0, RND(globals.myPadHeight + YSCALE(300), globals.osPadHeight - YSCALE(700)));
    jetAnim.position = ccp(-(sprite.contentSize.width / 2) + XSCALE(20), sprite.contentSize.height / 2);
    
    fadeTimer = [NSTimer scheduledTimerWithTimeInterval:2.6 target:self selector:@selector(fadeOut) userInfo:nil repeats:NO];
    fireTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(fire) userInfo:nil repeats:YES];
    
    [sprite runAction:[CCSequence actions:
                       [CCCallFuncN actionWithTarget:self selector:@selector(sound)],
                       [CCDelayTime actionWithDuration:1.0],
                       [CCCallFuncN actionWithTarget:self selector:@selector(fadeIn)],
                       [CCMoveTo actionWithDuration:2.0 position:ccp(SCREEN_WIDTH, sprite.position.y)],
                       [CCCallFuncN actionWithTarget:self selector:@selector(setZeroPos)],
                       [CCDelayTime actionWithDuration:2.0],
                       [CCCallFuncN actionWithTarget:self selector:@selector(goLeft)],
                       nil
                       ]];
}

- (void)goLeft
{
    if (runCounter >= runCount) {
        [self removeMe];
        
        return;
    }
    
    runCounter++;
    
    sprite.flipX = YES;
    jetAnim.flipX = YES;
    
    sprite.position = ccp(SCREEN_WIDTH, RND(globals.myPadHeight + YSCALE(300), globals.osPadHeight - YSCALE(700)));
    jetAnim.position = ccp(sprite.contentSize.width + (jetAnim.contentSize.width / 2), sprite.contentSize.height / 2);
    
    fadeTimer = [NSTimer scheduledTimerWithTimeInterval:2.6 target:self selector:@selector(fadeOut) userInfo:nil repeats:NO];
    fireTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(fire) userInfo:nil repeats:YES];
    
    [sprite runAction:[CCSequence actions:
                       [CCCallFuncN actionWithTarget:self selector:@selector(sound)],
                       [CCDelayTime actionWithDuration:1.0],
                       [CCCallFuncN actionWithTarget:self selector:@selector(fadeIn)],
                       [CCMoveTo actionWithDuration:2.0 position:ccp(0, sprite.position.y)],
                       [CCCallFuncN actionWithTarget:self selector:@selector(setZeroPos)],
                       [CCDelayTime actionWithDuration:2.0],
                       [CCCallFuncN actionWithTarget:self selector:@selector(goRight)],
                       nil
                       ]];
}

- (void)fire
{
    if (duringCleanup) return;
    
    if (sprite== nil) return;
    
    @try {
        if (sprite.position.x > 0 && sprite.position.x < SCREEN_WIDTH) {
            NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSValue valueWithCGPoint:sprite.position] forKey:@"position"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FireRocket" object:nil userInfo:dic];
            
            effectHandle = [[SimpleAudioEngine sharedEngine] playEffect:@"fire2.mp3"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"**fire: %@", exception.description);
    }
    @finally {
    }
}

- (void)shake
{
    [sprite runAction:[CCShake actionWithDuration:0.5 amplitude:ccp(XSCALE(10),YSCALE(10)) dampening:NO shakes:6]];
}

- (void)flipLeft
{
    sprite.flipX = YES;
    jetAnim.flipX = YES;
}

- (void)flipRight
{
    sprite.flipX = NO;
    jetAnim.flipX = NO;
}

- (void)fadeIn
{
    [sprite runAction:[CCFadeIn actionWithDuration:0.2]];
    [jetAnim runAction:[CCFadeIn actionWithDuration:0.3]];
}

- (void)fadeOut
{
    if (duringCleanup) return;
    
    @try {
        [fireTimer invalidate];
        fireTimer = nil;
        
        [[SimpleAudioEngine sharedEngine] stopEffect:effectHandle];
        
        [sprite runAction:[CCFadeOut actionWithDuration:0.5]];
        [jetAnim runAction:[CCFadeOut actionWithDuration:0.6]];
    }
    @catch (NSException *exception) {
        NSLog(@"**fadeOut: %@", exception.description);
    }
    @finally {
    }
}

- (void)setZeroPos
{
    sprite.position = ccp(0, 0);
}

- (void)cleanUp
{
    duringCleanup = YES;
    fireTimer = nil;
    fadeTimer = nil;
    
    [jetAnim removeAnim];
    
    [sprite stopAllActions];
}

- (void)removeMe
{
    duringCleanup = YES;
    
    @try {
        fireTimer = nil;
        fadeTimer = nil;
        
        [jetAnim removeAnim];
        
        [sprite stopAllActions];
        
        [sprite removeAllChildrenWithCleanup:YES];
        [sprite removeFromParent];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CleanupRocket" object:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"**removeMe : %@", exception.description);
    }
    @finally {
    }
}

@end
