//
//  OSPadLayer.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 20/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "GameGlobals.h"

@interface OSPadLayer : NSObject <ChipmunkObject> {
    ChipmunkBody *body;
    ChipmunkShape *shape;
    CCPhysicsSprite *sprite;
    
    NSMutableSet *chipmunkObjects;
    
    GameGlobals *globals;
}

@property (nonatomic, retain) NSMutableSet *chipmunkObjects;
@property (nonatomic, retain) CCPhysicsSprite *sprite;

- (void)reset;

@end
