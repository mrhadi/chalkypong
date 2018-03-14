//
//  GameLevelObject.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 12/03/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "GameLevelObject.h"

@implementation GameLevelObject

@synthesize levelMethod;
@synthesize interval;
@synthesize delay;
@synthesize repeat;
@synthesize myData;
@synthesize runCounter;

- (id)initWithName:(SEL)level withData:(id)data withInterval:(int)i withRepeat:(int)r withDelay:(int)d;
{
    self = [super init];
    
    if (self) {
        levelMethod = level;
        myData = data;
        interval = i;
        repeat = r;
        delay = d;
        runCounter = 0;
    }
    
    return self;
}

@end
