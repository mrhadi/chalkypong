//
//  PanelLayer.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 26/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "cocos2d.h"
#import "GameGlobals.h"

@interface PanelLayer : CCLayer {
    GameGlobals *globals;
    
    CCSprite *levelFlag;
    
    CCLabelTTF *scoreLabel;
    CCLabelTTF *ballLabel;
    CCLabelTTF *levelLabel;
    
    NSNumberFormatter *formatter;
    
    int maxLevels;
    int levelBarWidth;
}

- (void)setScore:(int)score;
- (void)setLevel:(int)level;
- (void)setMaxLevels:(int)levels;
- (void)setBall:(int)count;
- (void)flashScore;
- (void)shakeScore;

@end
