//
//  AmbiguousObject.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 20/05/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "PhysicObjectReader.h"
#import "SimpleAudioEngine.h"
#import "GameGlobals.h"

@interface AmbiguousObject : NSObject <ChipmunkObject> {
    ChipmunkBody *body;
    CCPhysicsSprite *sprite;
    
    NSMutableSet *chipmunkObjects;
    NSTimer *loopTimer;
    
    ALuint effectHandle;
}

@property (nonatomic, retain) NSMutableSet *chipmunkObjects;
@property (nonatomic, retain) CCPhysicsSprite *sprite;

- (id)initWithName:(NSString *)name;
- (void)fadeOut;
- (void)fadeIn;
- (void)fade;
- (void)shake;
- (void)crack;
- (void)flash;
- (void)cleanUp;
- (void)run;

@end
