//
//  ScoreObject.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 21/04/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "ScoreObject.h"

@implementation ScoreObject

@synthesize score;
@synthesize date;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithInt:self.score] forKey:@"Score"];
    [aCoder encodeObject:self.date forKey:@"Date"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.score = [[aDecoder decodeObjectForKey:@"Score"] intValue];
        self.date = [aDecoder decodeObjectForKey:@"Date"];
    }
    return self;
}

@end
