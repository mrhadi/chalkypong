//
//  GameGlobals.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 18/02/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <StoreKit/StoreKit.h>
#import "Reachability.h"

#define TOP_SCREEN      [[CCDirector sharedDirector] winSize].height
#define SCREEN_WIDTH    [[CCDirector sharedDirector] winSize].width
#define SCREEN_HEIGHT   [[CCDirector sharedDirector] winSize].height

#define IT_IS_iPad      (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IT_IS_iPhone    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IT_IS_iPhone5   SCREEN_HEIGHT == 568

#define iPHONE_WIDTH     320
#define iPHONE_HEIGHT    480
#define iPAD_WIDTH       768
#define iPAD_HEIGHT      1024

#define TWO_BALLS_Pack1  @"com.nilooapps.chalkypong.2ballspack1"

#define XSCALE(x)       (IT_IS_iPad ? (x / 2) : (iPHONE_WIDTH  * (x / 2)) / iPAD_WIDTH)
#define YSCALE(y)       (IT_IS_iPad ? (y / 2) : (iPHONE_HEIGHT * (y / 2)) / iPAD_HEIGHT)

#define FONTSCALE(s)    (IT_IS_iPad ? s : s / 1.8)

#define RND(min, max)   min + (arc4random() % (max - min + 1))

#define iPadPhone5(iPad, iPhone, iPhone5)   (IT_IS_iPad ? iPad : (IT_IS_iPhone5 ? iPhone5 : iPhone))


@class ScoreObject;

@interface GameGlobals : NSObject <NSURLConnectionDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    CGSize screenSize;
    
    int osPadHeight;
    int myPadHeight;
    
    int ballDefVelY;
    int ballMaxVelY;
    
    int highScore;
    int lastScore;
    int lastGameLevel;
    int ranking;
    int lastRanking;
    int extraBalls;
    
    int iOSVer;
    
    BOOL gameSound;
    BOOL gameMusic;
    BOOL appFreeVersion;
    BOOL isGameCenterAvailable;
    BOOL firstHomeVisit;
    BOOL hasPurchase;
    
    NSUserDefaults *userDefaults;
    
    NSString *deviceUDID;
    NSString *playerID;
    
    NSMutableArray *scoreHistory;
    NSMutableArray *inAppProducts;
    NSMutableArray *inAppPurchase;
    
    NSArray *gameCenterPlayer;
    NSArray *gameCenterScores;
    
    Reachability *internetReachability;
    Reachability *hostReachability;
}

+ (id)sharedGlobal;

@property (readonly) CGSize screenSize;
@property (readonly) int osPadHeight;
@property (readonly) int myPadHeight;
@property (readonly) int ballDefVelY;
@property (readonly) int ballMaxVelY;
@property (readonly) int iOSVer;
@property (readonly) int extraBalls;
@property (readonly) BOOL appFreeVersion;
@property (readonly) BOOL hasPurchase;
@property int highScore;
@property int lastScore;
@property int lastGameLevel;
@property int ranking;
@property BOOL gameSound;
@property BOOL gameMusic;
@property BOOL isGameCenterAvailable;
@property BOOL firstHomeVisit;
@property (nonatomic, strong) NSString *deviceUDID;
@property (nonatomic, strong) NSString *playerID;
@property (nonatomic, strong, readonly) NSMutableArray *scoreHistory;
@property (nonatomic, strong, readonly) NSMutableArray *inAppProducts;
@property (nonatomic, strong, readonly) NSMutableArray *inAppPurchase;
@property (nonatomic, strong) NSArray *gameCenterPlayer;
@property (nonatomic, strong) NSArray *gameCenterScores;

- (void)musicOff;
- (void)musicOn;
- (void)musicUp;
- (void)musicDown;
- (void)soundOff;
- (void)soundOn;
- (void)loadSettings;
- (void)saveSettings;
- (void)addScoreHistory:(ScoreObject *)obj;
- (void)playClick;
- (void)postScoreToServer:(int)score;
- (void)getPlayerRanking;
- (void)restorePurchases;
- (void)postExtra;

- (CGPoint)uniPoint:(CGPoint)p withXGap:(int)xGap withYGap:(int)yGap;
- (int)uniX:(int)x;
- (int)uniY:(int)y;

@end
