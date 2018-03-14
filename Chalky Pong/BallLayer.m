//
//  BallLayer.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 20/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "BallLayer.h"

@implementation BallLayer

@synthesize chipmunkObjects;
@synthesize sprite;
@synthesize body;
@synthesize basePos;
@synthesize hitBase;

- (id)init
{
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        chipmunkObjects = [[NSMutableSet alloc] init];
		cpFloat mass = 2.0;
        hitBase = NO;
        
        sprite = [CCPhysicsSprite spriteWithFile:@"ball.png"];
        
        int t = 100 + arc4random() % 200;
        int d = arc4random() % 2;
        
        if (d == 1)
            t = -t;
        
		body = [ChipmunkBody bodyWithMass:mass andMoment:cpMomentForCircle(mass, sprite.contentSize.width, sprite.contentSize.height, cpv(0, 0))];
		body.data = self;
        body.torque = t;
        
        shape = [ChipmunkCircleShape circleWithBody:body radius:sprite.contentSize.width / 2 offset:cpv(0, 0)];
        shape.friction = 0.3;
        shape.elasticity = 1.5;
        shape.data = self;
        shape.collisionType = @"Ball";
        
        sprite.chipmunkBody = body;
        
        [chipmunkObjects addObject:body];
        [chipmunkObjects addObject:shape];
    }
    return self;
}

- (void)drop:(cpVect)force
{
    body.force = force;
}

- (void)reset:(CCSprite *)baseOn
{
    sprite.position = ccp(SCREEN_WIDTH / 2, baseOn.position.y - (baseOn.contentSize.height / 2) - (sprite.contentSize.height / 2) - 1);
    basePos = sprite.position;
}

@end
