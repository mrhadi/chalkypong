//
//  HelpLayer.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 26/04/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"

@protocol HelpLayerDelegate <NSObject>
@required
- (void)closeHelpLayer;
@end

@interface HelpLayer : CCLayer {
    id <HelpLayerDelegate> myDelegate;
    
    GameGlobals *globals;
    
    CCMenu *rightMenu;
    CCMenu *leftMenu;
    CCMenu *dotMenu;
    
    CCSprite *helpScreen1;
    CCSprite *helpScreen2;
    CCSprite *currentScreen;
    
    int currentPage;
    
    NSMutableArray *arrScreens;
}

@property (strong, nonatomic) id myDelegate;

@end
