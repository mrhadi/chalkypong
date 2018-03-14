//
//  GiftObject.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 19/07/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "GiftObject.h"

@implementation GiftObject

@synthesize spriteName;
@synthesize scoreValue;

- (id)initWithSprite:(NSString *)sprite withScore:(int)score
{
    self = [super init];
    if (self) {
        scoreValue = score;
        spriteName = sprite;
    }
    return self;
}

@end
