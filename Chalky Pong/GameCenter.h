//
//  GameCenter.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 14/04/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "GameGlobals.h"

@protocol GameCenterDelegate <NSObject>
@optional
- (void)gameCenterDataReady;
@end

@interface GameCenter : NSObject {
    id <GameCenterDelegate> myDelegate;
    
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    
    GKLocalPlayer *localPlayer;
    
    GameGlobals *globals;
    
    UIViewController *login;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL userAuthenticated;
@property (strong, nonatomic) id myDelegate;

+ (GameCenter *)sharedInstance;
- (void)authenticateLocalUser;
- (void)reportScore:(int64_t)score;
- (void)retrieveTopScores;

@end
