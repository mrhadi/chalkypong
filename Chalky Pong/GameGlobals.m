//
//  GameGlobals.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 18/02/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import "GameGlobals.h"
#import "SimpleAudioEngine.h"
#import "ScoreObject.h"

#include <sys/types.h>
#include <sys/sysctl.h>


#define SERVER_KEY  @"1CLqQlDIR4Sk246KXXnVqo94V9Xlz8Fb55"
#define SERVER_URL  @"https://www.nilooapps.com/chalkypong/scripts/scoreEngine.php"

static GameGlobals *sharedGlobal = nil;

@implementation GameGlobals

@synthesize screenSize;
@synthesize osPadHeight;
@synthesize myPadHeight;
@synthesize ballDefVelY;
@synthesize ballMaxVelY;
@synthesize gameMusic;
@synthesize gameSound;
@synthesize highScore;
@synthesize lastScore;
@synthesize lastGameLevel;
@synthesize ranking;
@synthesize iOSVer;
@synthesize isGameCenterAvailable;
@synthesize scoreHistory;
@synthesize gameCenterPlayer;
@synthesize gameCenterScores;
@synthesize deviceUDID;
@synthesize playerID;
@synthesize appFreeVersion;
@synthesize inAppProducts;
@synthesize inAppPurchase;
@synthesize extraBalls;
@synthesize firstHomeVisit;
@synthesize hasPurchase;

+ (id)sharedGlobal
{
    @synchronized(self) {
        if (sharedGlobal == nil)
            sharedGlobal = [[self alloc] init];
    }
    return sharedGlobal;
}

- (id)init
{
    if (self == [super init]) {
        userDefaults = [NSUserDefaults standardUserDefaults];
        screenSize = [[CCDirector sharedDirector] winSize];
        scoreHistory = [[NSMutableArray alloc] init];
        inAppProducts = [[NSMutableArray alloc] init];
        inAppPurchase = [[NSMutableArray alloc] init];
        iOSVer = [[[UIDevice currentDevice] systemVersion] integerValue];
        gameCenterScores = [[NSArray alloc] init];
        gameCenterPlayer = [[NSArray alloc] init];
        
        NSLog(@"iOS %d", iOSVer);
        
        gameSound = YES;
        gameMusic = YES;
        firstHomeVisit = YES;
        hasPurchase = NO;
        highScore = 0;
        lastScore = 0;
        lastGameLevel = 0;
        lastRanking = 0;
        extraBalls = 0;
        isGameCenterAvailable = NO;
        deviceUDID = @"";
        playerID = @"";
        
        myPadHeight = SCREEN_HEIGHT / 6;
        osPadHeight = SCREEN_HEIGHT - YSCALE(200);
        
        int gapBetweenPads = osPadHeight - myPadHeight;
        
        NSLog(@"ScreenSize: %dx%d", (int)SCREEN_WIDTH, (int)SCREEN_HEIGHT);
        NSLog(@"GapBetweenPads: %d", gapBetweenPads);
        
        if (IT_IS_iPhone5) {
            ballDefVelY = 465;
        }
        else if (IT_IS_iPhone) {
            ballDefVelY = 420;
        }
        else if (IT_IS_iPad) {
            ballDefVelY = 800;
        }
        else {
            ballDefVelY = 500;
        }
        
        ballMaxVelY = ballDefVelY + 30;
        
        NSString *isSettings = [userDefaults objectForKey:@"isSettings"];
        if (isSettings == nil) {
            [self saveSettings];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        internetReachability = [Reachability reachabilityForInternetConnection];
        [internetReachability startNotifier];
        
        hostReachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
        [hostReachability startNotifier];
        
        #ifdef FREE_VERSION
            appFreeVersion = YES;
            NSLog(@"Free Version");
        #else
            appFreeVersion = NO;
            NSLog(@"Paid Version");
        #endif
        
        [self loadSettings];
        [self runAppPurchase];
    }
    
    return self;
}

- (void)loadSettings
{
    gameSound = [userDefaults boolForKey:@"gameSound"];
    gameMusic = [userDefaults boolForKey:@"gameMusic"];
    hasPurchase = [userDefaults boolForKey:@"hasPurchase"];
    highScore = [userDefaults integerForKey:@"highScore"];
    lastScore = [userDefaults integerForKey:@"lastScore"];
    lastRanking = [userDefaults integerForKey:@"lastRanking"];
    
    NSData *scoreData = [userDefaults objectForKey:@"scoreHistory"];
    if (scoreData.length > 0) {
        scoreHistory = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:scoreData]];
    }
    
    NSLog(@"loadSetting:");
    NSLog(@"gameSound: %hhd", gameSound);
    NSLog(@"gameMusic: %hhd", gameMusic);
    NSLog(@"hasPurchase: %hhd", hasPurchase);
    NSLog(@"highScore: %d", highScore);
    NSLog(@"lastRanking: %d", lastRanking);
    NSLog(@"scoreHistory: %d item(s)", [scoreHistory count]);
    
    if (!gameSound) {
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
    }
}

- (void)saveSettings
{
    NSData *scoreData = [[NSData alloc] init];
    
    if (scoreHistory.count > 0) {
        scoreData = [NSKeyedArchiver archivedDataWithRootObject:scoreHistory];
    }
    
    [userDefaults setBool:gameSound forKey:@"gameSound"];
    [userDefaults setBool:gameMusic forKey:@"gameMusic"];
    [userDefaults setBool:hasPurchase forKey:@"hasPurchase"];
    [userDefaults setValue:@"Yes" forKey:@"isSettings"];
    [userDefaults setInteger:highScore forKey:@"highScore"];
    [userDefaults setInteger:lastScore forKey:@"lastScore"];
    [userDefaults setInteger:lastRanking forKey:@"lastRanking"];
    [userDefaults setObject:scoreData forKey:@"scoreHistory"];
    [userDefaults synchronize];
    
    NSLog(@"saveSettings");
    
    @try {
        NSLog(@"Caller: [%@]", [[[[NSThread callStackSymbols] objectAtIndex:1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]] objectAtIndex:1]);
    }
    @catch (NSException *exception) {
        NSLog(@"Error on finding the caller method: %@", exception.description);
    }
    @finally {
    }
}

- (void)addScoreHistory:(ScoreObject *)obj
{
    [scoreHistory addObject:obj];
    
    NSSortDescriptor *scoreDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSArray *sortedArray = [scoreHistory sortedArrayUsingDescriptors:[NSArray arrayWithObject:scoreDescriptor]];
    
    scoreHistory = [[NSMutableArray alloc] initWithArray:sortedArray];
}

- (void)musicOff
{
    gameMusic = NO;
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    [self saveSettings];
}

- (void)musicOn
{
    gameMusic = YES;

    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background2.mp3" loop:YES];
    
    [self saveSettings];
}

- (void)soundOff
{
    gameSound = NO;
    
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
    
    [self saveSettings];
}

- (void)soundOn
{
    gameSound = YES;

    [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0];
    
    [self saveSettings];
}

- (void)musicUp
{
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0];
}

- (void)musicDown
{
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.4];
}

- (void)playClick
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.mp3" pitch:1.0f pan:0.0f gain:1.0f];
}

- (CGPoint)uniPoint:(CGPoint)p withXGap:(int)xGap withYGap:(int)yGap
{
    int x = p.x;
    int y = p.y;
    
    CGPoint cOrg = ccp(768 / 2, 1024 / 2);
    CGPoint cCur = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    
    int dX = cOrg.x - x;
    int dY = cOrg.y - y;
    
    return CGPointMake(cCur.x - (dX * 0.41) - xGap,  cCur.y - (dY * 0.41) - yGap);
}

- (int)uniX:(int)x
{
    CGPoint cOrg = ccp(768 / 2, 1024 / 2);
    CGPoint cCur = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    
    int dX = cOrg.x - x;
    
    return cCur.x - (dX * 0.41);
}

- (int)uniY:(int)y
{
    CGPoint cOrg = ccp(768 / 2, 1024 / 2);
    CGPoint cCur = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    
    int dY = cOrg.y - y;
    
    return cCur.y - (dY * 0.41);
}

- (void)postScoreToServer:(int)score
{
    #ifdef FREE_VERSION
        NSString *appType = @"Free";
    #else
        NSString *appType = @"Paid";
    #endif
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    NSLog(@"Platform: %@", platform);
    
    NSString *post = [[NSString alloc] initWithFormat:@"action=ADD_SCORE&key=%@&udid=%@&score=%d&platform=%@&level=%d&type=%@", SERVER_KEY, deviceUDID, score, platform, lastGameLevel, appType];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSLog(@"postScoreToServer: %@", post);
    
    NSData *postData = [post dataUsingEncoding:[NSString defaultCStringEncoding]];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error == nil) {
            NSString *rank = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            ranking = [rank intValue];
            
            NSLog(@"Ranking: %d", ranking);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RankingIsReady" object:nil];
        }
        else {
            NSLog(@"postScoreToServer: %@", error.description);
            
            NSLog(@"Can't get live ranking, used the local one!");
            
            if (lastRanking == 0) {
                ranking = [userDefaults integerForKey:@"ranking"];
            }
            else {
                ranking = lastRanking;
            }
            
            NSLog(@"Local ranking: %d", ranking);
        }
        
        lastRanking = ranking;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RankingIsReady" object:nil];
    }];
}

- (void)getPlayerRanking
{
    NSString *post = [[NSString alloc] initWithFormat:@"action=GET_RANK&key=%@&udid=%@", SERVER_KEY, deviceUDID];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSLog(@"getPlayerRanking: %@", post);
    
    NSData *postData = [post dataUsingEncoding:[NSString defaultCStringEncoding]];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error == nil) {
            NSString *rank = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            ranking = [rank intValue];
            
            NSLog(@"Ranking: %d", ranking);
        }
        else {
            NSLog(@"getPlayerRanking: %@", error.description);
            NSLog(@"Can't get live ranking, used the local one!");
            
            if (lastRanking == 0) {
                ranking = [userDefaults integerForKey:@"ranking"];
            }
            else {
                ranking = lastRanking;
            }
            
            NSLog(@"Local ranking: %d", ranking);
        }
        
        lastRanking = ranking;

        [[NSNotificationCenter defaultCenter] postNotificationName:@"RankingIsReady" object:nil];
    }];
}

- (void)postExtra
{
    NSString *post = [[NSString alloc] initWithFormat:@"action=SET_EXTRA&key=%@&udid=%@", SERVER_KEY, deviceUDID];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSLog(@"postExtra: %@", post);
    
    NSData *postData = [post dataUsingEncoding:[NSString defaultCStringEncoding]];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error == nil) {
            NSString *res = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"postExtra: %@", res);
        }
        else {
            NSLog(@"postExtra: %@", error.description);
        }
    }];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

- (void)runAppPurchase
{
     if (appFreeVersion) {
         [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
     
         if ([SKPaymentQueue canMakePayments]) {
             SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:TWO_BALLS_Pack1]];
             request.delegate = self;
             
             [request start];
         }
         else {
             NSLog(@"Please enable In App Purchase in Settings");
         }
     }
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@">> paymentQueue updatedTransactions ...");
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"SKPaymentTransactionStatePurchased");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                if (transaction.originalTransaction) {
                    NSLog(@"Restored");
                }
                
                hasPurchase = YES;
                
                [inAppPurchase addObject:transaction.payment.productIdentifier];
                
                [self saveSettings];
                [self processPurchases];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"SKPaymentTransactionStateFailed: %@", transaction.error);
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"SKPaymentTransactionStatePurchasing");
                break;
                
            case SKPaymentTransactionStateRestored:
                NSLog(@"SKPaymentTransactionStateRestored");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            default:
                break;
        }
        
        NSDictionary *dic = [NSDictionary dictionaryWithObject:transaction forKey:@"transaction"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TransactionState" object:nil userInfo:dic];
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@">> paymentQueueRestoreCompletedTransactionsFinished: %lu", (unsigned long)queue.transactions.count);
    
    for (SKPaymentTransaction *transaction in queue.transactions) {
        if (SKPaymentTransactionStateRestored){
            NSLog(@"SKPaymentTransactionStateRestored: %@", transaction.payment.productIdentifier);
            
            [inAppPurchase addObject:transaction.payment.productIdentifier];
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }

    [self processPurchases];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RestoreCompleted" object:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@">> paymentQueue restoreCompletedTransactionsFailedWithError: %@", error.description);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RestoreCompleted" object:nil];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@">> productsRequest didReceiveResponse ...");
    
    NSArray *products = response.products;
    
    for (SKProduct *product in response.products) {
        [inAppProducts addObject:product];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedString = [numberFormatter stringFromNumber:product.price];
        
        NSLog(@"productsRequest: [%@][%@][%@][%@][%@]", product.localizedTitle, product.localizedDescription, product.price, formattedString, product.productIdentifier);
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products) {
        NSLog(@"Product not found: %@", product);
    }
}

- (void)restorePurchases
{
    NSLog(@">> restorePurchases");
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)processPurchases
{
    NSLog(@">> processPurchases ...");
    
    for (SKProduct *product in inAppProducts) {
        if ([inAppPurchase containsObject:product.productIdentifier]) {
            NSLog(@"[%@] has been purchased", product.productIdentifier);
            
            if ([product.productIdentifier isEqualToString:TWO_BALLS_Pack1]) {
                extraBalls = 2;
            }
        }
    }
    
    if (extraBalls > 0) {
        hasPurchase = YES;
        
        [self saveSettings];
    }
    
    NSLog(@"extraBalls = %d", extraBalls);
}

- (void)reachabilityChanged:(NSNotification *)note
{
    [self reachabilityStatus];
}

- (void)reachabilityStatus
{
    NSLog(@"reachabilityStatus:");
    
    NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            NSLog(@"Net not reachable");
            break;
            
        case ReachableViaWWAN:
            NSLog(@"Net reachable via WWAN");
            break;
            
        case ReachableViaWiFi:
            NSLog(@"Net reachable via WiFi");
            break;
    }
    
    NetworkStatus hostStatus = [hostReachability currentReachabilityStatus];
    switch (hostStatus) {
        case NotReachable:
            NSLog(@"Host not reachable");
            break;
            
        case ReachableViaWWAN:
            NSLog(@"Host reachable via WWAN");
            break;
            
        case ReachableViaWiFi:
            NSLog(@"Host reachable via WiFi");
            break;
    }
}

@end
