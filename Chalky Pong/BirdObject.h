//
//  BirdObject.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 15/06/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "PhysicObjectReader.h"
#import "SimpleAudioEngine.h"
#import "GameGlobals.h"
#import "BirdSprite.h"

@interface BirdObject : NSObject <ChipmunkObject> {
    ChipmunkBody *body;
    CCPhysicsSprite *sprite;
    
    GameGlobals *globals;
    
    NSMutableSet *chipmunkObjects;
    
    ALuint effectHandle;
    
    NSTimer *soundTimer;
    
    int hit;
    
    BirdSprite *birdAnim;
}

@property (nonatomic, retain) NSMutableSet *chipmunkObjects;
@property (nonatomic, retain) CCPhysicsSprite *sprite;
@property int hit;
@property int runCount;

- (id)initWithName:(NSString *)name;
- (void)fadeOut;
- (void)fadeIn;
- (void)cleanUp;
- (void)goRight;
- (void)goLeft;
- (void)shake;

@end
