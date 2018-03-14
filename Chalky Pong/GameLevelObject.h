//
//  GameLevelObject.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 12/03/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameLevelObject : NSObject {
    int interval;
    int repeat;
    int delay;
    int runCounter;
    id myData;
    
    SEL levelMethod;
}

@property (readonly) int interval;
@property (readonly) int repeat;
@property (readonly) int delay;
@property (readonly) id myData;
@property (readonly) SEL levelMethod;
@property int runCounter;

- (id)initWithName:(SEL)level withData:(id)data withInterval:(int)i withRepeat:(int)r withDelay:(int)d;

@end
