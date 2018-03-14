//
//  PhysicObjectReader.m
//  Waves
//
//  Created by Boojiyarnezhad Hadi on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhysicObjectReader.h"
#import "GameGlobals.h"

#define PHYSIC_SHAPE_CIRCLE     @"CIRCLE"
#define PHYSIC_SHAPE_POLY       @"POLYGON"

typedef struct {
    CGSize size;
    NSMutableSet *vects;
} ShapeStruct;


@implementation PhysicObjectReader

@synthesize shapes;
@synthesize body;
@synthesize shapeType;
@synthesize groupId;
@synthesize radius;
@synthesize size;

- (id)initWithFile:(NSString *)plistFile forObject:(NSString *)objName withMass:(cpFloat)mass
{
    self = [super init];
    
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:plistFile ofType:@"plist"];
        
        if (path == NULL) {
            NSLog(@"*** PhysicObjectReader: file not found%@", plistFile);
            
            return self;
        }
        
        NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];
        
        if (![plistData count] > 0) {
            NSLog(@"*** PhysicObjectReader: invalid file %@", path);
            
            return self;
        }
        
        NSDictionary *bodies = [plistData objectForKey:@"bodies"];
        NSDictionary *objectData = [bodies objectForKey:objName];
        NSArray *bodyFixtures = [objectData objectForKey:@"fixtures"];
        NSDictionary *fixItems = [bodyFixtures objectAtIndex:0];
        NSString *shape = [fixItems objectForKey:@"fixture_type"];
        
        groupId = [[fixItems objectForKey:@"group"] intValue];
        collisionId = [[fixItems objectForKey:@"collision_type"] intValue];
        
        shapes = [[NSMutableSet alloc] init];
        
        if ([shape isEqualToString:PHYSIC_SHAPE_POLY]) {
            ShapeStruct shapesStruct;
            shapeType = PHYSIC_SHAPE_POLY;
            
            shapesStruct = [self getShapes:[fixItems objectForKey:@"polygons"]];
            
            size = shapesStruct.size;
            
            body = [[ChipmunkBody alloc] initWithMass:mass andMoment:cpMomentForBox(mass, size.width, size.height)];
    
            for (NSMutableArray *arr in shapesStruct.vects) {
                cpVect cordArray[[arr count]];
                
                for (int i = 0; i < [arr count]; i++) {
                    NSValue *value = arr[i];
                    
                    cordArray[i] = [value CGPointValue];
                }
                
                ChipmunkShape *shape = [ChipmunkPolyShape polyWithBody:body count:[arr count] verts:cordArray offset:cpv(0, 0)];
                
                [shapes addObject:shape];
            }
        }
        else if ([shape isEqualToString:PHYSIC_SHAPE_CIRCLE]) {
            shapeType = PHYSIC_SHAPE_CIRCLE;
            
            NSDictionary *circleData = [fixItems objectForKey:@"circle"];
            
            radius = [[circleData objectForKey:@"radius"] intValue];
            radius = XSCALE(radius);
            
            body = [[ChipmunkBody alloc] initWithMass:mass andMoment:cpMomentForCircle(mass, radius, radius, cpv(0, 0))];
            
            ChipmunkShape *circleShape = [ChipmunkCircleShape circleWithBody:body radius:radius offset:cpv(0, 0)];
            
            [shapes addObject:circleShape];
        }
    }
    
    return self;
}

- (void)getPolyShapes:(NSArray *)polygons
{
    NSArray *poly;
    CGPoint point;
    NSString *cordString;
    
    float topLeftX = -1;
    float topLeftY = 1;
    
    float bottomRightX = 1;
    float bottomRightY = -1;
    
    int polyCount;
    
    for (unsigned int i = 0; i < [polygons count]; i++) {
        poly = [polygons objectAtIndex:i];
        polyCount = [poly count];
        
        cpVect cordArray[polyCount];
        
        for (unsigned int j = 0; j < [poly count]; j++) {
            cordString = [poly objectAtIndex:j];
            point = CGPointFromString(cordString);
            
            if (point.x < 0) {
                if (point.x < topLeftX) {
                    topLeftX = point.x;
                }
            }
            else if (point.x > 0) {
                if (point.x > bottomRightX) {
                    bottomRightX = point.x;
                }
            }
            
            if (point.y < 0) {
                if (point.y < topLeftY) {
                    topLeftY = point.y;
                }
            }
            else if (point.y > 0) {
                if (point.y > bottomRightY) {
                    bottomRightY = point.y;
                }
            }
            
            cordArray[j] = CGPointMake(XSCALE(point.x), YSCALE(point.y));
        }
        
        ChipmunkShape *shape = [ChipmunkPolyShape polyWithBody:body count:polyCount verts:cordArray offset:cpv(0, 0)];
        
        [shapes addObject:shape];
    }

    size = CGSizeMake(bottomRightX - topLeftX, bottomRightY - topLeftY);
}

- (ShapeStruct)getShapes:(NSArray *)polygons
{
    NSArray *poly;
    CGPoint point;
    NSString *cordString;
    
    float topLeftX = -1;
    float topLeftY = 1;
    
    float bottomRightX = 1;
    float bottomRightY = -1;
    
    int polyCount;
    
    NSMutableSet *vects = [[NSMutableSet alloc] init];
    ShapeStruct retVal;
    
    for (unsigned int i = 0; i < [polygons count]; i++) {
        poly = [polygons objectAtIndex:i];
        polyCount = [poly count];
        
        NSMutableArray *cordArray = [[NSMutableArray alloc] init];
        
        for (unsigned int j = 0; j < [poly count]; j++) {
            cordString = [poly objectAtIndex:j];
            point = CGPointFromString(cordString);
            
            if (point.x < 0) {
                if (point.x < topLeftX) {
                    topLeftX = point.x;
                }
            }
            else if (point.x > 0) {
                if (point.x > bottomRightX) {
                    bottomRightX = point.x;
                }
            }
            
            if (point.y < 0) {
                if (point.y < topLeftY) {
                    topLeftY = point.y;
                }
            }
            else if (point.y > 0) {
                if (point.y > bottomRightY) {
                    bottomRightY = point.y;
                }
            }
            
            [cordArray addObject:[NSValue valueWithCGPoint: CGPointMake(XSCALE(point.x), YSCALE(point.y))]];
        }
        
        [vects addObject:cordArray];
    }
    
    retVal.size = CGSizeMake(bottomRightX - topLeftX, bottomRightY - topLeftY);;
    retVal.vects = vects;
    
    return retVal;
}

@end
