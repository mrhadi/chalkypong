//
//  AboutScene.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 20/04/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "AboutScene.h"
#import "MainScene.h"
#import "SimpleAudioEngine.h"

@implementation AboutScene

- (id)init {
    self = [super init];
    if (self) {
        CCLayer *about = [CCLayer node];
        globals = [GameGlobals sharedGlobal];
        
        backgroundImage = [CCSprite spriteWithFile:@"about.png"];
        backgroundImage.position = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
        
        [about addChild:backgroundImage z:0 tag:0];
        [self addChild:about];
        
        CCMenuItem *btBack = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"close_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"close_o.png"] target:self selector:@selector(doBack)];
        CCMenu *back = [CCMenu menuWithItems:btBack, nil];
        back.position = ccp(XSCALE(1380), SCREEN_HEIGHT - YSCALE(150));
        [self addChild:back];
        
        NSString *appVersion = [NSString stringWithFormat:@"Ver. %@ Build %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
        
        CCLabelTTF *versionLabel = [CCLabelTTF labelWithString:appVersion fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(24)];
        versionLabel.position = ccp(SCREEN_WIDTH - versionLabel.boundingBox.size.width / 2 - XSCALE(40), versionLabel.boundingBox.size.height);
        versionLabel.color = ccWHITE;
        [self addChild:versionLabel];
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    CGPoint ballPos;
    
    if (IT_IS_iPhone5) {
        ballPos = CGPointMake(58, 275);
    }
    else if (IT_IS_iPhone) {
        ballPos = CGPointMake(58, 233);
    }
    else {
        ballPos = CGPointMake(138, 455);
    }
    
    ball = [CCSprite spriteWithSpriteFrameName:@"splash_ball.png"];
    ball.position = ballPos;
    [self addChild:ball];
}

- (void)onEnterTransitionDidFinish
{
    NSLog(@"AboutScene");
    
    int x;
    int y;
    int scale;
    
    if (IT_IS_iPhone5) {
        x = XSCALE(630);
        y = SCREEN_HEIGHT - YSCALE(1870);
        scale = XSCALE(60);
    }
    else if (IT_IS_iPhone) {
        x = XSCALE(630);
        y = SCREEN_HEIGHT - YSCALE(1680);
        scale = XSCALE(60);
    }
    else {
        x = XSCALE(610);
        y = SCREEN_HEIGHT - YSCALE(1810);
        scale = XSCALE(40);
    }
    
    CCMenuItem *facebook = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"facebook_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"facebook_o.png"] target:self selector:@selector(doFacebook)];
    CCMenuItem *twitter = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"twitter_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"twitter_o.png"] target:self selector:@selector(doTwitter)];
    CCMenuItem *email = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"email_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"email_o.png"] target:self selector:@selector(doEmail)];
    
    CCMenu *socialMenu = [CCMenu menuWithItems:facebook, twitter, email, nil];
    [socialMenu alignItemsHorizontallyWithPadding:scale];
    socialMenu.position = ccp(x, y);
    socialMenu.opacity = 0;
    [self addChild:socialMenu];
    
    [socialMenu runAction:[CCFadeTo actionWithDuration:0.5 opacity:255]];
    
    [self scheduleOnce:@selector(animBall) delay:0.5];
}

- (void)onExit
{
    [super onExit];
    
    [self removeAllChildrenWithCleanup:YES];
}

- (void)doBack
{
    [globals playClick];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainScene node]]];
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

- (void)doEmail
{
    [globals playClick];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.chalkypong.com"]];
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

@end
