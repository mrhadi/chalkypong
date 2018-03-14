//
//  HardShape.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 13/03/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "PhysicObjectReader.h"
#import "GameGlobals.h"

@interface HardShape : NSObject <ChipmunkObject> {
    ChipmunkBody *body;
    CCPhysicsSprite *sprite;
    
    NSMutableSet *chipmunkObjects;
    
    int hit;
}

@property (nonatomic, retain) NSMutableSet *chipmunkObjects;
@property (nonatomic, retain) CCPhysicsSprite *sprite;
@property int hit;

- (id)initWithName:(NSString *)name;
- (void)fadeOut;
- (void)fadeIn;
- (void)fade;
- (void)shake;

@end
