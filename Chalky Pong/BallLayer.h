//
//  BallLayer.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 20/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "GameGlobals.h"

@interface BallLayer : NSObject <ChipmunkObject> {
    ChipmunkBody *body;
    ChipmunkShape *shape;
    CCPhysicsSprite *sprite;
    
    NSMutableSet *chipmunkObjects;
    
    GameGlobals *globals;
    
    cpVect basePos;
    
    BOOL hitBase;
}

@property (nonatomic, retain) NSMutableSet *chipmunkObjects;
@property (nonatomic, retain) CCPhysicsSprite *sprite;
@property (nonatomic, retain) ChipmunkBody *body;
@property cpVect basePos;
@property BOOL hitBase;

- (void)drop:(cpVect)force;
- (void)reset:(CCSprite *)baseOn;

@end
