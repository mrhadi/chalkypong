//
//  MainScene.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 18/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "MainScene.h"
#import "ChalkboardLayer.h"
#import "GameScene.h"
#import "AboutScene.h"
#import "HelpScene.h"
#import "ScoresScene.h"
#import "SimpleAudioEngine.h"
#import "CCShake.h"
#import "ExtraBallSprite.h"

#define AUTO_PLAY   0
#define FADE_LAYER  100

@implementation MainScene

- (id)init
{
    self = [super init];
    if (self) {
        CCLayer *splash = [CCLayer node];
        globals = [GameGlobals sharedGlobal];
        isWaitingRestore = NO;
        
        backgroundImage = [CCSprite spriteWithFile:@"splash.png"];
        backgroundImage.position = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
        
        [splash addChild:backgroundImage];
        [self addChild:splash];
        
        NSString *appVersion = [NSString stringWithFormat:@"Ver. %@ Build %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
        
        CCLabelTTF *versionLabel = [CCLabelTTF labelWithString:appVersion fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(24)];
        versionLabel.position = ccp(SCREEN_WIDTH - versionLabel.boundingBox.size.width / 2 - XSCALE(40), versionLabel.boundingBox.size.height);
        versionLabel.color = ccWHITE;
        [self addChild:versionLabel];
        
        NSLog(@"%@", appVersion);
        
        if (globals.hasPurchase) {
            NSLog(@"hasPurchase ...");
            
            [globals restorePurchases];
        }
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRanking) name:@"RankingIsReady" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableMenus) name:@"EnableMenus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showExtraBallSprite) name:@"RestoreCompleted" object:nil];
    
    [[GameCenter sharedInstance] authenticateLocalUser];
    
    ball = [CCSprite spriteWithSpriteFrameName:@"splash_ball.png"];
    ball.position = cpv(iPadPhone5(138, 58, 58), iPadPhone5(455, 203, 250));
    [self addChild:ball];
}

- (void)onExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeAllChildrenWithCleanup:YES];
}

- (void)onEnterTransitionDidFinish
{
    if (globals.gameMusic) {
        if (globals.firstHomeVisit) {
            [globals musicOn];
        }
        else {
            [globals musicUp];
        }
    }
    
    [self scheduleOnce:@selector(animBall) delay:1.0];
    [self scheduleOnce:@selector(showMenu) delay:0.5];

    if (globals.highScore != 0 || globals.lastScore != 0) {
        [self showRanking];

        [globals postScoreToServer:globals.highScore];
    }
    
    if (AUTO_PLAY) {
        [self scheduleOnce:@selector(doPlay) delay:10];
    }
    
    if (globals.appFreeVersion) {
        if (!globals.hasPurchase) {
            [self scheduleOnce:@selector(showHand) delay:1.5];
        }
    }
    
    [globals saveSettings];
    
    globals.firstHomeVisit = NO;
}

- (void)showHand
{
    hand = [CCSprite spriteWithSpriteFrameName:@"hand.png"];
    hand.position = ccp(iPadPhone5(360, 135, 135), iPadPhone5(250, 115, 160));
    hand.opacity = 0;
    
    [hand runAction:[CCFadeIn actionWithDuration:1.0]];
    
    [self addChild:hand];
    [self animHand];
}

- (void)animHand
{
    id move1 = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(iPadPhone5(40, 10, 10), iPadPhone5(25, 10, 10))];
    id ease1 = [CCEaseIn actionWithAction:move1 rate:3];
    
    id move2 = [CCMoveBy actionWithDuration:0.9 position:CGPointMake(-iPadPhone5(40, 10, 10), -iPadPhone5(25, 10, 10))];
    id ease2 = [CCEaseOut actionWithAction:move2 rate:2];
    
    id shake = [CCCallFuncN actionWithTarget:self selector:@selector(shakeMenuItem)];
    
    CCSequence *sequence = [CCSequence actions:ease1, shake, ease2, nil];
    
    [hand runAction:[CCRepeatForever actionWithAction:sequence]];
}

- (void)shakeMenuItem
{
    [buyMenu runAction:[CCShake actionWithDuration:0.15 amplitude:ccp(XSCALE(10),YSCALE(10)) dampening:NO shakes:6]];
}

- (void)setRanking
{
    [ranking setRanking];
}

- (void)showRanking
{
    ranking = [RankingSprite node];
    ranking.position = ccp(iPadPhone5(160, 75, 80), iPadPhone5(SCREEN_HEIGHT + ranking.myHeight / 2, SCREEN_HEIGHT + ranking.myHeight / 2, SCREEN_HEIGHT + ranking.myHeight / 2));
    [self addChild:ranking];
    
    [ranking startAnim];
    
    id move = [CCMoveBy actionWithDuration:1.5 position:CGPointMake(0, -ranking.myHeight)];
    id ease = [CCEaseIn actionWithAction:move rate:5];
    
    [ranking runAction:ease];
}

- (void)showMenu
{
    CCMenuItem *play = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mmenu_play_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mmenu_play_o.png"] target:self selector:@selector(doPlay)];
    CCMenuItem *scores = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mmenu_scores_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mmenu_scores_o.png"] target:self selector:@selector(doScores)];
    CCMenuItem *help = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mmenu_help_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mmenu_help_o.png"] target:self selector:@selector(doHelp)];
    CCMenuItem *about = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mmenu_about_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mmenu_about_o.png"] target:self selector:@selector(doAbout)];
    CCMenuItem *buy = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mmenu_buy_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mmenu_buy_o.png"] target:self selector:@selector(doBuy)];
    
    CCMenuItem *soundOff = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"sound_off.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"sound_off.png"] target:nil selector:nil];
    CCMenuItem *soundOn = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"sound_on.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"sound_on.png"] target:nil selector:nil];
    CCMenuItem *musicOff = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"music_off.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"music_off.png"] target:self selector:nil];
    CCMenuItem *musicOn = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"music_on.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"music_on.png"] target:self selector:nil];
    CCMenuItem *facebook = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"facebook.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"facebook.png"] target:self selector:@selector(doFacebook)];
    CCMenuItem *twitter = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"twitter.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"twitter.png"] target:self selector:@selector(doTwitter)];
    
    CCMenuItemToggle *soundToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(doSound) items:soundOn, soundOff, nil];
    CCMenuItemToggle *musicToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(doMusic) items:musicOn, musicOff, nil];
    
    if (!globals.gameMusic)
        musicToggle.selectedIndex = 1;
    
    if (!globals.gameSound)
        soundToggle.selectedIndex = 1;
    
    scoreMenu = [CCMenu menuWithItems:scores, nil];
    scoreMenu.position = ccp(iPadPhone5(627, 250, 250), iPadPhone5(756, 385, 425));
    scoreMenu.opacity = 0;
    [self addChild:scoreMenu];
    
    helpMenu = [CCMenu menuWithItems:help, nil];
    helpMenu.position = ccp(iPadPhone5(670, 270, 270), iPadPhone5(523, 220, 260));
    helpMenu.opacity = 0;
    [self addChild:helpMenu];
    
    aboutMenu = [CCMenu menuWithItems:about, nil];
    if (!globals.appFreeVersion)
        aboutMenu.position = ccp(iPadPhone5(530, 205, 205), iPadPhone5(434, 170, 210));
    else
        aboutMenu.position = ccp(iPadPhone5(657, 270, 270), iPadPhone5(355, 134, 175));
    aboutMenu.opacity = 0;
    [self addChild:aboutMenu];
    
    buyMenu = [CCMenu menuWithItems:buy, nil];
    if (!globals.appFreeVersion)
        buyMenu.position = ccp(iPadPhone5(657, 271, 271), iPadPhone5(351, 132, 172));
    else
        buyMenu.position = ccp(iPadPhone5(505, 200, 200), iPadPhone5(380, 170, 210));
    buyMenu.opacity = 0;
    [self addChild:buyMenu];
    
    soundMenu = [CCMenu menuWithItems:soundToggle, musicToggle, facebook, twitter, nil];
    [soundMenu alignItemsHorizontallyWithPadding:YSCALE(50)];
    soundMenu.position = ccp(iPadPhone5(350, 160, 160), iPadPhone5(115, 55, 100));
    [self addChild:soundMenu];
    
    playMenu = [CCMenu menuWithItems:play, nil];
    playMenu.position = ccp(iPadPhone5(487, 202, 202), iPadPhone5(624, 300, 340));
    playMenu.opacity = 0;
    [self addChild:playMenu];
    
    [playMenu runAction:[CCFadeTo actionWithDuration:0.5 opacity:255]];
    [scoreMenu runAction:[CCFadeTo actionWithDuration:0.5 opacity:255]];
    [helpMenu runAction:[CCFadeTo actionWithDuration:0.5 opacity:255]];
    [aboutMenu runAction:[CCFadeTo actionWithDuration:0.5 opacity:255]];
    
    if (globals.appFreeVersion) {
        [buyMenu runAction:[CCFadeTo actionWithDuration:0.5 opacity:255]];
    }
    else {
        buyMenu.enabled = NO;
    }
}

- (void)fadeScreen
{
    [backgroundImage runAction:[CCFadeTo actionWithDuration:2.0 opacity:150]];
}

- (void)showExtraBallSprite
{
    if (!isWaitingRestore) return;
    
    isWaitingRestore = NO;
    
    ExtraBallSprite *extraBall = [ExtraBallSprite node];
    [self addChild:extraBall];
}

- (void)doFacebook
{
    [globals playClick];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/chalkypong"]];
}


- (void)doTwitter
{
    [globals playClick];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/chalkypong"]];
}

- (void)doBuy
{
    [globals playClick];
    [globals postExtra];
    
    [self disableMenus];
    
    CCSprite *blackImage = [CCSprite spriteWithFile:@"blackbg.png"];
    blackImage.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    blackImage.opacity = 150;
    blackImage.tag = FADE_LAYER;
    [self addChild:blackImage];
    
    isWaitingRestore = YES;
    
    [globals restorePurchases];
}

- (void)doPlay
{
    [globals playClick];
    
    [self stopAllActions];
    
    if (globals.gameMusic) {
        [globals musicDown];
    }
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene node]]];
}

- (void)doScores
{
    [globals playClick];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[ScoresScene node]]];
    
    return;
    
    [ball pauseSchedulerAndActions];
    
    scoresLayer = [ScoresLayer node];
    scoresLayer.myDelegate = self;
    [self addChild:scoresLayer];
}

- (void)closeScoresLayer
{
    [scoresLayer removeFromParentAndCleanup:YES];
    scoresLayer = nil;
    
    [ball resumeSchedulerAndActions];
}

- (void)doSound
{
    [globals playClick];
    
    if (globals.gameSound) {
        [globals soundOff];
    }
    else {
        [globals soundOn];
    }
}

- (void)doMusic
{
    [globals playClick];
    
    if (globals.gameMusic) {
        [globals musicOff];
    }
    else {
        [globals musicOn];
    }
}

- (void)doHelp
{
    [globals playClick];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelpScene node]]];
}

- (void)doAbout
{
    [globals playClick];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[AboutScene node]]];
}

- (void)animBall
{
    int y1;
    int y2;
    
    if (IT_IS_iPhone5) {
        y1 = 15;
        y2 = 30;
    }
    else if (IT_IS_iPhone) {
        y1 = 15;
        y2 = 25;
    }
    else {
        y1 = 35;
        y2 = 60;
    }
    
    id move1 = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -y1)];
    id ease1 = [CCEaseIn actionWithAction:move1 rate:3];
    
    id move2 = [CCMoveBy actionWithDuration:0.9 position:CGPointMake(0, y2)];
    id ease2 = [CCEaseOut actionWithAction:move2 rate:2];
    
    id move3 = [CCMoveBy actionWithDuration:0.9 position:CGPointMake(0, -y2)];
    id ease3 = [CCEaseIn actionWithAction:move3 rate:2];
    
    id move4 = [CCMoveBy actionWithDuration:0.8 position:CGPointMake(0, y1)];
    id ease4 = [CCEaseOut actionWithAction:move4 rate:3];
    
    id sound = [CCCallFuncN actionWithTarget:self selector:@selector(ballHit)];
    
    CCSequence *sequence = [CCSequence actions:ease1, sound, ease2, ease3, sound, ease4, nil];
    
    [ball runAction:[CCRepeatForever actionWithAction:sequence]];
}

- (void)ballHit
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"ball.mp3" pitch:0.5f pan:0.0f gain:0.5f];
}

- (void)disableMenus
{
    playMenu.enabled = NO;
    scoreMenu.enabled = NO;
    aboutMenu.enabled = NO;
    helpMenu.enabled = NO;
    buyMenu.enabled = NO;
}

- (void)enableMenus
{
    playMenu.enabled = YES;
    scoreMenu.enabled = YES;
    aboutMenu.enabled = YES;
    helpMenu.enabled = YES;
    buyMenu.enabled = YES;
    
    [self removeChildByTag:FADE_LAYER cleanup:YES];
}


@end
