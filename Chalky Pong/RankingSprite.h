//
//  RankingSprite.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 1/05/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"

@interface RankingSprite : CCSprite {
    GameGlobals *globals;
    
    CCLabelTTF *labelRank;
    CCLabelTTF *labelLoading;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *hightScoreLabel;
    
    CCSprite *star1;
    CCSprite *star2;
    CCSprite *star3;
    CCSprite *star4;
    CCSprite *star5;
    CCSprite *starF;
    
    int starCounter;
    int myWidth;
    int myHeight;
    
    NSArray *starArray;
}

@property (readonly) int myWidth;
@property (readonly) int myHeight;

- (void)startAnim;
- (void)setRanking;

@end
