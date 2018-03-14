//
//  BirdObject.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 15/06/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "BirdObject.h"
#import "CCShake.h"

@implementation BirdObject

@synthesize chipmunkObjects;
@synthesize sprite;
@synthesize hit;

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        chipmunkObjects = [[NSMutableSet alloc] init];
        globals = [GameGlobals sharedGlobal];
        hit = 0;
        
        PhysicObjectReader *physicObject = [[PhysicObjectReader alloc] initWithFile:@"PhysicShapes" forObject:name withMass:100];
        
		body = physicObject.body;
		body.data = self;
        body.moment = INFINITY;
        
        sprite = [CCPhysicsSprite node];
        sprite.chipmunkBody = body;
        sprite.opacity = 0;
        
        birdAnim = [[BirdSprite alloc] initWithName:name];
        birdAnim.opacity = 0;
        [sprite addChild:birdAnim];
        
		[chipmunkObjects addObject:body];
        
        for (ChipmunkShape *shape in physicObject.shapes) {
            shape.friction = 0.1;
            shape.elasticity = 0.8;
            shape.collisionType = @"BirdObject";
            
            [chipmunkObjects addObject:shape];
        }
    }
    return self;
}

- (void)goRight
{
    [self sound];
    [self moveRight];
}

- (void)goLeft
{
    [self sound];
    [self flipLeft];
    [self moveLeft];
}

- (void)moveLeft
{
    ccBezierConfig bezier1;
    bezier1.controlPoint_1 = ccp(XSCALE(60) + arc4random() % (int)(SCREEN_WIDTH / 2), globals.myPadHeight + arc4random() % globals.osPadHeight);
    bezier1.controlPoint_2 = ccp((SCREEN_WIDTH / 2) + arc4random() % (int)SCREEN_WIDTH - XSCALE(60), globals.myPadHeight + arc4random() % globals.osPadHeight);
    bezier1.endPosition = ccp(XSCALE(20), globals.myPadHeight + arc4random() % globals.osPadHeight);
    
    ccBezierConfig bezier2;
    bezier1.controlPoint_1 = ccp(XSCALE(60) + arc4random() % (int)(SCREEN_WIDTH / 2), globals.myPadHeight + arc4random() % globals.osPadHeight);
    bezier1.controlPoint_2 = ccp((SCREEN_WIDTH / 2) + arc4random() % (int)SCREEN_WIDTH - XSCALE(60), globals.myPadHeight + arc4random() % globals.osPadHeight);
    bezier2.endPosition = ccp(SCREEN_WIDTH - XSCALE(20), globals.myPadHeight + arc4random() % globals.osPadHeight);
    
    [sprite runAction:[CCSequence actions:
                       [CCBezierTo actionWithDuration:3.5 bezier:bezier1],
                       [CCCallFuncN actionWithTarget:self selector:@selector(flipRight)],
                       [CCBezierTo actionWithDuration:3.3 bezier:bezier2],
                       [CCCallFuncN actionWithTarget:self selector:@selector(flipLeft)],
                       [CCCallFuncN actionWithTarget:self selector:@selector(moveLeft)],
                       nil
                       ]];
}

- (void)moveRight
{
    ccBezierConfig bezier1;
    bezier1.controlPoint_1 = ccp(XSCALE(40) + arc4random() % (int)SCREEN_WIDTH - XSCALE(40), globals.myPadHeight + arc4random() % globals.osPadHeight);
    bezier1.controlPoint_2 = ccp(XSCALE(40) + arc4random() % (int)SCREEN_WIDTH - XSCALE(40), globals.myPadHeight + arc4random() % globals.osPadHeight);
    bezier1.endPosition = ccp(SCREEN_WIDTH - XSCALE(20), globals.myPadHeight + arc4random() % globals.osPadHeight);
    
    ccBezierConfig bezier2;
    bezier1.controlPoint_1 = ccp(XSCALE(40) + arc4random() % (int)SCREEN_WIDTH - XSCALE(40), globals.myPadHeight + arc4random() % globals.osPadHeight);
    bezier1.controlPoint_2 = ccp(XSCALE(40) + arc4random() % (int)SCREEN_WIDTH - XSCALE(40), globals.myPadHeight + arc4random() % globals.osPadHeight);
    bezier2.endPosition = ccp(XSCALE(20), globals.myPadHeight + arc4random() % globals.osPadHeight);
    
    [sprite runAction:[CCSequence actions:
                       [CCBezierTo actionWithDuration:3.5 bezier:bezier1],
                       [CCCallFuncN actionWithTarget:self selector:@selector(flipLeft)],
                       [CCBezierTo actionWithDuration:3.3 bezier:bezier2],
                       [CCCallFuncN actionWithTarget:self selector:@selector(flipRight)],
                       [CCCallFuncN actionWithTarget:self selector:@selector(moveRight)],
                       nil
                       ]];
}

- (void)sound
{
    effectHandle = [[SimpleAudioEngine sharedEngine] playEffect:@"bird2.mp3"];
    
    CDSoundEngine *engine = [CDAudioManager sharedManager].soundEngine;
    CDSoundSource *aSound =[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"bird2.mp3"];
    
    float seconds = [engine bufferDurationInSeconds:aSound.soundId] + 1.5;
    
    soundTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(sound) userInfo:nil repeats:NO];
}

- (void)shake
{
    [sprite runAction:[CCShake actionWithDuration:0.5 amplitude:ccp(XSCALE(10),YSCALE(10)) dampening:NO shakes:6]];
}

- (void)flipLeft
{
    birdAnim.flipX = YES;
}

- (void)flipRight
{
    birdAnim.flipX = NO;
}

- (void)fadeIn
{
    [birdAnim action];
    [birdAnim runAction:[CCFadeIn actionWithDuration:1.0]];
}

- (void)fadeOut
{
    [birdAnim runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.4], [CCCallFuncN actionWithTarget:self selector:@selector(removeMe)], nil]];
}

- (void)removeMe
{
    [sprite stopAllActions];
    
    [sprite removeAllChildrenWithCleanup:YES];
    [sprite removeFromParent];
}

- (void)cleanUp
{
    [soundTimer invalidate];
    soundTimer = nil;
    
    [[SimpleAudioEngine sharedEngine] stopEffect:effectHandle];
    
    [birdAnim removeAnim];
}

@end
