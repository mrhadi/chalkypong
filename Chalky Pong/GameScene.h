//
//  GameScene.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 18/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "CCScene.h"
#import "ObjectiveChipmunk.h"
#import "GameGlobals.h"

#import "GameLevelObject.h"
#import "RocketObject.h"
#import "ChalkboardLayer.h"

@class PadLayer;
@class OSPadLayer;
@class BallLayer;
@class PanelLayer;
@class GameOverScene;

@interface GameScene : CCScene {
    ChipmunkSpace *gameSpace;
    
    ChalkboardLayer *chalkboardLayer;
    
    PadLayer *myPad;
    OSPadLayer *osPad;
    PanelLayer *panel;
    
    GameGlobals *globals;
    
    CCLayer *gameMenu;
    
    CCSprite *lowerGuide;
    CCSprite *upperGuide;
    
    int padDirection;
    int padLastX;
    int padXStart;
    
    int gameScore;
    int gameLevel;
    int gameLevelLifeTime;
    
    int lastShooter;
    int countBalls;
    int multiBalls;
    
    int lowerGuideLine;
    int upperGuideLine;
    
    float osPadVelYFactor;
    
    GameLevelObject *gameLevelObj;
    
    BOOL gameOver;
    BOOL gamePaused;
    BOOL pendingGiftCollection;
    BOOL pendingRescueCollection;
    BOOL giftCollected;
    BOOL isBallActive;
    BOOL decPadSize;
    BOOL incPadSize;
    BOOL processingPad;
    
    NSMutableArray *shapes;
    NSMutableArray *balls;
    NSMutableArray *giftObjects;
    
    NSArray *levelArray;
}

@end
