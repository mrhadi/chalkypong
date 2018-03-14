//
//  AmbiguousObject.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 20/05/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "AmbiguousObject.h"
#import "CCShake.h"

@implementation AmbiguousObject

@synthesize chipmunkObjects;
@synthesize sprite;

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        chipmunkObjects = [[NSMutableSet alloc] init];
        
        PhysicObjectReader *physicObject = [[PhysicObjectReader alloc] initWithFile:@"PhysicShapes" forObject:name withMass:20];
        
		body = physicObject.body;
		body.data = self;
        
        sprite = [CCPhysicsSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png", name]];
        sprite.chipmunkBody = body;
        sprite.opacity = 0;
        
		[chipmunkObjects addObject:body];
        
        for (ChipmunkShape *shape in physicObject.shapes) {
            shape.friction = 0.2;
            shape.elasticity = 0.8;
            shape.collisionType = @"AmbiguousObject";
            
            [chipmunkObjects addObject:shape];
        }
        
        CCParticleSystem *particle = [CCParticleSystemQuad particleWithFile:@"Bomb.plist"];
        [sprite addChild:particle];
        
        particle.position = ccp(XSCALE(70), YSCALE(115));
        [particle resetSystem];
    }
    return self;
}

- (void)run
{
    effectHandle = [[SimpleAudioEngine sharedEngine] playEffect:@"fuse.mp3"];
    
    CDSoundEngine *engine = [CDAudioManager sharedManager].soundEngine;
    CDSoundSource *aSound =[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"fuse.mp3"];
    
    float seconds = [engine bufferDurationInSeconds:aSound.soundId];
    
    loopTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(run) userInfo:nil repeats:NO];
}

- (void)fadeIn
{
    [sprite runAction:[CCFadeIn actionWithDuration:1.0]];
}

- (void)fadeOut
{
    [self shake];
    [sprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.4], [CCCallFuncN actionWithTarget:self selector:@selector(removeMe)], nil]];
}

- (void)removeMe
{
    [sprite removeAllChildrenWithCleanup:YES];
    [sprite removeFromParent];
}

- (void)shake
{
    [sprite runAction:[CCShake actionWithDuration:0.1 amplitude:ccp(XSCALE(10),YSCALE(10)) dampening:NO shakes:6]];
}

- (void)fade
{
}

- (void)crack
{
}

- (void)flash
{
}

- (void)cleanUp
{
    [loopTimer invalidate];
    loopTimer = nil;
    
    [[SimpleAudioEngine sharedEngine] stopEffect:effectHandle];
}

@end
