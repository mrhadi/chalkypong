//
//  MainScene.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 18/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"
#import "ScoresLayer.h"
#import "GameCenter.h"
#import "RankingSprite.h"

@interface MainScene : CCScene <ScoresLayerDelegate> {
    CCSprite *ball;
    CCSprite *backgroundImage;
    CCSprite *hand;
    
    GameGlobals *globals;
    
    ScoresLayer *scoresLayer;
    
    CCMenu *playMenu;
    CCMenu *helpMenu;
    CCMenu *aboutMenu;
    CCMenu *scoreMenu;
    CCMenu *buyMenu;
    CCMenu *soundMenu;
    
    RankingSprite *ranking;
    
    //CCLabelTTF *freeLabelW;
    //CCLabelTTF *freeLabelB;
    
    BOOL isWaitingRestore;
}

@end
