//
//  GiftShape.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 4/05/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "GiftShape.h"
#import "CCShake.h"

@implementation GiftShape

@synthesize chipmunkObjects;
@synthesize sprite;
@synthesize floatingShape;
@synthesize hit;

- (id)initWithName:(NSString *)name;
{
    self = [super init];
    if (self) {
        floatingShape = NO;
        hit = 0;
        chipmunkObjects = [[NSMutableSet alloc] init];
        
        PhysicObjectReader *physicObject = [[PhysicObjectReader alloc] initWithFile:@"PhysicShapes" forObject:name withMass:10.0];
        
		body = physicObject.body;
		body.data = self;
        
        sprite = [CCPhysicsSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png", name]];
        sprite.chipmunkBody = body;
        sprite.ignoreBodyRotation = YES;
        sprite.opacity = 0;
        sprite.anchorPoint = ccp(0.5, 0.5);
        
		[chipmunkObjects addObject:body];
        
        for (ChipmunkShape *shape in physicObject.shapes) {
            shape.friction = 0.2;
            shape.elasticity = 0.8;
            shape.collisionType = @"GiftShape";
            
            [chipmunkObjects addObject:shape];
        }
    }
    return self;
}

- (void)fadeIn
{
    [sprite runAction:[CCFadeIn actionWithDuration:1.0]];
}

- (void)fadeOut
{
    [sprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.4], [CCCallFuncN actionWithTarget:self selector:@selector(removeMe)], nil]];
}

- (void)removeMe
{
    [sprite stopAllActions];
    [sprite removeFromParent];
}

- (void)shake
{
    [sprite stopAllActions];
    [sprite runAction:[CCShake actionWithDuration:0.1 amplitude:ccp(XSCALE(10),YSCALE(10)) dampening:NO shakes:6]];
}

- (void)rotate
{
    [sprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCRotateBy actionWithDuration:0.5 angle:25], [CCRotateBy actionWithDuration:0.5 angle:-25], nil]]];
}

@end

