//
//  PanelLayer.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 26/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "PanelLayer.h"
#import "CCShake.h"
#import "SimpleAudioEngine.h"
#import "CCShake.h"

@implementation PanelLayer

- (id)init
{
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        
        formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        //CCSprite *bgPanel = [CCSprite spriteWithSpriteFrameName:@"top_panel.png"];
        //bgPanel.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT - (bgPanel.contentSize.height / 2));
        //[self addChild:bgPanel z:0];
        
        CCSprite *levelBar = [CCSprite spriteWithSpriteFrameName:@"level_bar.png"];
        levelBar.position = ccp(XSCALE(500), SCREEN_HEIGHT - YSCALE(73));
        [self addChild:levelBar z:1];
        
        levelBarWidth = levelBar.contentSize.width;
        
        CCSprite *level = [CCSprite spriteWithSpriteFrameName:@"level.png"];
        level.position = ccp(XSCALE(380), SCREEN_HEIGHT - YSCALE(47));
        [self addChild:level z:0];
        
        levelFlag = [CCSprite spriteWithSpriteFrameName:@"level_flag.png"];
        levelFlag.position = ccp(XSCALE(380), SCREEN_HEIGHT - YSCALE(47));
        [self addChild:levelFlag z:2];
        
        levelLabel = [CCLabelTTF labelWithString:@"1" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(40)];
        levelLabel.position = ccp(XSCALE(685), SCREEN_HEIGHT - YSCALE(85));
        levelLabel.color = ccBLACK;
        [self addChild:levelLabel z:2];
        
        scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(44)];
        scoreLabel.position = ccp(SCREEN_WIDTH - XSCALE(285), SCREEN_HEIGHT - YSCALE(88));
        scoreLabel.color = ccBLACK;
        [self addChild:scoreLabel z:2];
        
        ballLabel = [CCLabelTTF labelWithString:@"0" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(44)];
        ballLabel.position = ccp(SCREEN_WIDTH - XSCALE(705), SCREEN_HEIGHT - YSCALE(88));
        ballLabel.color = ccBLACK;
        [self addChild:ballLabel z:2];
        
        //CCMenuItem *btPause = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pause_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pause_o.png"] target:self selector:@selector(pauseGame)];
        CCMenuItem *btPause = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pause.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pause.png"] target:self selector:@selector(pauseGame)];
        CCMenu *pause = [CCMenu menuWithItems:btPause, nil];
        pause.position = ccp(XSCALE(120), SCREEN_HEIGHT - YSCALE(72));
        [self addChild:pause];
    }
    return self;
}

- (void)setScore:(int)score
{
    [scoreLabel setString:[formatter stringFromNumber:[NSNumber numberWithInt:score]]];
}

- (void)setLevel:(int)level
{
    [levelLabel setString:[NSString stringWithFormat:@"%d", level]];
    
    [self shakeLevel];
    
    float moveX = levelBarWidth / maxLevels;
    levelFlag.position = ccp(levelFlag.position.x + moveX, levelFlag.position.y);
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"levelup1.mp3"];
    
    [self beatFlag];
}

- (void)setMaxLevels:(int)levels
{
    maxLevels = levels;
}

- (void)pauseGame
{
    [globals playClick];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PauseGame" object:nil];
}

- (void)flashScore
{
    [scoreLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.3], [CCFadeIn actionWithDuration:0.3], [CCFadeOut actionWithDuration:0.3], [CCFadeIn actionWithDuration:0.3], nil]];
}

- (void)flashBallCount
{
    [ballLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.5], [CCFadeIn actionWithDuration:0.5], [CCFadeOut actionWithDuration:0.5], [CCFadeIn actionWithDuration:0.5], nil]];
}

- (void)shakeScore
{
    [scoreLabel runAction:[CCShake actionWithDuration:0.5 amplitude:ccp(XSCALE(5),YSCALE(5)) dampening:NO shakes:10]];
}

- (void)setBall:(int)count
{
    [ballLabel setString:[NSString stringWithFormat:@"%d", count]];
    
    [self flashBallCount];
}

- (void)beatFlag
{
    [levelFlag runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.3 scale:0.7], [CCScaleTo actionWithDuration:0.3 scale:1.1], [CCScaleTo actionWithDuration:0.3 scale:1.0], nil]];
}

- (void)shakeLevel
{
    [levelLabel runAction:[CCShake actionWithDuration:0.1 amplitude:ccp(XSCALE(10),YSCALE(10)) dampening:NO shakes:6]];
}

@end
