//
//  ExtraBallSprite.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 7/08/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"

@interface ExtraBallSprite : CCLayer {
    GameGlobals *globals;
    
    int myWidth;
    int myHeight;
    
    cpVect rowPos;
    
    CCSprite *loadingSprite;
    
    CCLabelTTF *message;
    CCLabelTTF *messageShadow;
    CCLabelTTF *header;
    
    NSMutableArray *menuItems;
    NSMutableArray *products;
    
    BOOL itemRestored;
}

@end
