//
//  PointSprite.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 22/07/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"

@interface PointsSprite : CCSprite {
    GameGlobals *globals;
    
    CCLabelTTF *pointsSprite;
    CCLabelTTF *shadowSprite;
}

- (id)initWithPoints:(int)points;
- (void)go;

@end
