//
//  GameScene.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 18/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "GameScene.h"
#import "SimpleAudioEngine.h"
#import "MainScene.h"
#import "GameCenter.h"

#import "PuffSprite.h"
#import "PointsSprite.h"
#import "CountdownSprite.h"

#import "PadLayer.h"
#import "OSPadLayer.h"
#import "BallLayer.h"
#import "PanelLayer.h"

#import "AmbiguousObject.h"
#import "BaseObject.h"
#import "GearObject.h"
#import "ScoreObject.h"
#import "ShapeObject.h"
#import "BirdObject.h"
#import "GiftObject.h"

#ifdef CAM_VERSION
#import <Kamcord/Kamcord.h>
#endif

#define SHOW_PHYISIC    0
#define GAMEOVER_ACTIVE 1
#define SHOW_GUIDES     0

#define THICKNESS       100.0f
#define ELASTICITY      0.5f
#define FRICTION        0.2f
#define GRAVITY_X       0.0f
#define GRAVITY_Y       0.0f

#define HIDDEN_LAYER    0
#define BG_LAYER        1
#define GUIDE_LAYER     2
#define BASE_LAYER      2
#define OS_PAD_LAYER    3
#define BALL_LAYER      3
#define SHAPE_LAYER     3
#define BIRD_LAYER      4
#define ROCKET_LAYER    4
#define PUFF_LAYER      5
#define POINTS_LAYER    9
#define MY_PAD_LAYER    10
#define PANEL_LAYER     10
#define COUNTDOWN_LAYER 20
#define MENU_LAYER      30

#define OSPAD_SHOT      1
#define MYPAD_SHOT      2

#define MAX_SHAPES      28

#define UNLIMIT_LEVEL   1000

#define PAD_SCALE_MAX   1.0
#define PAD_SCALE_MIN   0.4
#define PAD_SCALE_AMT   0.15

#define GIFT_SCORE_1    5000
#define GIFT_SCORE_2    12000

#define SCORE_BALL_GEAR     300
#define SCORE_BALL_BIRD     500
#define SCORE_BALL_SHAPE    100
#define SCORE_BALL_ROCKET   500
#define SCORE_BALL_STAND    200
#define SCORE_PAD_SHAPE     500
#define SCORE_GAME_LIFE     10

#ifdef FREE_VERSION
    #define MAX_BALLS 1
#else
    #define MAX_BALLS 3
#endif

@implementation GameScene

- (id)init
{
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        gameScore = 0;
        gameOver = NO;
        gameLevel = 0;
        gameLevelLifeTime = 0;
        osPadVelYFactor = 1;
        lastShooter = 0;
        countBalls = MAX_BALLS + globals.extraBalls;
        multiBalls = 1;
        pendingGiftCollection = NO;
        pendingRescueCollection = NO;
        isBallActive = NO;
        decPadSize = NO;
        incPadSize = NO;
        processingPad = NO;
        
        GiftObject *gift1 = [[GiftObject alloc] initWithSprite:@"G01" withScore:GIFT_SCORE_1];
        GiftObject *gift2 = [[GiftObject alloc] initWithSprite:@"G02" withScore:GIFT_SCORE_2];
        
        shapes = [[NSMutableArray alloc] init];
        balls = [[NSMutableArray alloc] init];
        giftObjects = [[NSMutableArray alloc] initWithObjects:gift1, gift2, nil];
        
        [self buildSpace];
        
        chalkboardLayer = [ChalkboardLayer node];
        [self addChild:chalkboardLayer z:BG_LAYER];
        
        //BaseObject *baseObj = [[BaseObject alloc] init];
        //baseObj.sprite.position = ccp(SCREEN_WIDTH / 2, YSCALE(60));
        //[gameSpace add:baseObj];
        //[self addChild:baseObj.sprite z:BASE_LAYER];
        
        panel = [PanelLayer node];
        [panel setBall:countBalls];
        [self addChild:panel z:PANEL_LAYER];
        
        myPad = [PadLayer node];
        myPad.sprite.position = ccp(SCREEN_WIDTH / 2, globals.myPadHeight);
        [gameSpace add:myPad];
        [self addChild:myPad z:MY_PAD_LAYER];
        
        osPad = [[OSPadLayer alloc] init];
        osPad.sprite.position = ccp(SCREEN_WIDTH / 2, globals.osPadHeight);
        [gameSpace add:osPad];
        [self addChild:osPad.sprite z:OS_PAD_LAYER];
        
        [self addBall];
        
        if (IT_IS_iPad) {
            lowerGuideLine = globals.myPadHeight + 50;
            upperGuideLine = globals.osPadHeight - 50;
        }
        else if (IT_IS_iPhone) {
            lowerGuideLine = globals.myPadHeight + 25;
            upperGuideLine = globals.osPadHeight - 25;
        }
        else {
            lowerGuideLine = globals.myPadHeight + 30;
            upperGuideLine = globals.osPadHeight - 30;
        }
        
        [gameSpace addCollisionHandler:self typeA:@"Ball" typeB:@"Ball" begin:@selector(ballHitBall:space:) preSolve:nil postSolve:nil separate:nil];
        [gameSpace addCollisionHandler:self typeA:@"Ball" typeB:@"MyPad" begin:@selector(ballHitPad:space:) preSolve:nil postSolve:nil separate:nil];
        [gameSpace addCollisionHandler:self typeA:@"Ball" typeB:@"OSPad" begin:@selector(ballHitOSPad:space:) preSolve:nil postSolve:nil separate:nil];
        [gameSpace addCollisionHandler:self typeA:@"Ball" typeB:@"Border" begin:nil preSolve:nil postSolve:nil separate:@selector(ballHitBorder:space:)];
        [gameSpace addCollisionHandler:self typeA:@"Ball" typeB:@"ShapeObject" begin:nil preSolve:nil postSolve:nil separate:@selector(ballHitShapeObject:space:)];
        [gameSpace addCollisionHandler:self typeA:@"Ball" typeB:@"BaseObject" begin:@selector(ballHitBase:space:) preSolve:nil postSolve:nil separate:nil];
        [gameSpace addCollisionHandler:self typeA:@"Ball" typeB:@"GearObject" begin:@selector(ballHitGear:space:) preSolve:nil postSolve:nil separate:nil];
        [gameSpace addCollisionHandler:self typeA:@"Ball" typeB:@"AmbiguousObject" begin:@selector(showPuff:) preSolve:nil postSolve:nil separate:@selector(ballHitGearAmbiguous:space:)];
        [gameSpace addCollisionHandler:self typeA:@"Ball" typeB:@"TroubleObject" begin:nil preSolve:nil postSolve:nil separate:@selector(ballHitTroubleObject:space:)];
        [gameSpace addCollisionHandler:self typeA:@"Ball" typeB:@"BirdObject" begin:@selector(showPuff:) preSolve:nil postSolve:nil separate:@selector(ballHitBird:space:)];
        
        [gameSpace addCollisionHandler:self typeA:@"MyPad" typeB:@"ShapeObject" begin:@selector(myPadHitShape:space:) preSolve:nil postSolve:nil separate:nil];
        [gameSpace addCollisionHandler:self typeA:@"MyPad" typeB:@"GearObject" begin:@selector(myPadHitGear:space:) preSolve:nil postSolve:nil separate:nil];
        [gameSpace addCollisionHandler:self typeA:@"MyPad" typeB:@"AmbiguousObject" begin:@selector(ballHitGearAmbiguous:space:) preSolve:nil postSolve:nil separate:nil];
        [gameSpace addCollisionHandler:self typeA:@"MyPad" typeB:@"BirdObject" begin:@selector(showPuff:) preSolve:nil postSolve:nil separate:@selector(ballHitBird:space:)];
        
        [gameSpace addCollisionHandler:self typeA:@"OSPad" typeB:@"ShapeObject" begin:nil preSolve:nil postSolve:nil separate:@selector(osPadHitShape:space:)];
        
        [gameSpace addCollisionHandler:self typeA:@"ShapeObject" typeB:@"ShapeObject" begin:@selector(showPuff:) preSolve:nil postSolve:nil separate:@selector(shapeHitShape:space:)];
        [gameSpace addCollisionHandler:self typeA:@"ShapeObject" typeB:@"BaseObject" begin:@selector(shapeHitBase:space:) preSolve:nil postSolve:nil separate:nil];
        [gameSpace addCollisionHandler:self typeA:@"ShapeObject" typeB:@"GearObject" begin:@selector(shapeHitGear:space:) preSolve:nil postSolve:nil separate:nil];
        [gameSpace addCollisionHandler:self typeA:@"ShapeObject" typeB:@"TroubleObject" begin:@selector(shapeHitTroubleObject:space:) preSolve:nil postSolve:nil separate:nil];
        
        [gameSpace addCollisionHandler:self typeA:@"GearObject" typeB:@"GearObject" begin:@selector(gearHitGear:space:) preSolve:nil postSolve:nil separate:nil];
        
        [gameSpace addCollisionHandler:self typeA:@"BirdObject" typeB:@"ShapeObject" begin:@selector(showPuff:) preSolve:nil postSolve:nil separate:@selector(birdHitShape:space:)];
    
        [gameSpace addCollisionHandler:self typeA:@"RocketObject" typeB:@"ShapeObject" begin:nil preSolve:nil postSolve:nil separate:@selector(rocketHitShape:space:)];
        
        padDirection = 0;
        padXStart = (int)myPad.sprite.position.x;
        padLastX = (int)myPad.sprite.position.x;
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:@"DidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userPaused) name:@"PauseGame" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rocketFire:) name:@"FireRocket" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rocketCleanup) name:@"CleanupRocket" object:nil];
}

- (void)onEnterTransitionDidFinish
{
    [self scheduleUpdate];
    [self buildLevels];
    [self BuildGameMenu];
    [self initTimers];
    
    if (SHOW_GUIDES) {
        CCSprite *guildLine1 = [CCSprite spriteWithFile:@"guildline.png"];
        guildLine1.position = ccp(SCREEN_WIDTH / 2, lowerGuideLine);
        guildLine1.opacity = 40;
        [self addChild:guildLine1 z:GUIDE_LAYER];
        
        CCSprite *guildLine2 = [CCSprite spriteWithFile:@"guildline.png"];
        guildLine2.position = ccp(SCREEN_WIDTH / 2, upperGuideLine);
        guildLine2.opacity = 40;
        [self addChild:guildLine2 z:GUIDE_LAYER];
    }
    
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:myPad priority:0 swallowsTouches:NO];
    
    #ifdef CAM_VERSION
    [Kamcord startRecording];
    #endif
}

- (void)onExit
{
    [self removeAllChildrenWithCleanup:YES];
}

- (void)didEnterBackground
{
    [self userPaused];
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)BuildGameMenu
{
    gameMenu = [CCLayer node];
    
    CCSprite *menuBG = [CCSprite spriteWithFile:@"menubg.png"];
    menuBG.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    [gameMenu addChild:menuBG];
    
    CCMenuItem *resume = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu_resume_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_resume_o.png"] target:self selector:@selector(resumeSelected)];
    CCMenuItem *replay = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu_replay_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_replay_o.png"] target:self selector:@selector(replaySelected)];
    CCMenuItem *home = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu_home_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_home_o.png"] target:self selector:@selector(homeSelected)];
    
    CCMenuItem *soundOff = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu_sound_off.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_sound_off.png"] target:nil selector:nil];
    CCMenuItem *soundOn = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu_sound_on.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_sound_on.png"] target:nil selector:nil];
    
    CCMenuItem *musicOff = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu_music_off.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_music_off.png"] target:self selector:nil];
    CCMenuItem *musicOn = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu_music_on.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_music_on.png"] target:self selector:nil];
    
    CCMenuItemToggle *soundToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(soundSelected) items:soundOn, soundOff, nil];
    CCMenuItemToggle *musicToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(musicSelected) items:musicOn, musicOff, nil];
    
    if (!globals.gameMusic)
        musicToggle.selectedIndex = 1;
    
    if (!globals.gameSound)
        soundToggle.selectedIndex = 1;
    
    CCMenu *mainMenu = [CCMenu menuWithItems:resume, replay, soundToggle, musicToggle, home, nil];
    [mainMenu alignItemsVerticallyWithPadding:YSCALE(30)];
    mainMenu.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    
    [gameMenu addChild:mainMenu];
    
    [self addChild:gameMenu z:HIDDEN_LAYER];
}

- (void)showGameMenu
{
    [self reorderChild:gameMenu z:MENU_LAYER];
}

- (void)hideGameMenu
{
    [self reorderChild:gameMenu z:HIDDEN_LAYER];
}

- (void)resumeSelected
{
    [globals playClick];
    
    [self hideGameMenu];
    [self resumeSchedulerAndActions];
    [self scheduleOnce:@selector(resumeGame) delay:0.5];
}

- (void)replaySelected
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameScene node]]];
}

- (void)homeSelected
{
    [globals playClick];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainScene node]]];
}

- (void)soundSelected
{
    [globals playClick];
    
    if (globals.gameSound) {
        [globals soundOff];
    }
    else {
        [globals soundOn];
    }
}

- (void)musicSelected
{
    [globals playClick];
    
    if (globals.gameMusic) {
        [globals musicOff];
    }
    else {
        [globals musicDown];
        [globals musicOn];
    }
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)initTimers
{
    [self resetScore];
    
    CountdownSprite *countdown = [CountdownSprite node];
    countdown.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    [self addChild:countdown z:COUNTDOWN_LAYER];
    [countdown action];
    
    [self scheduleOnce:@selector(moveOSPad) delay:2.0];
    [self schedule:@selector(calculateScore) interval:1 repeat:kCCRepeatForever delay:3.0];
    [self schedule:@selector(rescueManager) interval:5.0 repeat:kCCRepeatForever delay:5.0];
}

- (void)stopTimers
{
    [self unschedule:@selector(calculateScore)];
    [self unschedule:@selector(moveOSPad)];
    [self unschedule:@selector(rescueManager)];
}

- (void)buildLevels
{
    GameLevelObject *level1  = [[GameLevelObject alloc] initWithName:@selector(level_ShapeSimple)           withData:(id)1      withInterval:2 withRepeat:4  withDelay:10];
    GameLevelObject *level2  = [[GameLevelObject alloc] initWithName:@selector(level_ShapeSimple)           withData:(id)2      withInterval:2 withRepeat:4  withDelay:3];
    GameLevelObject *level3  = [[GameLevelObject alloc] initWithName:@selector(level_ShapeSimple)           withData:(id)3      withInterval:2 withRepeat:4  withDelay:3];
    GameLevelObject *level4  = [[GameLevelObject alloc] initWithName:@selector(level_ShapeSimple_Float)     withData:(id)4      withInterval:2 withRepeat:6  withDelay:3];
    GameLevelObject *level5  = [[GameLevelObject alloc] initWithName:@selector(level_Rocket)                withData:(id)2      withInterval:1 withRepeat:1  withDelay:5];
    GameLevelObject *level6  = [[GameLevelObject alloc] initWithName:@selector(level_ShapeHard)             withData:(id)4      withInterval:2 withRepeat:8  withDelay:5];
    GameLevelObject *level7  = [[GameLevelObject alloc] initWithName:@selector(level_ShapeSimple_Float)     withData:(id)5      withInterval:2 withRepeat:8  withDelay:5];
    GameLevelObject *level8  = [[GameLevelObject alloc] initWithName:@selector(level_ShapeTrouble_Float)    withData:(id)6      withInterval:2 withRepeat:8  withDelay:5];
    GameLevelObject *level9  = [[GameLevelObject alloc] initWithName:@selector(level_Pad_Shooter)           withData:nil        withInterval:1 withRepeat:15 withDelay:35];
    GameLevelObject *level10 = [[GameLevelObject alloc] initWithName:@selector(level_addExtraBall)          withData:(id)1      withInterval:1 withRepeat:1  withDelay:10];
    GameLevelObject *level11 = [[GameLevelObject alloc] initWithName:@selector(level_ShapeSimple_Float)     withData:(id)6      withInterval:2 withRepeat:8  withDelay:5];
    GameLevelObject *level12 = [[GameLevelObject alloc] initWithName:@selector(level_Rocket)                withData:(id)4      withInterval:1 withRepeat:1  withDelay:10];
    GameLevelObject *level13 = [[GameLevelObject alloc] initWithName:@selector(level_addExtraBall)          withData:(id)2      withInterval:1 withRepeat:1  withDelay:10];
    GameLevelObject *level14 = [[GameLevelObject alloc] initWithName:@selector(level_addExtraBall)          withData:(id)1      withInterval:1 withRepeat:1  withDelay:2];
    GameLevelObject *level15 = [[GameLevelObject alloc] initWithName:@selector(level_ShapeSimple)           withData:(id)4      withInterval:1 withRepeat:10 withDelay:5];
    GameLevelObject *level16 = [[GameLevelObject alloc] initWithName:@selector(level_ShapeSimple)           withData:(id)5      withInterval:1 withRepeat:10 withDelay:3];
    GameLevelObject *level17 = [[GameLevelObject alloc] initWithName:@selector(level_ShapeSimple)           withData:(id)6      withInterval:1 withRepeat:10 withDelay:3];
    GameLevelObject *level18 = [[GameLevelObject alloc] initWithName:@selector(level_Bird)                  withData:nil        withInterval:1 withRepeat:1  withDelay:10];
    GameLevelObject *level19 = [[GameLevelObject alloc] initWithName:@selector(level_addExtraBall)          withData:(id)1      withInterval:1 withRepeat:1  withDelay:20];
    GameLevelObject *level20 = [[GameLevelObject alloc] initWithName:@selector(level_ShapeTrouble_Float)    withData:(id)6      withInterval:2 withRepeat:8  withDelay:5];
    GameLevelObject *level21 = [[GameLevelObject alloc] initWithName:@selector(level_Pad_Shooter)           withData:nil        withInterval:1 withRepeat:15 withDelay:5];
    GameLevelObject *level22 = [[GameLevelObject alloc] initWithName:@selector(level_Gear)                  withData:nil        withInterval:1 withRepeat:1  withDelay:30];
    
    levelArray = [[NSArray alloc] initWithObjects:level1, level2, level3, level4, level5, level6, level7, level8, level9, level10, level11, level12, level13, level14, level15, level16, level17, level18, level19, level20, level21, level22, nil];
    
    [panel setMaxLevels:levelArray.count];
}

- (void)levelManager
{
    if (gamePaused) {
        return;
    }
    
    if (gameLevel == 0) {
        gameLevel = 1;
        gameLevelObj = levelArray[gameLevel - 1];
        gameLevelLifeTime = 0;
        
        [self schedule:gameLevelObj.levelMethod interval:gameLevelObj.interval repeat:gameLevelObj.repeat - 1 delay:gameLevelObj.delay];
        
        NSLog(@"GameLevel %d started.", gameLevel);
    }
    else {
        if (gameLevelLifeTime == gameLevelObj.repeat) {
            NSLog(@"GameLevel %d done.", gameLevel);
            
            if (gameLevel < [levelArray count]) {
                gameLevel++;
                gameLevelObj = levelArray[gameLevel - 1];
                gameLevelLifeTime = 0;
                
                [self schedule:gameLevelObj.levelMethod interval:gameLevelObj.interval repeat:gameLevelObj.repeat - 1 delay:gameLevelObj.delay];
                
                [panel setLevel:gameLevel];
                
                NSLog(@"GameLevel %d started.", gameLevel);
            }
            else {
                NSLog(@"No more levels!");
            }
        }
    }
}

- (void)rescueManager
{
    if (gamePaused) {
        return;
    }
    
    if (myPad.padScale < PAD_SCALE_MAX && !pendingRescueCollection) {
        pendingRescueCollection = YES;
        
        float delay = fabsf(myPad.padScale - PAD_SCALE_MIN) * 50;
        
        [self scheduleOnce:@selector(addRescueShape) delay:delay];
        
        NSLog(@"Pad rescue scheduled: %f sec", delay);
    }
}

- (void)update:(ccTime)delta
{
    ccTime fixed_dt = [CCDirector sharedDirector].animationInterval;
	[gameSpace step:fixed_dt];
    
    if (decPadSize) {
        if (!processingPad) {
            processingPad = YES;
            
            NSLog(@"Processing Pad ...");
            
            float padScale = myPad.padScale;
            
            [gameSpace remove:myPad];
            
            if (padScale >= PAD_SCALE_MIN) {
                padScale -= PAD_SCALE_AMT;
            }
            
            [myPad myScale:padScale];
            [gameSpace add:myPad];
            
            processingPad = NO;
            decPadSize = NO;
            
            NSLog(@"Pad scale: %f", padScale);
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"uh-oh.mp3"];
        }
        else {
            NSLog(@"Ignored double Pad processing!");
        }
    }
    
    if (incPadSize) {
        if (!processingPad) {
            processingPad = YES;
            
            NSLog(@"Processing Pad ...");
            
            float padScale = myPad.padScale;
            
            [gameSpace remove:myPad];
            
            if (padScale < PAD_SCALE_MAX) {
                padScale += PAD_SCALE_AMT;
            }
            
            [myPad myScale:padScale];
            [myPad shake];
            [gameSpace add:myPad];
            
            processingPad = NO;
            incPadSize = NO;
            
            NSLog(@"Pad scale: %f", padScale);
        }
        else {
            NSLog(@"Ignored double Pad processing!");
        }
    }
    
    if (gamePaused) {
        return;
    }
    
    [self checkPadDirection];
    [self whereIsBall];
    [self levelManager];
}

- (void)buildSpace
{
    gameSpace = [[ChipmunkSpace alloc] init];
    [gameSpace addBounds:CGRectMake(0, 0, SCREEN_WIDTH, globals.osPadHeight + YSCALE(40))
               thickness:THICKNESS
              elasticity:ELASTICITY
                friction:FRICTION
                  layers:CP_ALL_LAYERS
                   group:CP_NO_GROUP
           collisionType:@"Border"
     ];
    
    if (SHOW_PHYISIC) {
        CCPhysicsDebugNode *debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:gameSpace];
        [self addChild:debugNode z:100];
        debugNode.visible = YES;
    }
    
    gameSpace.gravity = cpv(GRAVITY_X, GRAVITY_Y);
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)level_ShapeSimple
{
    int r = 1 + arc4random() % MAX_SHAPES;

    ShapeObject *shape = [[ShapeObject alloc] initWithName:(r < 10) ? [NSString stringWithFormat:@"S0%d", r] : [NSString stringWithFormat:@"S%d", r] shapeType:SHAPE_TYPE_SIMPLE];
    shape.sprite.position = [self getRndShapePos:(int)gameLevelObj.myData emptySpace:YES];
    [gameSpace add:shape];
    [self addChild:shape.sprite z:SHAPE_LAYER];
    [shape fadeIn];
    [shapes addObject:shape];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"jump1.mp3"];
    
    gameLevelLifeTime++;
}

- (void)level_ShapeHard
{
    int r = 1 + arc4random() % MAX_SHAPES;
    
    ShapeObject *shape = [[ShapeObject alloc] initWithName:(r < 10) ? [NSString stringWithFormat:@"S0%d", r] : [NSString stringWithFormat:@"S%d", r] shapeType:SHAPE_TYPE_HARD];
    shape.sprite.position = [self getRndShapePos:(int)gameLevelObj.myData emptySpace:YES];
    [gameSpace add:shape];
    [self addChild:shape.sprite z:SHAPE_LAYER];
    [shape fadeIn];
    [shapes addObject:shape];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"jump2.mp3"];
    
    gameLevelLifeTime++;
}

- (void)level_ShapeSimple_Float
{
    int r = 1 + arc4random() % MAX_SHAPES;
    
    ShapeObject *shape = [[ShapeObject alloc] initWithName:(r < 10) ? [NSString stringWithFormat:@"S0%d", r] : [NSString stringWithFormat:@"S%d", r] shapeType:SHAPE_TYPE_SIMPLE];
    shape.floatingShape = YES;
    shape.sprite.position = [self getRndShapePos:(int)gameLevelObj.myData emptySpace:YES];
    [gameSpace add:shape];
    [self addChild:shape.sprite z:SHAPE_LAYER];
    [shape fadeIn];
    [shapes addObject:shape];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"jump1.mp3"];
    
    gameLevelLifeTime++;
}

- (void)level_ShapeTrouble_Float
{
    int r = 1 + arc4random() % 3;
    
    ShapeObject *shape = [[ShapeObject alloc] initWithName:[NSString stringWithFormat:@"T0%d", r] shapeType:SHAPE_TYPE_TROUBLE_1];
    shape.floatingShape = YES;
    shape.sprite.position = [self getRndShapePos:6 emptySpace:YES];
    [gameSpace add:shape];
    [self addChild:shape.sprite z:SHAPE_LAYER];
    [shape fadeIn];
    [shapes addObject:shape];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"jump3.mp3"];
    
    gameLevelLifeTime++;
}

- (void)level_Gear
{
    GearObject *gear1 = [[GearObject alloc] initWithName:@"GR01"];
    gear1.sprite.position = ccp((gear1.sprite.boundingBox.size.width / 2), [self getRndYPos:5]);
    [gameSpace add:gear1];
    [self addChild:gear1.sprite z:SHAPE_LAYER];
    [shapes addObject:gear1];
    
    GearObject *gear2 = [[GearObject alloc] initWithName:@"GR02"];
    gear2.sprite.position = ccp(SCREEN_WIDTH - (gear2.sprite.boundingBox.size.width / 2), [self getRndYPos:4]);
    [gameSpace add:gear2];
    [self addChild:gear2.sprite z:SHAPE_LAYER];
    [shapes addObject:gear2];
    
    [gear1 fadeIn];
    [gear2 fadeIn];
    
    [gear1 run];
    
    [gear1 moveMe];
    [gear2 moveMe];
    
    ChipmunkSimpleMotor *motor = [ChipmunkSimpleMotor simpleMotorWithBodyA:gear1.body bodyB:gear2.body rate:70];
    [gameSpace add:motor];
    
    gear1.motor = motor;
    gear2.motor = motor;
    
    gameLevelLifeTime++;
}

- (void)level_Bird
{
    BirdObject *bird1 = [[BirdObject alloc] initWithName:@"BirdB"];
    bird1.sprite.position = ccp(0, [self getRndYPos:5]);
    [gameSpace add:bird1];
    [self addChild:bird1.sprite z:BIRD_LAYER];
    [bird1 fadeIn];
    [bird1 goRight];
    [shapes addObject:bird1];
    
    BirdObject *bird2 = [[BirdObject alloc] initWithName:@"BirdR"];
    bird2.sprite.position = ccp(SCREEN_WIDTH - XSCALE(20), [self getRndYPos:5]);
    [gameSpace add:bird2];
    [self addChild:bird2.sprite z:BIRD_LAYER];
    [bird2 fadeIn];
    [bird2 goLeft];
    [shapes addObject:bird2];
    
    gameLevelLifeTime++;
}

- (void)level_Rocket
{
    RocketObject *rocket = [[RocketObject alloc] initWithName:@"Jet"];
    rocket.myDelegate = self;
    rocket.runCount = (int)gameLevelObj.myData;
    rocket.sprite.position = ccp(0, 0);
    [gameSpace add:rocket];
    [self addChild:rocket.sprite z:ROCKET_LAYER];
    [rocket run];
    [shapes addObject:rocket];
    
    gameLevelLifeTime++;
}

- (void)level_Pad_Shooter
{
    if (balls.count > 0) {
        BallLayer *ball = [balls objectAtIndex:0];
        
        if (ball.sprite.position.y >= osPad.sprite.position.y - YSCALE(200)) {
            NSLog(@"Don't shoot now!");
            
            gameLevelLifeTime++;
            
            return;
        }
    }
    else {
        NSLog(@"Pad shooter: No ball is available!");
        
        gameLevelLifeTime++;
        
        return;
    }
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"fire1.mp3"];
    
    PuffSprite *puff = [[PuffSprite alloc] initWithSpeed:0.05];
    puff.position = ccp(osPad.sprite.position.x, osPad.sprite.position.y - YSCALE(60));
    [self addChild:puff z:PUFF_LAYER];
    [puff action];
    
    ShapeObject *rocket = [[ShapeObject alloc] initWithName:@"RO03" shapeType:SHAPE_TYPE_ROCKET];
    rocket.sprite.position = ccp(osPad.sprite.position.x, osPad.sprite.position.y - rocket.sprite.contentSize.height / 2 - osPad.sprite.contentSize.height);
    [gameSpace add:rocket];
    [self addChild:rocket.sprite z:SHAPE_LAYER];
    [rocket fadeIn];
    [shapes addObject:rocket];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"fire2.mp3"];
    
    gameLevelLifeTime++;
}

- (void)level_addExtraBall
{
    cpVect standPos = [self getRndShapePos:5 emptySpace:YES];
    NSString *standName = [NSString stringWithFormat:@"Stand0%d", (int)gameLevelObj.myData];
    
    BallLayer *extraBall = [[BallLayer alloc] init];
    extraBall.sprite.position = standPos;
    extraBall.basePos = extraBall.sprite.position;
    [gameSpace add:extraBall];
    [self addChild:extraBall.sprite z:BALL_LAYER];
    
    ShapeObject *topStand = [[ShapeObject alloc] initWithName:standName shapeType:SHAPE_TYPE_STAND];
    topStand.sprite.position = ccp(standPos.x, standPos.y + extraBall.sprite.contentSize.height / 2 + topStand.sprite.contentSize.height);
    [gameSpace add:topStand];
    [self addChild:topStand.sprite z:SHAPE_LAYER];
    [topStand fadeIn];
    [shapes addObject:topStand];
    
    ShapeObject *bottomStand = [[ShapeObject alloc] initWithName:standName shapeType:SHAPE_TYPE_STAND];
    bottomStand.sprite.rotation = 180;
    bottomStand.sprite.position = ccp(standPos.x, standPos.y - extraBall.sprite.contentSize.height / 2 - bottomStand.sprite.contentSize.height);
    [gameSpace add:bottomStand];
    [self addChild:bottomStand.sprite z:SHAPE_LAYER];
    [bottomStand fadeIn];
    [shapes addObject:bottomStand];
    
    ShapeObject *leftStand = [[ShapeObject alloc] initWithName:standName shapeType:SHAPE_TYPE_STAND];
    leftStand.sprite.rotation = -90.0;
    leftStand.sprite.position = ccp(standPos.x - topStand.sprite.contentSize.height / 2 - leftStand.sprite.contentSize.width / 2, standPos.y);
    [gameSpace add:leftStand];
    [self addChild:leftStand.sprite z:SHAPE_LAYER];
    [leftStand fadeIn];
    [shapes addObject:leftStand];
    
    ShapeObject *rightStand = [[ShapeObject alloc] initWithName:standName shapeType:SHAPE_TYPE_STAND];
    rightStand.sprite.rotation = 90.0;
    rightStand.sprite.position = ccp(standPos.x + topStand.sprite.contentSize.height / 2 + rightStand.sprite.contentSize.width / 2, standPos.y);
    [gameSpace add:rightStand];
    [self addChild:rightStand.sprite z:SHAPE_LAYER];
    [rightStand fadeIn];
    [shapes addObject:rightStand];
    
    [balls addObject:extraBall];
    multiBalls++;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"uh-oh.mp3"];
    
    gameLevelLifeTime++;
}

- (void)level_Exploded_Shapes
{
    cpVect pos = [self getRndShapePos:5 emptySpace:YES];
    
    for (int i = 1; i <= 15; i++) {
        int r = 1 + arc4random() % 4;
        
        ShapeObject *shape = [[ShapeObject alloc] initWithName:[NSString stringWithFormat:@"B%d", r] shapeType:SHAPE_TYPE_SIMPLE];
        shape.sprite.position = pos;
        [gameSpace add:shape];
        [self addChild:shape.sprite z:SHAPE_LAYER];
        [shape fadeIn];
        [shapes addObject:shape];
    }
    
    gameLevelLifeTime++;
}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)addAmbiguousShape
{
    AmbiguousObject *shape = [[AmbiguousObject alloc] initWithName:@"Q02"];
    shape.sprite.position = [self getRndShapePos:4 emptySpace:YES];
    [gameSpace add:shape];
    [self addChild:shape.sprite z:SHAPE_LAYER];
    [shape fadeIn];
    [shape run];
    [shapes addObject:shape];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"uh-oh.mp3"];

}

- (void)addGiftShape:(GiftObject *)gift
{
    ShapeObject *shape = [[ShapeObject alloc] initWithName:gift.spriteName shapeType:SHAPE_TYPE_GIFT_1];
    shape.isGift = YES;
    shape.sprite.position = [self getRndShapePos:6 emptySpace:YES];
    [gameSpace add:shape];
    [self addChild:shape.sprite z:SHAPE_LAYER];
    [shape fadeIn];
    [shape rotate];
    [shapes addObject:shape];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"jump1.mp3"];
}

- (void)addRescueShape
{
    int r = RND(1, 2);
    
    ShapeObject *shape = [[ShapeObject alloc] initWithName:[NSString stringWithFormat:@"RC%d", r] shapeType:SHAPE_TYPE_RESCUE];
    shape.sprite.position = [self getRndShapePos:4 emptySpace:YES];
    [gameSpace add:shape];
    [self addChild:shape.sprite z:SHAPE_LAYER];
    [shape fadeIn];
    [shape beat];
    [shapes addObject:shape];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"points1.mp3"];
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)ballHitGearAmbiguous:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    cpShape *shapeA, *shapeB;
    ChipmunkShape *sa, *sb;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    sa = shapeA->data;
    sb = shapeB->data;
    
    ShapeObject *shape = b.data;
    
    [shapes removeObject:shape];
    [space smartRemove:shape];
    [shape fadeOut];
    [shape cleanUp];
    
    if (countBalls >= 2) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"uh-oh.mp3"];
        
        //[space addPostStepCallback:self selector:@selector(addGear) key:nil];
    }
    else {
        int d = arc4random() % 10;
        
        if (d >= 5) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"uh-oh.mp3"];
            
            //[space addPostStepCallback:self selector:@selector(addGear) key:nil];
        }
        else {
            //[space addPostStepCallback:self selector:@selector(addGiftShape) key:nil];
        }
    }
}

- (void)ballHitBall:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"ball.mp3"];
}

- (void)ballHitPad:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    lastShooter = MYPAD_SHOT;
    
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    cpShape *shapeA, *shapeB;
    ChipmunkShape *sa, *sb;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    sa = shapeA->data;
    sb = shapeB->data;
    
    [a resetForces];
    
    float velX = a.vel.x;
    int speedPad = 0;
    
    if (padDirection != 0) {
        speedPad = abs((int)myPad.sprite.position.x - padXStart);
        
        if (padDirection == 1) {
            velX = speedPad;
        }
        else {
            velX = -speedPad;
        }
    }
    
    if (a.vel.y < globals.ballDefVelY) {
        a.vel = cpv(velX + (int)myPad.sprite.position.x - padXStart, globals.ballDefVelY + speedPad);
    }
    else if (a.vel.y > globals.ballMaxVelY) {
        a.vel = cpv(velX + (int)myPad.sprite.position.x - padXStart, globals.ballMaxVelY);
    }
    else {
        a.vel = cpv(velX + (int)myPad.sprite.position.x - padXStart, abs(a.vel.y) + speedPad);
    }
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"ball.mp3"];
    
    /*
    id move = [CCMoveBy actionWithDuration:0.5 position:CGPointMake(0, -50)];
    id ease = [CCEaseOut actionWithAction:move rate:2];
    
    [chalkboardLayer runAction:ease];
    */
    
    /*
    CCParticleSystem *particle = [CCParticleSystemQuad particleWithFile:@"Stars.plist"];
    [self addChild:particle];
    
    //particle.positionType = kCCPositionTypeRelative;
    //particle.sourcePosition = myPad.position;
    particle.position = ccp(0, 0);
    [particle resetSystem];
    */
}

- (void)ballHitOSPad:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    lastShooter = OSPAD_SHOT;
    
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    cpShape *shapeA, *shapeB;
    ChipmunkShape *sa, *sb;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    sa = shapeA->data;
    sb = shapeB->data;
    
    int minVelX = XSCALE(800);
    
    if (a.vel.x >= -minVelX && a.vel.x <= minVelX) {
        if (a.vel.x >= 0)
            a.vel = cpv(minVelX, a.vel.y);
        else
            a.vel = cpv(-minVelX, a.vel.y);
    }
    
    if (a.vel.y < globals.ballDefVelY) {
        a.vel = cpv(a.vel.x, -globals.ballDefVelY);
    }
    else if (a.vel.y > globals.ballMaxVelY) {
        a.vel = cpv(a.vel.x, -globals.ballMaxVelY);
    }
    else {
        a.vel = cpv(a.vel.x, -a.vel.y);
    }
    
    a.vel = cpv(a.vel.x, a.vel.y * osPadVelYFactor);
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"ball.mp3"];
}

- (void)ballHitBorder:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"drop.mp3"];
    
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    cpShape *shapeA, *shapeB;
    ChipmunkShape *sa, *sb;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    sa = shapeA->data;
    sb = shapeB->data;
     
    int minVelY = YSCALE(700);
    int minVelX = XSCALE(600);
    
    a.force = ccp(-a.force.x, a.force.y);
    
    if (a.vel.y >= -minVelY && a.vel.y <= minVelY) {
        if (a.vel.y >= 0)
            a.vel = cpv(a.vel.x, minVelY);
        else
            a.vel = cpv(a.vel.x, -minVelY);
    }
    
    if (a.vel.x >= -minVelX && a.vel.x <= minVelX) {
        if (a.vel.x >= 0)
            a.vel = cpv(minVelX, a.vel.y);
        else
            a.vel = cpv(-minVelX, a.vel.y);
    }
}

- (void)ballHitGear:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"hitmetal.mp3"];
    
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    cpShape *shapeA, *shapeB;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    GearObject *gear = b.data;
    
    if (lastShooter == MYPAD_SHOT) {
        gear.motor.rate -= 10.0;
        
        gameScore += SCORE_BALL_GEAR;
        [panel flashScore];
        
        [self showPoints:gear.sprite.position points:SCORE_BALL_GEAR];
        
        if (gear.motor.rate <= 0) {
            [gameSpace smartRemove:gear];
        }
    }
}

- (BOOL)ballHitBase:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    if (gamePaused) {
        return false;
    }
    
    if (!GAMEOVER_ACTIVE) {
        NSLog(@"Game over is not active!");
        
        return false;
    }
    
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    BallLayer *ball = a.data;
    
    if (ball.hitBase) {
        NSLog(@"ballHitBase: Second time!");
    }
    else {
        ball.hitBase = YES;
        
        [ball.body resetForces];
        
        [self removeBall:ball];
        [self showPuff:arbiter];
        [self ballMissed:ball];
    }
    
    return false;
}

- (void)ballHitBird:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    cpShape *shapeA, *shapeB;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    BirdObject *bird = b.data;
    [bird shake];
    
    gameScore += SCORE_BALL_BIRD;
    [panel flashScore];
    
    [self showPoints:bird.sprite.position points:SCORE_BALL_BIRD];
    
    NSLog(@"ballHitBirdObject");
    
    if (bird.hit == 10) {
        [shapes removeObject:bird];
        [space smartRemove:bird];
        [bird fadeOut];
        [bird cleanUp];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"bird4.mp3"];
    }
    else {
        [[SimpleAudioEngine sharedEngine] playEffect:@"bird5.mp3"];
        
        bird.hit++;
    }
}

- (void)ballHitTroubleObject:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.mp3"];
    
    return;
    
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    cpShape *shapeA, *shapeB;
    ChipmunkShape *sa, *sb;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    sa = shapeA->data;
    sb = shapeB->data;
    
    int minVelY = XSCALE(900);
    
    if (a.vel.y >= -minVelY && a.vel.y <= minVelY) {
        if (a.vel.y >= 0)
            a.vel = cpv(a.vel.x, minVelY);
        else
            a.vel = cpv(a.vel.x, -minVelY);
    }
}

- (void)ballHitShapeObject:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    cpShape *shapeA, *shapeB;
    ChipmunkShape *sa, *sb;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    sa = shapeA->data;
    sb = shapeB->data;
    
    int minVelY = XSCALE(800);
    
    if (a.vel.y >= -minVelY && a.vel.y <= minVelY) {
        if (a.vel.y >= 0)
            a.vel = cpv(a.vel.x, minVelY);
        else
            a.vel = cpv(a.vel.x, -minVelY);
    }
    
    ShapeObject *shape = b.data;
    
    switch (shape.shapeType) {
        case SHAPE_TYPE_SIMPLE:
            if (lastShooter == OSPAD_SHOT) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"brick.mp3"];
            }
            else {
                gameScore += SCORE_BALL_SHAPE;
                
                [self showPoints:shape.sprite.position points:SCORE_BALL_SHAPE];
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"points1.mp3"];
            }
            
            if (shape.floatingShape) {
                if (shape.hit == 1) {
                    [shapes removeObject:shape];
                    [space smartRemove:shape];
                    [shape fadeOut];
                }
                else {
                    [shape shake];
                    shape.hit++;
                    
                    b.force = ccp(0, -YSCALE(1000));
                }
            }
            else {
                [shapes removeObject:shape];
                [space smartRemove:shape];
                [shape fadeOut];
            }
            break;
            
        case SHAPE_TYPE_HARD:
            if (lastShooter == OSPAD_SHOT) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"boxpain.mp3"];
            }
            else {
                gameScore += SCORE_BALL_SHAPE;
                
                [self showPoints:shape.sprite.position points:SCORE_BALL_SHAPE];
                
                if (shape.hit == 1) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"points1.mp3"];
                    
                    [shape shake];
                    [shapes removeObject:shape];
                    [space smartRemove:shape];
                    [shape fadeOut];
                }
                else {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"break1.mp3"];
                    
                    shape.hit++;
                    
                    [shape shake];
                    [shape crack];
                }
            }
            break;
            
        case SHAPE_TYPE_GIFT_1:
            if (lastShooter == OSPAD_SHOT) {
                [shape shake];
                
                b.force = ccp(0, -YSCALE(1000));
            }
            else {
                if (!giftCollected) {
                    giftCollected = YES;
                    pendingGiftCollection = NO;
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:@"getitem9.mp3"];
                    
                    countBalls++;
                    [panel setBall:countBalls];
                    
                    [shapes removeObject:shape];
                    [space smartRemove:shape];
                    [shape shake];
                    [shape fadeOut];
                }
            }
            break;
            
        case SHAPE_TYPE_ROCKET:
            gameScore += SCORE_BALL_ROCKET;
            [panel flashScore];
            
            [self showPoints:shape.sprite.position points:SCORE_BALL_ROCKET];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"getitem7.mp3"];
            
            [shapes removeObject:shape];
            [space smartRemove:shape];
            [shape fadeOut];
            
            [self showPuffPos:shape.sprite.position];
            break;
            
        case SHAPE_TYPE_RESCUE:
            [[SimpleAudioEngine sharedEngine] playEffect:@"getitem7.mp3"];
            
            incPadSize = YES;
            
            [shapes removeObject:shape];
            [space smartRemove:shape];
            [shape fadeOut];
            
            pendingRescueCollection = NO;
            break;
        
        case SHAPE_TYPE_STAND:
            [[SimpleAudioEngine sharedEngine] playEffect:@"getitem1.mp3"];
            
            gameScore += SCORE_BALL_STAND;
            
            [self showPoints:shape.sprite.position points:SCORE_BALL_STAND];
            break;
            
        default:
            break;
    }
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)gearHitGear:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"sawcut.mp3"];
    
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    a.vel = ccp(-a.vel.x * 2, -a.vel.y * 2);
    b.vel = ccp(-b.vel.x * 2, -b.vel.y * 2);
    
    GearObject *gearA = a.data;
    GearObject *gearB = b.data;
    
    [gearA.sprite stopAllActions];
    [gearB.sprite stopAllActions];
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)myPadHitGear:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"sawcut.mp3"];
    
    decPadSize = YES;
}

- (void)myPadHitShape:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    cpShape *shapeA, *shapeB;
    ChipmunkShape *sa, *sb;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    sa = shapeA->data;
    sb = shapeB->data;
    
    ShapeObject *shape = b.data;
    
    if (shape.shapeType == SHAPE_TYPE_GIFT_1) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"getitem9.mp3"];
        
        countBalls++;
        [panel setBall:countBalls];
    }
    else if (shape.shapeType == SHAPE_TYPE_ROCKET || shape.shapeType == SHAPE_TYPE_SHOOTER) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"fire1.mp3"];
        
        [shapes removeObject:shape];
        [space smartRemove:shape];
        [shape fadeOut];
        
        [myPad shake];
        
        decPadSize = YES;
    }
    else {
        gameScore += SCORE_PAD_SHAPE;
        [panel flashScore];
        
        [self showPoints:shape.sprite.position points:SCORE_PAD_SHAPE];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"getitem7.mp3"];
    }
    
    [self showPuff:arbiter];
    
    [shape shake];
    [shapes removeObject:shape];
    [space smartRemove:shape];
    [shape fadeOut];
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)shapeHitGear:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"brick.mp3"];
    
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    ShapeObject *shape = a.data;
    
    if (shape.shapeType == SHAPE_TYPE_RESCUE) {
        a.force = ccp(0, -YSCALE(500));
    }
    else {
        [shapes removeObject:shape];
        [space smartRemove:shape];
        [shape fadeOut];
    
        [self showPuff:arbiter];
    }
}

- (void)shapeHitBase:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    ShapeObject *shape = a.data;
    
    switch (shape.shapeType) {
        case SHAPE_TYPE_GIFT_1:
            [shapes removeObject:shape];
            [space smartRemove:shape];
            [shape fadeOut];
            
            [self showPuff:arbiter];
            break;
        
        case SHAPE_TYPE_ROCKET:
            [[SimpleAudioEngine sharedEngine] playEffect:@"fire1.mp3"];
            
            [shapes removeObject:shape];
            [space smartRemove:shape];
            [shape fadeOut];
            
            [self showPuff:arbiter];
            break;
        
        case SHAPE_TYPE_SHOOTER:
            [[SimpleAudioEngine sharedEngine] playEffect:@"fire1.mp3"];
            
            [shapes removeObject:shape];
            [space smartRemove:shape];
            [shape fadeOut];
            
            [self showPuff:arbiter];
            break;
            
        default:
            break;
    }
}

- (void)shapeHitTroubleObject:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    ShapeObject *shapeA = a.data;
    ShapeObject *shapeB = b.data;
    
    if (shapeA.shapeType == SHAPE_TYPE_ROCKET || shapeA.shapeType == SHAPE_TYPE_SHOOTER) {
        [shapes removeObject:shapeB];
        [space smartRemove:shapeB];
        [shapeB fadeOut];
        
        return;
    }
    
    if (!shapeA.hasJoint) {
        ChipmunkPinJoint *pin = [ChipmunkPinJoint pinJointWithBodyA:a bodyB:b anchr1:ccp(0, 0) anchr2:ccp(0, 0)];
        
        [shapeA.chipmunkObjects addObject:pin];
        [space smartAdd:pin];
    }
}

- (void)shapeHitShape:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"getitem1.mp3"];
    
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    ShapeObject *shapeB = b.data;
    ShapeObject *shapeA = a.data;
    
    if (shapeA.shapeType != SHAPE_TYPE_GIFT_1 && shapeA.shapeType != SHAPE_TYPE_ROCKET && shapeA.shapeType != SHAPE_TYPE_RESCUE) {
        [shapes removeObject:shapeA];
        [space smartRemove:shapeA];
        [shapeA fadeOut];
    }
    
    if (shapeB.shapeType != SHAPE_TYPE_GIFT_1 && shapeA.shapeType != SHAPE_TYPE_ROCKET && shapeA.shapeType != SHAPE_TYPE_RESCUE) {
        [shapes removeObject:shapeB];
        [space smartRemove:shapeB];
        [shapeB fadeOut];
    }
    
    //a.vel = cpv(a.vel.x * 5, a.vel.y * 5);
    //b.vel = cpv(a.vel.x * 5, a.vel.y * 5);
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)osPadHitShape:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"getitem1.mp3"];
    
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    cpShape *shapeA, *shapeB;
    ChipmunkShape *sa, *sb;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    sa = shapeA->data;
    sb = shapeB->data;
    
    ShapeObject *shape = b.data;
    
    [shape shake];
    [shapes removeObject:shape];
    [space smartRemove:shape];
    [shape fadeOut];
    
    [self showPuff:arbiter];
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)birdHitShape:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    BirdObject *bird = b.data;
    [bird shake];
    
    ShapeObject *shapeB = b.data;
    
    if (shapeB.shapeType != SHAPE_TYPE_GIFT_1) {
        [shapes removeObject:shapeB];
        [space smartRemove:shapeB];
        [shapeB fadeOut];
    }
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)rocketHitShape:(cpArbiter *)arbiter space:(ChipmunkSpace *)space
{
    cpBody *bodyA, *bodyB;
    ChipmunkBody *a, *b;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
    
    a = bodyA->data;
    b = bodyB->data;
    
    ShapeObject *shapeB = b.data;
    
    if (shapeB.shapeType != SHAPE_TYPE_GIFT_1 && shapeB.shapeType != SHAPE_TYPE_ROCKET && shapeB.shapeType != SHAPE_TYPE_RESCUE) {
        [self showPuffPos:shapeB.sprite.position];
        
        [shapes removeObject:shapeB];
        [space smartRemove:shapeB];
        [shapeB fadeOut];
    }
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)gameOver
{
    if (gameOver) {
        return;
    }
    
    gameOver = YES;
    
    NSLog(@"gameOver");
    
    [self stopTimers];
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    globals.lastScore = gameScore;
    globals.lastGameLevel = gameLevel;
    
    ScoreObject *obj = [[ScoreObject alloc] init];
    obj.score = globals.lastScore;
    obj.date = [NSDate date];
    [globals addScoreHistory:obj];
     
    if (globals.lastScore > globals.highScore) {
        globals.highScore = globals.lastScore;
    }
    
    [globals postScoreToServer:globals.lastScore];
    
    [[GameCenter sharedInstance] retrieveTopScores];
    
    for (int c = 0; c < [shapes count]; c++) {
        ShapeObject *obj = [shapes objectAtIndex:c];
        
        [obj cleanUp];
        [obj.sprite stopAllActions];
        [gameSpace smartRemove:obj];
        [self removeChild:obj.sprite cleanup:YES];
        
        obj = nil;
    }
    
    for (BallLayer *b in balls) {
        [self removeBall:b];
    }
    
    [shapes removeAllObjects];
    
    [self scheduleOnce:@selector(loadMainScene) delay:1.5];
    
    if (globals.isGameCenterAvailable) {
        [[GameCenter sharedInstance] reportScore:gameScore];
        
        NSLog(@"Score sent to the game center: %d", gameScore);
    }
    
    #ifdef CAM_VERSION
    [Kamcord stopRecording];
    [Kamcord showView];
    #endif
}

- (void)pauseGame
{
    gamePaused = YES;
    
    for (BallLayer *b in balls) {
        [b.sprite pauseSchedulerAndActions];
    }
    
    [self pauseSchedulerAndActions];
}

- (void)resumeGame
{
    gamePaused = NO;
    
    for (BallLayer *b in balls) {
        [b.sprite resumeSchedulerAndActions];
    }
}

- (void)userPaused
{
    if (gamePaused) {
        return;
    }
    
    [self pauseGame];
    [self showGameMenu];
}

- (void)loadMainScene
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainScene node]]];
}

- (void)restartGame
{
    NSLog(@"restartGame");
    
    gameOver = NO;
    countBalls = MAX_BALLS + globals.extraBalls;
    
    [myPad reset];
    [osPad reset];
    
    [panel setBall:countBalls];
    
    [self addBall];
    [self initTimers];
}

- (void)resetScore
{
    gameScore = 0;
    
    [panel setScore:gameScore];
}

- (void)calculateScore
{
    if (gamePaused) {
        return;
    }
    
    gameScore += SCORE_GAME_LIFE;
    
    [panel setScore:gameScore];
    
    if (!pendingGiftCollection) {
        if (giftObjects.count > 0) {
            GiftObject *gift = [giftObjects objectAtIndex:0];
            
            if (gameScore >= gift.scoreValue) {
                pendingGiftCollection = YES;
                giftCollected = NO;
                
                [self addGiftShape:gift];
                
                [giftObjects removeObjectAtIndex:0];
            }
        }
    }
}

- (void)anotherGo
{
    [self addBall];
    [self moveOSPad];
    
    gamePaused = NO;
}

- (void)moveOSPad
{
    int moveCount = 2 + arc4random() % 4;
    
    int minX = (osPad.sprite.contentSize.width / 2);
    int maxX = XSCALE(1536) - (osPad.sprite.contentSize.width / 2);
    
    int curX = osPad.sprite.position.x;
    int leftGap = 0;
    int rightGap = 0;
    int moveToX = 0;
    int moveByX = 0;
    
    NSMutableArray *actionArray = [[NSMutableArray alloc] init];
    
    for (int c = 1; c <= moveCount; c++) {
        leftGap = curX - minX;
        rightGap = maxX - curX;
        
        if (leftGap >= rightGap) {
            moveToX = minX + arc4random() % (curX - minX);
        }
        else {
            moveToX = curX + arc4random() % (maxX - curX);
        }
        
        moveByX = moveToX - curX;
        
        id moveAction = [CCMoveBy actionWithDuration:0.6 position:ccp(moveByX, 0)];
        
        [actionArray addObject:moveAction];
        
        curX = moveToX;
    }
    
    [actionArray addObject:[CCCallFuncND actionWithTarget:self selector:@selector(dropBall:force:) data:(void *)moveByX]];
    
    BallLayer *ball = [balls objectAtIndex:0];
    [ball.sprite runAction:[CCSequence actionWithArray:actionArray]];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"levelup1.mp3"];
}

- (void)checkPadDirection
{
    int x = (int)myPad.sprite.position.x;
    
    if (x > padLastX) {
        if (padDirection != 1) {
            padXStart = x;
        }
        
        padDirection = 1; //Right
    }
    else if (x < padLastX) {
        if (padDirection != -1) {
            padXStart = x;
        }
        
        padDirection = -1; //Left
    }
    else {
        padDirection = 0; //No Move
        padXStart = x;
    }
    
    padLastX = (int)myPad.sprite.position.x;
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)addBall
{
    BallLayer *ball = [[BallLayer alloc] init];
    [ball reset:osPad.sprite];
    [gameSpace add:ball];
    [self addChild:ball.sprite z:BALL_LAYER];
    
    if (balls.count > 0) {
        id obj = [balls objectAtIndex:0];
        
        [balls removeObjectAtIndex:0];
        [balls addObject:ball];
        [balls addObject:obj];
    }
    else {
        [balls addObject:ball];
    }
}

- (void)removeBall:(BallLayer *)ball
{
    @try {
        [gameSpace smartRemove:ball];
        [self removeChild:ball.sprite cleanup:NO];
        
        [balls removeObject:ball];
    }
    @catch (NSException *exception) {
        NSLog(@"removeBall execption :%@", exception.description);
    }
    @finally {
    }
}

- (void)ballMissed:(BallLayer *)ball
{
    if (gamePaused) {
        return;
    }
    
    int activeBalls = 0;
    
    for (BallLayer *b in balls) {
        if (CGPointEqualToPoint(b.basePos, b.sprite.position)) {
            NSLog(@"CGPointEqualToPoint");
        }
        else {
            activeBalls++;
        }
    }
    
    NSLog(@"activeBalls: %d", activeBalls);
    
    if (activeBalls > 0) {
        multiBalls--;
        
        if (multiBalls >= 1) {
            return;
        }
    }
    
    gamePaused = YES;
    isBallActive = NO;
    lastShooter = 0;
    
    NSLog(@"ballMissed, %d ball(s) left", countBalls - 1);
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.mp3"];
    
    countBalls--;
    [panel setBall:countBalls];
    
    if (countBalls == 0) {
        [self gameOver];
            
        return;
    }
    
    [osPad reset];
    
    [self scheduleOnce:@selector(anotherGo) delay:2.0];
}

- (void)whereIsBall
{
    if (gameOver) {
        return;
    }
    
    if (gamePaused) {
        return;
    }
    
    int halfSize = (osPad.sprite.contentSize.width / 2);
    
    BallLayer *ball = [balls objectAtIndex:0];
    
    if (ball.sprite.position.y >= globals.osPadHeight) {
        ball.sprite.position = ccp(ball.sprite.position.x, ball.basePos.y);
        
        NSLog(@"Ball saved!");
    }
    
    if (ball.sprite.position.x > SCREEN_WIDTH - halfSize) {
        osPad.sprite.position = ccp(SCREEN_WIDTH - halfSize, osPad.sprite.position.y);
    }
    else if (ball.sprite.position.x < halfSize) {
        osPad.sprite.position = ccp(halfSize, osPad.sprite.position.y);
    }
    else {
        osPad.sprite.position = ccp(ball.sprite.position.x, osPad.sprite.position.y);
    }
}

- (void)dropBall:(id)sender force:(int)x
{
    isBallActive = YES;
    lastShooter = OSPAD_SHOT;
    
    BallLayer *ball = [balls objectAtIndex:0];
    [ball drop:ccp(x * 2, -(globals.ballDefVelY + 1000))];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"ball.mp3"];
}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)showPoints:(cpVect)pos points:(int)points
{
    PointsSprite *sprite = [[PointsSprite alloc] initWithPoints:points];
    sprite.position = pos;
    [self addChild:sprite z:POINTS_LAYER];
    [sprite go];
}

- (void)showPuff:(cpArbiter *)arbiter
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"ballhit03.mp3"];
    
    cpContactPointSet set = cpArbiterGetContactPointSet(arbiter);
    if (set.count > 0) {
        PuffSprite *puff = [PuffSprite node];
        puff.position = set.points[0].point;
        [self addChild:puff z:PUFF_LAYER];
        [puff action];
    }
}

- (void)showPuffPos:(cpVect)pos
{
    PuffSprite *puff = [PuffSprite node];
    puff.position = pos;
    [self addChild:puff z:PUFF_LAYER];
    [puff action];
}

- (BOOL)posHasFilled:(int)x y:(int)y
{
    for (int c = 0; c < [shapes count]; c++) {
        ShapeObject *obj = [shapes objectAtIndex:c];
        
        CGRect rect = [obj.sprite boundingBox];
        rect = CGRectMake(rect.origin.x - rect.size.width, rect.origin.y - rect.size.height, rect.size.width * 3, rect.size.height * 3);
        
        if (CGRectContainsPoint(rect, CGPointMake(x, y))) {
            return YES;
        }
    }
    
    return NO;
}

- (CGPoint)getRndShapePos:(int)level emptySpace:(BOOL)shouldBeEmpty
{
    int minY = (SCREEN_HEIGHT / 2) - (level * 25);
    int maxY = (SCREEN_HEIGHT / 2) + (level * 25 + 25);
    
    minY = (minY < lowerGuideLine) ? lowerGuideLine : minY;
    maxY = (maxY > upperGuideLine) ? upperGuideLine : maxY;
    
    int y = minY + arc4random() % (maxY - minY);
    
    int minX = 40;
    int maxX = SCREEN_WIDTH - 40;
    int x = minX + arc4random() % (maxX - minX);
    
    if (SHOW_GUIDES) {
        if (lowerGuide == nil) {
            lowerGuide = [CCSprite spriteWithFile:@"guildline.png"];
            lowerGuide.opacity = 30;
            [self addChild:lowerGuide z:GUIDE_LAYER];
        }
        
        if (upperGuide == nil) {
            upperGuide = [CCSprite spriteWithFile:@"guildline.png"];
            upperGuide.opacity = 30;
            [self addChild:upperGuide z:GUIDE_LAYER];
        }
        
        lowerGuide.position = ccp(SCREEN_WIDTH / 2, minY);
        upperGuide.position = ccp(SCREEN_WIDTH / 2, maxY);
    }
    
    if (shouldBeEmpty) {
        if ([self posHasFilled:x y:y]) {
            return [self getRndShapePos:level emptySpace:shouldBeEmpty];
        }
    }
    
    return ccp(x,y);
}

- (int)getRndXPos:(int)level
{
    int minX = 40;
    int maxX = SCREEN_WIDTH - 40;
    int x = minX + arc4random() % (maxX - minX);
    
    return x;
}

- (int)getRndYPos:(int)level
{
    int minY = (SCREEN_HEIGHT / 2) - (level * 25);
    int maxY = (SCREEN_HEIGHT / 2) + (level * 25 + 25);
    
    minY = (minY < lowerGuideLine) ? lowerGuideLine : minY;
    maxY = (maxY > upperGuideLine) ? upperGuideLine : maxY;
    
    int y = minY + arc4random() % (maxY - minY);
    
    return y;
}


// Delegates
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


- (void)rocketCleanup
{
    for (int c = 0; c < [shapes count]; c++) {
        if ([[shapes objectAtIndex:c] isKindOfClass:[RocketObject class]]) {
            RocketObject *obj = [shapes objectAtIndex:c];
            
            [shapes removeObject:obj];
            [gameSpace smartRemove:obj];
            
            NSLog(@"rocketCleanup");
            
            break;
        }
    }
}

- (void)rocketFire:(NSNotification *)notification
{
    if (gameOver) {
        return;
    }
    
    cpVect pos = [[[notification userInfo] valueForKey:@"position"] CGPointValue];
    
    ShapeObject *rocket = [[ShapeObject alloc] initWithName:@"RO02" shapeType:SHAPE_TYPE_ROCKET];
    rocket.sprite.position = pos;
    [gameSpace add:rocket];
    [self addChild:rocket.sprite z:SHAPE_LAYER];
    [rocket fadeIn];
    [shapes addObject:rocket];
    
    PuffSprite *puff = [[PuffSprite alloc] initWithSpeed:0.05];
    puff.position = pos;
    [self addChild:puff z:PUFF_LAYER];
    [puff action];
}


@end
