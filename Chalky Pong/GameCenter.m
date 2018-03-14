//
//  GameCenter.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 14/04/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "GameCenter.h"

@implementation GameCenter

@synthesize gameCenterAvailable;
@synthesize myDelegate;
@synthesize userAuthenticated;

static GameCenter *sharedHelper = nil;
+ (GameCenter *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GameCenter alloc] init];
    }
    return sharedHelper;
}

- (id)init {
    if ((self = [super init])) {
        globals = [GameGlobals sharedGlobal];
        gameCenterAvailable = [self isGameCenterAvailable];
        
        if (gameCenterAvailable) {
            NSLog(@"GameCenter available");
            
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
        else {
            NSLog(@"GameCenter is not available");
        }
    }
    return self;
}

- (void)authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        
        userAuthenticated = TRUE;
        
        [self retrieveTopScores];
    }
    else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        
        userAuthenticated = FALSE;
    }
    
    for (UIView *v in [[[UIApplication sharedApplication] keyWindow] subviews]) {
        if (v.tag == 55) {
            [v removeFromSuperview];
        }
    }
}

- (BOOL)isGameCenterAvailable {
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (void)authenticateLocalUser {
    localPlayer = [GKLocalPlayer localPlayer];
    
    if (globals.iOSVer >= 6) {
        localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
            NSLog(@"authenticateHandler: %@", error.description);
            
            if (viewController != nil) {
                if (IT_IS_iPad) {
                    viewController.view.frame = CGRectMake(SCREEN_WIDTH / 2 - 270, SCREEN_HEIGHT / 2 - 310, 540, 620);
                }
                
                viewController.view.tag = 55;
                
                [[[UIApplication sharedApplication] keyWindow] addSubview:viewController.view];
                
                NSLog(@"Player is not authenticated!");
            }
            else if (localPlayer.isAuthenticated) {
                NSLog(@"Player authenticated, playerID: %@", localPlayer.playerID);
                
                globals.isGameCenterAvailable = YES;
                globals.playerID = localPlayer.playerID;
                
                //[self retrieveTopScores];
            }
            else {
                for (UIView *v in [[[UIApplication sharedApplication] keyWindow] subviews]) {
                    if (v.tag == 55) {
                        [v removeFromSuperview];
                    }
                }
                
                NSLog(@"Disable game center!");
            }
        };
    }
    else {
        /*
        [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
            if (localPlayer.isAuthenticated) {
                NSLog(@"authenticateWithCompletionHandler: %@", error.description);
                
                globals.isGameCenterAvailable = YES;
            }
            else {
                NSLog(@"Local player is not authenticated!");
            }
        }];
        */
    }
}

- (void)reportScore:(int64_t)score {
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"grp.CP_Leaderboard"];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    if (globals.iOSVer >= 7) {
        [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
            NSLog(@"GameCenter reportScoreWithCompletionHandler: %@", error.description);
        }];
    }
    else {
        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
            NSLog(@"GameCenter reportScoreWithCompletionHandler: %@", error.description);
        }];
    }
}

- (void)retrieveTopScores
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    
    if (leaderboardRequest != nil) {
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeToday;
        leaderboardRequest.range = NSMakeRange(1,100);
        
        if (globals.iOSVer >= 7) {
            leaderboardRequest.identifier = @"grp.CP_Leaderboard";
        }
        else {
            leaderboardRequest.category = @"grp.CP_Leaderboard";
        }
        
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (error != nil) {
                NSLog(@"GameCenter error getting scores: %@", error.description);
            }
            
            if (scores != nil) {
                globals.gameCenterScores = scores;
                
                NSLog(@"GameCenter Scores: %d", scores.count);
                
                NSArray *playerIDs = [scores valueForKey:@"playerID"];
                
                [GKPlayer loadPlayersForIdentifiers:playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
                    if (error != nil) {
                        NSLog(@"GameCenter error getting players: %@", error.description);
                    }
                    
                    if (players != nil) {
                        globals.gameCenterPlayer = players;
                        
                        for (GKPlayer *player in players) {
                            NSLog(@"Player: %@", player.displayName);
                        }
                    }
                }];
                
                for (GKScore *score in scores) {
                    NSLog(@"Score:%lld", score.value);
                }
                
                [[self myDelegate] gameCenterDataReady];
            }
        }];
    }
}

@end
