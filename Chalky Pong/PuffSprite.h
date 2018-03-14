//
//  PuffSprite.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 21/05/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"

@interface PuffSprite : CCSprite {
    GameGlobals *globals;
    
    NSMutableArray *frames;
    
    CCAnimation *anim;
    
    float animSpeed;
}

- (void)action;
- (id)initWithSpeed:(float)speed;

@end
