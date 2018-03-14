//
//  RocketObject.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 18/06/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "PhysicObjectReader.h"
#import "SimpleAudioEngine.h"
#import "GameGlobals.h"
#import "JetSprite.h"

@protocol RocketObjectDelegate <NSObject>
@required
- (void)rocketCleanup:(id)chipmunkObject;
@end

@interface RocketObject : NSObject <ChipmunkObject> {
    id <RocketObjectDelegate> myDelegate;
    
    ChipmunkBody *body;
    CCPhysicsSprite *sprite;
    
    GameGlobals *globals;
    
    NSMutableSet *chipmunkObjects;
    
    NSTimer *fireTimer;
    NSTimer *fadeTimer;
    
    ALuint effectHandle;
    
    int hit;
    int runCount;
    int runCounter;
    
    BOOL duringCleanup;
    
    JetSprite *jetAnim;
}

@property (strong, nonatomic) id myDelegate;
@property (nonatomic, retain) NSMutableSet *chipmunkObjects;
@property (nonatomic, retain) CCPhysicsSprite *sprite;
@property int hit;
@property int runCount;

- (id)initWithName:(NSString *)name;
- (void)fadeOut;
- (void)fadeIn;
- (void)shake;
- (void)run;
- (void)cleanUp;

@end
