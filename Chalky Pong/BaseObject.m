//
//  BaseObject.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 10/05/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "BaseObject.h"

@implementation BaseObject

@synthesize chipmunkObjects;
@synthesize sprite;

- (id)init
{
    self = [super init];
    if (self) {
        chipmunkObjects = [[NSMutableSet alloc] init];
        
        PhysicObjectReader *physicObject = [[PhysicObjectReader alloc] initWithFile:@"PhysicBase" forObject:@"base-ipadhd" withMass:INFINITY];
        
        body = physicObject.body;
        body.data = self;
        
        sprite = [CCPhysicsSprite spriteWithFile:@"base.png"];
        sprite.chipmunkBody = body;
        
        [chipmunkObjects addObject:body];
        
        for (ChipmunkShape *shape in physicObject.shapes) {
            shape.friction = 0.5;
            shape.elasticity = 0.0;
            shape.collisionType = @"BaseObject";
            
            [chipmunkObjects addObject:shape];
        }
    }
    return self;
}

@end
