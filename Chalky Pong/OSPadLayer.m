//
//  OSPadLayer.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 20/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "OSPadLayer.h"

@implementation OSPadLayer

@synthesize chipmunkObjects;
@synthesize sprite;

- (id)init
{
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        chipmunkObjects = [[NSMutableSet alloc] init];
		cpFloat mass = INFINITY;
        
        sprite = [CCPhysicsSprite spriteWithSpriteFrameName:@"pad_os.png"];
        
		body = [ChipmunkBody bodyWithMass:mass andMoment:cpMomentForBox(mass, sprite.contentSize.width, sprite.contentSize.height)];
		body.data = self;
		
        shape = [ChipmunkPolyShape boxWithBody:body width:sprite.contentSize.width height:sprite.contentSize.height];
        shape.friction = 1.0;
        shape.elasticity = 0.5;
        shape.data = self;
        shape.collisionType = @"OSPad";
        
        sprite.chipmunkBody = body;
        
        [chipmunkObjects addObject:body];
        [chipmunkObjects addObject:shape];
    }
    return self;
}

- (void)reset
{
    sprite.position = ccp(SCREEN_WIDTH / 2, globals.osPadHeight);
}

@end
