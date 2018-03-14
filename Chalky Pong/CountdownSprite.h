//
//  CountdownSprite.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 19/07/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"

@interface CountdownSprite : CCSprite {
    GameGlobals *globals;
    
    NSMutableArray *frames;
    
    CCAnimation *anim;
}

- (void)action;

@end
