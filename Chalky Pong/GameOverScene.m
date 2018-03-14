//
//  GameOver.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 14/04/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "GameOverScene.h"
#import "MainScene.h"
#import "GameScene.h"
#import "ScoreObject.h"
#import "RankingSprite.h"

#define RANKING_LAYER   90

@implementation GameOverScene

- (id)init {
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    CCLayer *gameover = [CCLayer node];
    
    int x;
    int y;
    
    if (IT_IS_iPhone5) {
        x = 3;
        y = 25;
    }
    else if (IT_IS_iPhone) {
        x = 3;
        y = 0;
    }
    else {
        x = 0;
        y = 0;
    }
    
    backgroundImage = [CCSprite spriteWithFile:@"gameover.png"];
    backgroundImage.position = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    
    [gameover addChild:backgroundImage z:0 tag:0];
    [self addChild:gameover];
    
    scoreLabel = [CCLabelTTF labelWithString:[formatter stringFromNumber:[NSNumber numberWithInt:globals.lastScore]] fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(46)];
    scoreLabel.position = ccp(XSCALE(766) + x, YSCALE(1754) + y);
    scoreLabel.color = ccBLACK;
    [self addChild:scoreLabel z:1];
    
    hightScoreLabel = [CCLabelTTF labelWithString:[formatter stringFromNumber:[NSNumber numberWithInt:globals.highScore]] fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(46)];
    hightScoreLabel.position = ccp(XSCALE(766) + x, YSCALE(1460) + y);
    hightScoreLabel.color = ccBLACK;
    [self addChild:hightScoreLabel z:1];
    
    ScoreObject *obj = [[ScoreObject alloc] init];
    obj.score = globals.lastScore;
    obj.date = [NSDate date];
    [globals addScoreHistory:obj];
    
    if (globals.lastScore > globals.highScore) {
        globals.highScore = globals.lastScore;
    }
    
    [globals saveSettings];
}

- (void)onEnterTransitionDidFinish
{
    NSLog(@"GameOverScene");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRanking) name:@"RankingIsReady" object:nil];
    
    [globals postScoreToServer:globals.lastScore];
    
    [self showMenu];
    [self showRanking];
    [self scheduleOnce:@selector(flashScore) delay:1.0];
    [self scheduleOnce:@selector(flashHighScore) delay:1.5];
    
    [[GameCenter sharedInstance] retrieveTopScores];
}

-(void)onExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRanking
{
    [ranking setRanking];
}

- (void)showRanking
{
    ranking = [RankingSprite node];
    [self addChild:ranking z:RANKING_LAYER];
    
    if (IT_IS_iPad) {
        ranking.position = ccp(150, SCREEN_HEIGHT - 150);
    }
    else if (IT_IS_iPhone5) {
        ranking.position = ccp(110, SCREEN_HEIGHT - 45);
    }
    else {
        ranking.position = ccp(60, SCREEN_HEIGHT - 40);
    }
    
    [ranking startAnim];
}

- (void)flashScore
{
    [scoreLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.5], [CCFadeIn actionWithDuration:0.5], [CCFadeOut actionWithDuration:0.3], [CCFadeIn actionWithDuration:0.3], nil]];
}

- (void)flashHighScore
{
    [hightScoreLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.5], [CCFadeIn actionWithDuration:0.5], [CCFadeOut actionWithDuration:0.3], [CCFadeIn actionWithDuration:0.3], nil]];
}

- (void)showMenu
{
    int x;
    int y;
    
    if (IT_IS_iPhone5) {
        x = 240;
        y = SCREEN_HEIGHT / 2 - YSCALE(60);
    }
    else if (IT_IS_iPhone) {
        x = 240;
        y = SCREEN_HEIGHT / 2 - YSCALE(60);
    }
    else {
        x = 580;
        y = SCREEN_HEIGHT / 2 - YSCALE(60);
    }
    
    CCMenuItem *replay = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu_replay_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_replay_o.png"] target:self selector:@selector(replaySelected)];
    CCMenuItem *home = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu_home_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_home_o.png"] target:self selector:@selector(homeSelected)];
    CCMenuItem *help = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu_how2play_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_how2play_o.png"] target:self selector:@selector(itemHelp)];
    CCMenuItem *scores = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu_scores_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_scores_o.png"] target:self selector:@selector(doScores)];

    CCMenu *mainMenu = [CCMenu menuWithItems:replay, scores, help, home, nil];
    [mainMenu alignItemsVerticallyWithPadding:YSCALE(10)];
    mainMenu.position = ccp(x, y);
    mainMenu.opacity = 0;
    
    [self addChild:mainMenu];
    
    [mainMenu runAction:[CCFadeTo actionWithDuration:0.2 opacity:255]];
}

- (void)replaySelected
{
    [globals playClick];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene node]]];
}

- (void)homeSelected
{
    [globals playClick];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainScene node]]];
}

- (void)itemHelp
{
    [globals playClick];
}

- (void)doScores
{
    [globals playClick];
    
    scoresLayer = [ScoresLayer node];
    scoresLayer.myDelegate = self;
    [self addChild:scoresLayer z:2];
}

- (void)closeScoresLayer
{
    [scoresLayer removeFromParentAndCleanup:YES];
    scoresLayer = nil;
}

@end
