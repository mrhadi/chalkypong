//
//  JetSprite.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 27/06/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"

@interface JetSprite : CCSprite {
    GameGlobals *globals;
    
    NSMutableArray *frames;
    
    CCAnimation *anim;
}

- (id)initWithName:(NSString *)name;
- (void)action;
- (void)removeAnim;

@end
