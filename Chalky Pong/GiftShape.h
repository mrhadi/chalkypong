//
//  GiftShape.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 4/05/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "PhysicObjectReader.h"
#import "GameGlobals.h"

@interface GiftShape : NSObject <ChipmunkObject> {
    ChipmunkBody *body;
    CCPhysicsSprite *sprite;
    
    NSMutableSet *chipmunkObjects;
    
    BOOL floatingShape;
    
    int hit;
}

@property (nonatomic, retain) NSMutableSet *chipmunkObjects;
@property (nonatomic, retain) CCPhysicsSprite *sprite;
@property BOOL floatingShape;
@property int hit;

- (id)initWithName:(NSString *)name;
- (void)fadeOut;
- (void)fadeIn;
- (void)shake;
- (void)rotate;

@end
