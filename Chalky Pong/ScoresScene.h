//
//  ScoresScene.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 13/07/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"
#import "GameCenter.h"

@interface ScoresScene : CCScene <GameCenterDelegate> {
    GameGlobals *globals;

    CCSprite *othersTable;
    
    CCMenu *scoresMenu;
    CCMenu *rightMenu;
    CCMenu *leftMenu;
    
    CCMenuItemToggle *youToggle;
    CCMenuItemToggle *othersToggle;
    
    NSMutableArray *rowDate;
    NSMutableArray *rowName;
    NSMutableArray *rowScore;
    
    int currentPage;
    int totalPages;
    int totalRows;
    int selectedTab;
    
    NSNumberFormatter *scoreFormatter;
    NSDateFormatter *dateFormater;
}

@end
