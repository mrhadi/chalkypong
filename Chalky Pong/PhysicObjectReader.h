//
//  PhysicObjectReader.h
//  Waves
//
//  Created by Boojiyarnezhad Hadi on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ObjectiveChipmunk.h"

@interface PhysicObjectReader : NSObject {
    NSMutableSet *shapes;
    
    int groupId;
    int collisionId;
    
    float radius;
    CGSize size;
    
    ChipmunkBody *body;
    
    NSString *shapeType;
}

@property (readonly) NSMutableSet *shapes;
@property (readonly) ChipmunkBody *body;
@property (readonly) NSString *shapeType;
@property (readonly) float radius;
@property (readonly) CGSize size;
@property (readonly) int groupId;

- (id)initWithFile:(NSString *)plistFile forObject:(NSString *)objName withMass:(cpFloat)mass;

@end
