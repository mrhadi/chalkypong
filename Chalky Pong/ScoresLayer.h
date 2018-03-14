//
//  ScoresLayer.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 20/04/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"
#import "GameCenter.h"

@protocol ScoresLayerDelegate <NSObject>
@required
- (void)closeScoresLayer;
@end

@interface ScoresLayer : CCLayer <GameCenterDelegate> {
    id <ScoresLayerDelegate> myDelegate;
    
    GameGlobals *globals;
    
    CCSprite *youTable;
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

@property (strong, nonatomic) id myDelegate;

@end
