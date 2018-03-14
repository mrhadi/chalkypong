//
//  GearObject.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 14/05/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "PhysicObjectReader.h"
#import "SimpleAudioEngine.h"
#import "GameGlobals.h"

@interface GearObject : NSObject <ChipmunkObject> {
    ChipmunkBody *body;
    CCPhysicsSprite *sprite;
    ChipmunkSimpleMotor *motor;
    
    NSMutableSet *chipmunkObjects;
    
    ALuint effectHandle;
    
    NSTimer *loopTimer;
    NSTimer *moveTimer;
    
    GameGlobals *globals;
    
    int hit;
}

@property (nonatomic, retain) NSMutableSet *chipmunkObjects;
@property (nonatomic, retain) CCPhysicsSprite *sprite;
@property (nonatomic, retain) ChipmunkBody *body;
@property (nonatomic, retain) ChipmunkSimpleMotor *motor;
@property int hit;

- (id)initWithName:(NSString *)name;
- (void)run;
- (void)fadeIn;
- (void)fadeOut;
- (void)cleanUp;
- (void)moveMe;

@end
