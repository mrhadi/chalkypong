//
//  HelpScene.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 13/07/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"

@interface HelpScene : CCScene {
    GameGlobals *globals;
    
    CCMenu *rightMenu;
    CCMenu *leftMenu;
    CCMenu *dotMenu;
    
    CCSprite *helpScreen1;
    CCSprite *helpScreen2;
    CCSprite *helpScreen3;
    CCSprite *helpScreen4;
    CCSprite *currentScreen;
    
    int currentPage;
    
    NSMutableArray *arrScreens;
}

@end
