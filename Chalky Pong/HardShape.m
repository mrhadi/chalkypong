//
//  HardShape.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 13/03/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "HardShape.h"
#import "CCShake.h"

@implementation HardShape

@synthesize chipmunkObjects;
@synthesize sprite;
@synthesize hit;

- (id)initWithName:(NSString *)name;
{
    self = [super init];
    if (self) {
        hit = 0;
        chipmunkObjects = [[NSMutableSet alloc] init];
        
        PhysicObjectReader *physicObject = [[PhysicObjectReader alloc] initWithFile:@"PhysicShapes" forObject:name withMass:INFINITY];
        
		body = physicObject.body;
		body.data = self;
        
        sprite = [CCPhysicsSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png", name]];
        sprite.chipmunkBody = body;
        sprite.opacity = 0;
        
		[chipmunkObjects addObject:body];
        
        for (ChipmunkShape *shape in physicObject.shapes) {
            shape.friction = 0.1;
            shape.elasticity = 0.5;
            shape.collisionType = @"HardShape";
            
            [chipmunkObjects addObject:shape];
        }
    }
    return self;
}

- (void)fadeIn
{
    [sprite runAction:[CCFadeIn actionWithDuration:0.5]];
}

- (void)fadeOut
{
    [sprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.4], [CCCallFuncN actionWithTarget:self selector:@selector(removeMe)], nil]];
}

- (void)removeMe
{
    [sprite removeFromParent];
}

- (void)shake
{
    [sprite runAction:[CCShake actionWithDuration:0.1 amplitude:ccp(XSCALE(10),YSCALE(10)) dampening:NO shakes:6]];
}

- (void)fade
{
    sprite.opacity = 100;
}
@end
