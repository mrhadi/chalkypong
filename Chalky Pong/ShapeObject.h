//
//  Shape.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 1/03/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "PhysicObjectReader.h"
#import "GameGlobals.h"

#define SHAPE_TYPE_SIMPLE       1
#define SHAPE_TYPE_HARD         2
#define SHAPE_TYPE_GIFT_1       3
#define SHAPE_TYPE_TROUBLE_1    4
#define SHAPE_TYPE_STAND        5
#define SHAPE_TYPE_ROCKET       6
#define SHAPE_TYPE_RESCUE       7
#define SHAPE_TYPE_SHOOTER      8


@interface ShapeObject : NSObject <ChipmunkObject> {
    ChipmunkBody *body;
    CCPhysicsSprite *sprite;
    CCSpriteFrame *cracked;
    
    NSMutableSet *chipmunkObjects;
    
    BOOL floatingShape;
    BOOL isGift;
    BOOL hasJoint;
    
    int hit;
    int shapeType;
    
    float mass;
}

@property (nonatomic, retain) NSMutableSet *chipmunkObjects;
@property (nonatomic, retain) CCPhysicsSprite *sprite;
@property BOOL floatingShape;
@property BOOL isGift;
@property BOOL hasJoint;
@property int hit;
@property int shapeType;

- (id)initWithName:(NSString *)name shapeType:(int)type;
- (void)fadeOut;
- (void)fadeIn;
- (void)fade;
- (void)shake;
- (void)crack;
- (void)rotate;
- (void)cleanUp;
- (void)beat;

@end
