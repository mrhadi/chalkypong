//
//  GameOver.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 14/04/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"
#import "ScoresLayer.h"
#import "RankingSprite.h"

@interface GameOverScene : CCScene <ScoresLayerDelegate> {
    CCSprite *backgroundImage;
    
    GameGlobals *globals;
    
    CCLabelTTF *scoreLabel;
    CCLabelTTF *hightScoreLabel;
    
    ScoresLayer *scoresLayer;
    
    RankingSprite *ranking;
}

@end
