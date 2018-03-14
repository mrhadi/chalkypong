//
//  PadLayer.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 18/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "GameGlobals.h"

@interface PadLayer : CCLayer <ChipmunkObject> {
    ChipmunkBody *body;
    ChipmunkShape *shape;
    
    CCPhysicsSprite *sprite;
    
    NSMutableSet *chipmunkObjects;
    
    GameGlobals *globals;
    
    float padScale;
}

@property (nonatomic, retain) NSMutableSet *chipmunkObjects;
@property (nonatomic, retain) CCPhysicsSprite *sprite;
@property (readonly) float padScale;

- (void)myScale:(float)scale;
- (void)reset;
- (void)shake;

@end
