//
//  BaseObject.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 10/05/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "PhysicObjectReader.h"

@interface BaseObject : NSObject <ChipmunkObject> {
    ChipmunkBody *body;
    CCPhysicsSprite *sprite;
    
    NSMutableSet *chipmunkObjects;
}

@property (nonatomic, retain) NSMutableSet *chipmunkObjects;
@property (nonatomic, retain) CCPhysicsSprite *sprite;

@end
