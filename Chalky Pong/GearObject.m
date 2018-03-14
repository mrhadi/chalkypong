//
//  GearObject.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 14/05/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "GearObject.h"

@implementation GearObject

@synthesize chipmunkObjects;
@synthesize motor;
@synthesize sprite;
@synthesize body;
@synthesize hit;

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        chipmunkObjects = [[NSMutableSet alloc] init];
        globals = [GameGlobals sharedGlobal];
        hit = 0;
        
        PhysicObjectReader *physicObject = [[PhysicObjectReader alloc] initWithFile:@"PhysicShapes" forObject:name withMass:500];
        
        body = physicObject.body;
        body.data = self; 
        
        sprite = [CCPhysicsSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png", name]];
        sprite.chipmunkBody = body;
        sprite.opacity = 0;
        
        [chipmunkObjects addObject:body];
        
        for (ChipmunkShape *shape in physicObject.shapes) {
            shape.friction = 0.8;
            shape.elasticity = 0.7;
            shape.collisionType = @"GearObject";
            
            [chipmunkObjects addObject:shape];
        }
    }
    return self;
}

- (void)run
{
    effectHandle = [[SimpleAudioEngine sharedEngine] playEffect:@"motor3.mp3" pitch:0.3f pan:0.0f gain:0.3f];
    
    CDSoundEngine *engine = [CDAudioManager sharedManager].soundEngine;
    CDSoundSource *aSound =[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"motor3.mp3"];
    
    float seconds = [engine bufferDurationInSeconds:aSound.soundId];
    
    loopTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(run) userInfo:nil repeats:NO];
}

- (void)fadeIn
{
    [sprite runAction:[CCFadeIn actionWithDuration:2.0]];
}

- (void)fadeOut
{
    [sprite runAction:[CCFadeOut actionWithDuration:1.0]];
}

- (void)cleanUp
{
    [loopTimer invalidate];
    [moveTimer invalidate];
    
    loopTimer = nil;
    moveTimer = nil;
    
    [sprite stopAllActions];
    
    [[SimpleAudioEngine sharedEngine] stopEffect:effectHandle];
}

- (void)moveMe
{
    [self move];
    
    moveTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(move) userInfo:nil repeats:YES];
}

- (void)move
{
    int minY = globals.myPadHeight - YSCALE(100);
    int maxY = globals.osPadHeight - YSCALE(200);
    int y = minY + arc4random() % (maxY - minY);
    
    int minX = XSCALE(100);
    int maxX = SCREEN_WIDTH - XSCALE(100);
    int x = minX + arc4random() % (maxX - minX);
    
    id move1 = [CCMoveTo actionWithDuration:5.0 position:ccp(x, y)];
    id ease1 = [CCEaseIn actionWithAction:move1 rate:5];
    [sprite runAction:ease1];
}

@end
