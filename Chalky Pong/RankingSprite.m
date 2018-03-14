//
//  RankingSprite.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 1/05/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "RankingSprite.h"

@implementation RankingSprite

@synthesize myHeight;
@synthesize myWidth;

- (id)init {
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        starCounter = 0;
        
        CCSprite *backgroundImage = [CCSprite spriteWithSpriteFrameName:@"score_board.png"];
        [self addChild:backgroundImage];
        
        myWidth = [backgroundImage boundingBox].size.width;
        myHeight = [backgroundImage boundingBox].size.height;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        scoreLabel = [CCLabelTTF labelWithString:[formatter stringFromNumber:[NSNumber numberWithInt:globals.lastScore]] fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(46)];
        scoreLabel.position = ccp(myWidth / 2, iPadPhone5(252, 125, 125));
        scoreLabel.color = ccBLACK;
        [backgroundImage addChild:scoreLabel];
        
        hightScoreLabel = [CCLabelTTF labelWithString:[formatter stringFromNumber:[NSNumber numberWithInt:globals.highScore]] fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(40)];
        hightScoreLabel.position = ccp(myWidth / 2, iPadPhone5(138, 69, 69));
        hightScoreLabel.color = ccWHITE;
        [backgroundImage addChild:hightScoreLabel];
        
        labelRank = [CCLabelTTF labelWithString:@"" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(44)];
        labelRank.position = ccp(myWidth / 2, iPadPhone5(52, 25, 25));
        labelRank.horizontalAlignment = kCCTextAlignmentCenter;
        labelRank.color = ccBLACK;
        labelRank.opacity = 0;
        [backgroundImage addChild:labelRank];
        
        labelLoading = [CCLabelTTF labelWithString:@"Loading" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(28)];
        labelLoading.position = ccp(myWidth / 2, iPadPhone5(70, 35, 35));
        labelLoading.horizontalAlignment = kCCTextAlignmentCenter;
        labelLoading.color = ccBLACK;
        [backgroundImage addChild:labelLoading];
        
        star1 = [CCSprite spriteWithSpriteFrameName:@"star_border.png"];
        star2 = [CCSprite spriteWithSpriteFrameName:@"star_border.png"];
        star3 = [CCSprite spriteWithSpriteFrameName:@"star_border.png"];
        star4 = [CCSprite spriteWithSpriteFrameName:@"star_border.png"];
        star5 = [CCSprite spriteWithSpriteFrameName:@"star_border.png"];
        starF = [CCSprite spriteWithSpriteFrameName:@"star_fill.png"];
        
        int wS = [star1 boundingBox].size.width;
        
        star3.position = ccp(myWidth / 2, iPadPhone5(45, 22, 22));
        star2.position = ccp(myWidth / 2 - wS, iPadPhone5(45, 22, 22));
        star1.position = ccp(myWidth / 2 - wS * 2, iPadPhone5(45, 22, 22));
        star4.position = ccp(myWidth / 2 + wS, iPadPhone5(45, 22, 22));
        star5.position = ccp(myWidth / 2 + wS * 2, iPadPhone5(45, 22, 22));
        
        starF.position = star1.position;
        starF.opacity = 0;
        
        [backgroundImage addChild:star1];
        [backgroundImage addChild:star2];
        [backgroundImage addChild:star3];
        [backgroundImage addChild:star4];
        [backgroundImage addChild:star5];
        [backgroundImage addChild:starF];
        
        starArray = [[NSArray alloc] initWithObjects:star1, star2, star3, star4, star5, nil];
    }
    
    return self;
}

- (void)startAnim
{
    [self scheduleOnce:@selector(flashScore) delay:1.0];
    [self scheduleOnce:@selector(flashHighScore) delay:1.5];
    
    [self flashLoading];
    [self schedule:@selector(fillStar) interval:0.3 repeat:kCCRepeatForever delay:0.0];
}

- (void)fillStar
{
    if (starCounter == 5) {
        starCounter = 0;
    }
    
    CCSprite *star = [starArray objectAtIndex:starCounter];
    
    starF.position = star.position;
    starF.opacity = 255;
    
    starCounter++;
}

- (void)flashLoading
{
    [labelLoading runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.4], [CCFadeIn actionWithDuration:0.3], nil]]];
}

- (void)flashRanking
{
    [labelRank runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.5], [CCFadeIn actionWithDuration:0.4], nil]]];
}

- (void)setRanking
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    if (globals.ranking > 0) {
        [labelRank setString:[formatter stringFromNumber:[NSNumber numberWithInt:globals.ranking]]];
    }
    else {
        [labelRank setString:@"Oops!"];
        [labelRank stopAllActions];
    }
    
    [labelLoading stopAllActions];
    [self unschedule:@selector(fillStar)];
    
    [star1 runAction:[CCFadeOut actionWithDuration:0.3]];
    [star2 runAction:[CCFadeOut actionWithDuration:0.3]];
    [star3 runAction:[CCFadeOut actionWithDuration:0.3]];
    [star4 runAction:[CCFadeOut actionWithDuration:0.3]];
    [star5 runAction:[CCFadeOut actionWithDuration:0.3]];
    [starF runAction:[CCFadeOut actionWithDuration:0.3]];
    
    [labelLoading runAction:[CCFadeOut actionWithDuration:0.3]];

    [labelRank runAction:[CCFadeIn actionWithDuration:1.5]];
}

- (void)flashScore
{
    [scoreLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.5], [CCFadeIn actionWithDuration:0.5], [CCFadeOut actionWithDuration:0.3], [CCFadeIn actionWithDuration:0.3], nil]];
}

- (void)flashHighScore
{
    [hightScoreLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.5], [CCFadeIn actionWithDuration:0.5], [CCFadeOut actionWithDuration:0.3], [CCFadeIn actionWithDuration:0.3], nil]];
}

@end
