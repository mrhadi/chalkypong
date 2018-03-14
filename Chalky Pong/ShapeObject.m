//
//  Shape.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 1/03/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "ShapeObject.h"
#import "CCShake.h"
#import "SimpleAudioEngine.h"

@implementation ShapeObject

@synthesize chipmunkObjects;
@synthesize sprite;
@synthesize floatingShape;
@synthesize hit;
@synthesize shapeType;
@synthesize isGift;
@synthesize hasJoint;

- (id)initWithName:(NSString *)name shapeType:(int)type
{
    self = [super init];
    if (self) {
        switch (type) {
            case SHAPE_TYPE_SIMPLE:
                mass = 10;
                break;
            
            case SHAPE_TYPE_GIFT_1:
                mass = 10;
                break;
                
            case SHAPE_TYPE_HARD:
                mass = INFINITY;
                break;
            
            case SHAPE_TYPE_TROUBLE_1:
                mass = 10;
                break;
            
            case SHAPE_TYPE_STAND:
                mass = 5;
                break;
            
            case SHAPE_TYPE_ROCKET:
                mass = 20;
                break;
            
            case SHAPE_TYPE_SHOOTER:
                mass = 30;
                break;
                
            case SHAPE_TYPE_RESCUE:
                mass = INFINITY;
                break;
                
            default:
                break;
        }
        
        floatingShape = NO;
        isGift = NO;
        hasJoint = NO;
        shapeType = type;
        hit = 0;
        chipmunkObjects = [[NSMutableSet alloc] init];
        
        if (type == SHAPE_TYPE_HARD) {
            cracked = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@.png", [name stringByReplacingOccurrencesOfString:@"S" withString:@"SC"]]];
        }
        else {
            cracked = [CCSprite node];
        }
        
        PhysicObjectReader *physicObject = [[PhysicObjectReader alloc] initWithFile:@"PhysicShapes" forObject:name withMass:mass];

		body = physicObject.body;
		body.data = self;
        
        if (type == SHAPE_TYPE_ROCKET) {
            body.vel =ccp(0, -YSCALE(800));
            body.force = ccp(0, -YSCALE(1000));
        }
        else if (type == SHAPE_TYPE_SHOOTER) {
            body.vel =ccp(0, -YSCALE(2500));
            body.force = ccp(0, YSCALE(5000));
        }
        
        sprite = [CCPhysicsSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png", name]];
        sprite.chipmunkBody = body;
        sprite.opacity = 0;
        
		[chipmunkObjects addObject:body];
        
        for (ChipmunkShape *shape in physicObject.shapes) {
            switch (type) {
                case SHAPE_TYPE_SIMPLE:
                    shape.friction = 0.2;
                    shape.elasticity = 0.8;
                    shape.collisionType = @"ShapeObject";
                    break;
                
                case SHAPE_TYPE_GIFT_1:
                    shape.friction = 0.2;
                    shape.elasticity = 0.8;
                    shape.collisionType = @"ShapeObject";
                    break;
                    
                case SHAPE_TYPE_HARD:
                    shape.friction = 0.1;
                    shape.elasticity = 0.7;
                    shape.collisionType = @"ShapeObject";
                    break;
                
                case SHAPE_TYPE_TROUBLE_1:
                    body.torque = 500;
                    shape.friction = 0.1;
                    shape.elasticity = 1.0;
                    shape.collisionType = @"TroubleObject";
                    break;
                    
                case SHAPE_TYPE_STAND:
                    shape.friction = 0.2                                                                                                                                                       ;
                    shape.elasticity = 0.9;
                    shape.collisionType = @"ShapeObject";
                    break;
                
                case SHAPE_TYPE_ROCKET:
                    shape.friction = 0.2;
                    shape.elasticity = 0.8;
                    shape.collisionType = @"ShapeObject";
                    break;
                
                case SHAPE_TYPE_SHOOTER:
                    shape.friction = 0.2;
                    shape.elasticity = 0.5;
                    shape.collisionType = @"ShapeObject";
                    break;
                    
                case SHAPE_TYPE_RESCUE:
                    shape.friction = 0.2;
                    shape.elasticity = 0.8;
                    shape.collisionType = @"ShapeObject";
                    break;
                    
                default:
                    break;
            }
            
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
    [self shake];
    [sprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.4], [CCCallFuncN actionWithTarget:self selector:@selector(removeMe)], nil]];
}

- (void)removeMe
{
    [sprite stopAllActions];
    [sprite removeFromParentAndCleanup:YES];
}

- (void)shake
{
    [sprite runAction:[CCShake actionWithDuration:0.1 amplitude:ccp(XSCALE(10),YSCALE(10)) dampening:NO shakes:6]];
}

- (void)fade
{
    sprite.opacity = 100;
}

- (void)crack
{
    [sprite setDisplayFrame:cracked];
}

- (void)rotate
{
    [sprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCRotateBy actionWithDuration:0.5 angle:25], [CCRotateBy actionWithDuration:0.5 angle:-25], nil]]];
}

- (void)cleanUp
{
}

- (void)beat
{
    [sprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.5 scale:0.7], [CCCallFuncN actionWithTarget:self selector:@selector(playSound)], [CCScaleTo actionWithDuration:0.5 scale:1.1], nil]]];
}

- (void)playSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"heartbeat.mp3" pitch:1.5 pan:0.0 gain:2.0];
}

@end
