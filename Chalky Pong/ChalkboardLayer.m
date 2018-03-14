//
//  BGLayer.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 18/02/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "ChalkboardLayer.h"

@implementation ChalkboardLayer

- (id)init {
    self = [super init];
    if (self) {
        CCSprite *backgroundImage = [CCSprite spriteWithFile:@"chalkboard.png"];
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        backgroundImage.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [self addChild:backgroundImage];
    }
    
    return self;
}

@end
