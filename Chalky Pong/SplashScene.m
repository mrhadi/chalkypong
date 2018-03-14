//
//  SplashScene.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 16/03/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "SplashScene.h"
#import "MainScene.h"
#import "SimpleAudioEngine.h"

@implementation SplashScene

- (id)init {
    self = [super init];
    if (self) {
        CCLayer *logo = [CCLayer node];
        
        CCSprite *backgroundImage = [CCSprite spriteWithFile:@"logo.png"];
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        backgroundImage.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        
        [logo addChild:backgroundImage z:0 tag:0];
        [self addChild:logo];
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];

    CCSpriteBatchNode *shapes = [CCSpriteBatchNode batchNodeWithFile:@"Shapes.pvr.ccz"];
    CCSpriteBatchNode *stuff1 = [CCSpriteBatchNode batchNodeWithFile:@"Stuff1.pvr.ccz"];
    CCSpriteBatchNode *stuff2 = [CCSpriteBatchNode batchNodeWithFile:@"Stuff2.pvr.ccz"];
    CCSpriteBatchNode *animation1 = [CCSpriteBatchNode batchNodeWithFile:@"Animation1.pvr.ccz"];
    CCSpriteBatchNode *animation2 = [CCSpriteBatchNode batchNodeWithFile:@"Animation2.pvr.ccz"];
    
    [self addChild:shapes];
    [self addChild:stuff1];
    [self addChild:stuff2];
    [self addChild:animation1];
    [self addChild:animation2];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Shapes.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Stuff1.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Stuff2.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Animation1.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Animation2.plist"];
    
    NSArray *soundEffects = [NSArray arrayWithObjects:
                             @"ball.mp3",
                             @"ballhit03.mp3",
                             @"beep.mp3",
                             @"bird1.mp3",
                             @"bird2.mp3",
                             @"bird3.mp3",
                             @"bird4.mp3",
                             @"bird5.mp3",
                             @"boxpain.mp3",
                             @"break1.mp3",
                             @"brick.mp3",
                             @"click.mp3",
                             @"drop.mp3",
                             @"fire1.mp3",
                             @"fire2.mp3",
                             @"float.mp3",
                             @"fuse.mp3",
                             @"gameover.mp3",
                             @"getitem1.mp3",
                             @"getitem7.mp3",
                             @"getitem8.mp3",
                             @"getitem9.mp3",
                             @"getitem10.mp3",
                             @"heartbeat.mp3",
                             @"hitmetal.mp3",
                             @"jump1.mp3",
                             @"jump2.mp3",
                             @"jump3.mp3",
                             @"levelup1.mp3",
                             @"motor3.mp3",
                             @"points1.mp3",
                             @"rocket1.mp3",
                             @"sawcut.mp3",
                             @"uh-oh.mp3",
                             nil];
    
    for (NSString *filename in soundEffects) {
        [[SimpleAudioEngine sharedEngine] preloadEffect:filename];
    }
    
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"background2.mp3"];
    
    NSLog(@"Loading resources done.");
    NSLog(@"SplashScene");
    
    [self scheduleOnce:@selector(loadMainScene) delay:2.5];
}


-(void)loadMainScene
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainScene node]]];
}

@end
