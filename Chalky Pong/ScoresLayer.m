//
//  ScoresLayer.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 20/04/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "ScoresLayer.h"
#import "ScoreObject.h"
#import <GameKit/GameKit.h>

#define TABLE_ROWS  7
#define X_NAME      (IT_IS_iPad ? 125 : 50)
#define X_SCORE     (IT_IS_iPad ? 640 : 265)
#define X_DATE      (IT_IS_iPad ? 155 : 70)
#define X_DATE_YOU  (IT_IS_iPad ? 125 : 60)

@implementation ScoresLayer

@synthesize myDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        
        rowName = [[NSMutableArray alloc] init];
        rowDate = [[NSMutableArray alloc] init];
        rowScore = [[NSMutableArray alloc] init];
        
        scoreFormatter = [[NSNumberFormatter alloc] init];
        scoreFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"dd MMM, yyyy"];
        
        NSLog(@"Total scores count: %d", totalRows);
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    NSLog(@"ScoresLayer");

    CCSprite *fade = [CCSprite spriteWithFile:@"blackbg.png"];
    fade.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    fade.opacity = 150;
    [self addChild:fade z:0];
    
    CCSprite *bg = [CCSprite spriteWithFile:@"scoresbg.png"];
    bg.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    [self addChild:bg z:1];
    
    CCMenuItem *youActive = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"you_a.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"you_a.png"] target:self selector:nil];
    CCMenuItem *youInactive = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"you_i.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"you_i.png"] target:self selector:nil];
     
    CCMenuItem *othersActive = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"others_a.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"others_a.png"] target:self selector:nil];
    CCMenuItem *othersInactive = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"others_i.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"others_i.png"] target:self selector:nil];
     
    youToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(youSelected) items:youActive, youInactive, nil];
    othersToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(othersSelected) items:othersActive, othersInactive, nil];
    othersToggle.selectedIndex = 1;
    
    scoresMenu = [CCMenu menuWithItems:youToggle, othersToggle, nil];
    [scoresMenu alignItemsHorizontallyWithPadding:-2];
    
    [self addChild:scoresMenu z:1];
    
    youTable = [CCSprite spriteWithFile:@"scores-youtable.png"];
    youTable.opacity = 255;
    [self addChild:youTable z:2];
    
    othersTable = [CCSprite spriteWithFile:@"scores-otherstable.png"];
    othersTable.opacity = 0;
    [self addChild:othersTable z:2];
    
    CCMenuItem *right = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"arrow_right_o.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"arrow_right_n.png"] target:self selector:@selector(showNext)];
    CCMenuItem *left = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"arrow_left_o.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"arrow_left_n.png"] target:self selector:@selector(showPre)];
    
    rightMenu = [CCMenu menuWithItems:right, nil];
    rightMenu.opacity = 100;
    rightMenu.enabled = NO;
    [self addChild:rightMenu z:2];
    
    leftMenu = [CCMenu menuWithItems:left, nil];
    leftMenu.opacity = 100;
    leftMenu.enabled = NO;
    [self addChild:leftMenu z:2];
    
    CCMenuItem *close = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"scores_close_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"scores_close_o.png"] target:self selector:@selector(closeSelected)];
    
    CCMenu *closeMenu = [CCMenu menuWithItems:close, nil];
    [self addChild:closeMenu z:2];
    
    scoresMenu.position = ccp(385, 767);
    youTable.position = ccp(768 / 2, 438);
    othersTable.position = ccp(768 / 2, 438);
    rightMenu.position = ccp(447, 96);
    leftMenu.position = ccp(333, 96);
    closeMenu.position = ccp(660, 860);
    
    if (!IT_IS_iPad) {
        scoresMenu.position = [globals uniPoint:scoresMenu.position withXGap:0 withYGap:0];
        youTable.position = [globals uniPoint:youTable.position withXGap:0 withYGap:0];
        othersTable.position = [globals uniPoint:othersTable.position withXGap:0 withYGap:0];
        rightMenu.position = [globals uniPoint:rightMenu.position withXGap:0 withYGap:0];
        leftMenu.position = [globals uniPoint:leftMenu.position withXGap:0 withYGap:0];
        closeMenu.position = [globals uniPoint:closeMenu.position withXGap:0 withYGap:0];
    }
    
    [self youSelected];
    [self getGameCenterData];
}

- (void)buildYouLabels
{
    int x = 180;
    int y = 700;
    
    if (!IT_IS_iPad) {
        x = [globals uniX:x];
        y = [globals uniY:y];
    }
    
    [rowName removeAllObjects];
    [rowDate removeAllObjects];
    [rowScore removeAllObjects];
    
    for (int i = 1; i <= TABLE_ROWS; i++) {
        CCLabelTTF *labelDate = [CCLabelTTF labelWithString:@"" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(30)];
        labelDate.position = ccp(X_DATE_YOU, y - YSCALE(13 * 2));
        labelDate.horizontalAlignment = kCCTextAlignmentLeft;
        labelDate.color = ccc3(40, 40, 40);
        [rowDate addObject:labelDate];
        [self addChild:labelDate z:3];
        
        CCLabelTTF *labelScore = [CCLabelTTF labelWithString:@"" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(44)];
        labelScore.position = ccp(X_SCORE, y - YSCALE(15 * 2));
        labelScore.horizontalAlignment = kCCTextAlignmentRight;
        labelScore.color = ccc3(59, 59, 59);
        [rowScore addObject:labelScore];
        [self addChild:labelScore z:3];
        
        if (IT_IS_iPad) {
            y -= 85;
        }
        else {
            y -= 35;
        }
    }
}

- (void)buildOthersLabels
{
    int x = 180;
    int y = 700;
    
    if (!IT_IS_iPad) {
        x = [globals uniX:x];
        y = [globals uniY:y];
    }
    
    [rowName removeAllObjects];
    [rowDate removeAllObjects];
    [rowScore removeAllObjects];
    
    for (int i = 1; i <= TABLE_ROWS; i++) {
        CCLabelTTF *labelName = [CCLabelTTF labelWithString:@"" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(40)];
        labelName.position = ccp(X_NAME, y);
        labelName.horizontalAlignment = kCCTextAlignmentLeft;
        labelName.color = ccc3(59, 59, 59);
        [rowName addObject:labelName];
        [self addChild:labelName z:3];
        
        CCLabelTTF *labelDate = [CCLabelTTF labelWithString:@"" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(22)];
        labelDate.position = ccp(X_DATE, y - YSCALE(28 * 2));
        labelDate.horizontalAlignment = kCCTextAlignmentLeft;
        labelDate.color = ccc3(40, 40, 40);
        [rowDate addObject:labelDate];
        [self addChild:labelDate z:3];
        
        CCLabelTTF *labelScore = [CCLabelTTF labelWithString:@"" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(44)];
        labelScore.position = ccp(X_SCORE, y - YSCALE(15 * 2));
        labelScore.horizontalAlignment = kCCTextAlignmentRight;
        labelScore.color = ccc3(59, 59, 59);
        [rowScore addObject:labelScore];
        [self addChild:labelScore z:3];
        
        if (IT_IS_iPad) {
            y -= 85;
        }
        else {
            y -= 35;
        }
    }
}

- (void)clearData
{
    for (CCLabelTTF *label in rowName) {
        label.string = [NSString stringWithFormat:@""];
        [label runAction:[CCFadeOut actionWithDuration:0.2]];
    }
    
    for (CCLabelTTF *label in rowDate) {
        label.string = [NSString stringWithFormat:@""];
        [label runAction:[CCFadeOut actionWithDuration:0.2]];
    }
    
    for (CCLabelTTF *label in rowScore) {
        label.string = [NSString stringWithFormat:@""];
        [label runAction:[CCFadeOut actionWithDuration:0.2]];
    }
}

- (void)fillData
{
    int index = (currentPage - 1) * TABLE_ROWS;
    int lastRow = ((index + TABLE_ROWS) > totalRows) ? (totalRows - index) : (TABLE_ROWS);
    
    @try {
        for (int i = 0; i < lastRow ; i++) {
            if (selectedTab == 1) {
                ScoreObject *score = [globals.scoreHistory objectAtIndex:index + i];
                
                if (rowName.count > 0) {
                    CCLabelTTF *labelName = [rowName objectAtIndex:i];
                    labelName.string = [NSString stringWithFormat:@"%d. ", index + i + 1];
                    labelName.position = ccp(X_NAME + labelName.contentSize.width / 2, labelName.position.y);
                    [labelName runAction:[CCFadeIn actionWithDuration:0.8]];
                }
                
                if (rowDate.count > 0) {
                    CCLabelTTF *labelDate = [rowDate objectAtIndex:i];
                    if ([score.date isKindOfClass:[NSDate class]]) {
                        labelDate.string = [dateFormater stringFromDate:score.date];
                        labelDate.position = ccp(X_DATE_YOU + labelDate.contentSize.width / 2, labelDate.position.y);
                        [labelDate runAction:[CCFadeIn actionWithDuration:0.8]];
                    }
                }
                
                if (rowScore.count > 0) {
                    CCLabelTTF *labelScore = [rowScore objectAtIndex:i];
                    labelScore.string = [scoreFormatter stringFromNumber:[NSNumber numberWithInt:score.score]];
                    labelScore.position = ccp(X_SCORE - labelScore.contentSize.width / 2, labelScore.position.y);
                    [labelScore runAction:[CCFadeIn actionWithDuration:0.8]];
                }
            }
            else if (selectedTab == 2) {
                GKPlayer *player = [globals.gameCenterPlayer objectAtIndex:index + i];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerID == %@", player.playerID];
                NSArray *filter = [globals.gameCenterScores filteredArrayUsingPredicate:predicate];
                
                if (filter.count > 0) {
                    GKScore *score = [filter objectAtIndex:0];
                    
                    if (rowName.count > 0) {
                        CCLabelTTF *labelName = [rowName objectAtIndex:i];
                        
                        NSString *displayName = player.displayName;
                        displayName = [displayName stringByReplacingOccurrencesOfString:@"“" withString:@""];
                        displayName = [displayName stringByReplacingOccurrencesOfString:@"”" withString:@""];
                        
                        labelName.string = [NSString stringWithFormat:@"%d.%@", index + i + 1, displayName];
                        labelName.position = ccp(X_NAME + labelName.contentSize.width / 2, labelName.position.y);
                        [labelName runAction:[CCFadeIn actionWithDuration:0.8]];
                    }
                    
                    if (rowDate.count > 0) {
                        CCLabelTTF *labelDate = [rowDate objectAtIndex:i];
                        if ([score.date isKindOfClass:[NSDate class]]) {
                            labelDate.string = [dateFormater stringFromDate:score.date];
                            labelDate.position = ccp(X_DATE + labelDate.contentSize.width / 2, labelDate.position.y);
                            [labelDate runAction:[CCFadeIn actionWithDuration:0.8]];
                        }
                    }
                    
                    if (rowScore.count > 0) {
                        CCLabelTTF *labelScore = [rowScore objectAtIndex:i];
                        labelScore.string = [scoreFormatter stringFromNumber:[NSNumber numberWithLongLong:score.value]];
                        labelScore.position = ccp(X_SCORE - labelScore.contentSize.width / 2, labelScore.position.y);
                        [labelScore runAction:[CCFadeIn actionWithDuration:0.8]];
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"***> %@", exception.name);
        NSLog(@"***>Reason: %@", exception.reason);
    }
    @finally {
    }
}

- (void)youSelected
{
    [globals playClick];
    
    [self clearData];
    [self buildYouLabels];
    
    totalRows = globals.scoreHistory.count;
    if (totalRows > 100) {
        totalRows = 100;
    }
    
    totalPages = totalRows / TABLE_ROWS;
    currentPage = 1;
    selectedTab = 1;
    
    if (totalPages == 0) {
        totalPages = 1;
    }
    else {
        int r = totalRows - (totalPages * TABLE_ROWS);
        
        if (r > 0) {
            totalPages++;
        }
    }
    
    rightMenu.opacity = 100;
    rightMenu.enabled = NO;
    leftMenu.opacity = 100;
    leftMenu.enabled = NO;
    
    if (totalPages > 1) {
        rightMenu.enabled = YES;
        [rightMenu runAction:[CCFadeIn actionWithDuration:0.2]];
    }
    
    [self fillData];
    
    youToggle.selectedIndex = 0;
    youTable.opacity = 255;
    
    othersToggle.selectedIndex = 1;
    othersTable.opacity = 0;
}

- (void)othersSelected
{
    [globals playClick];
    
    [self clearData];
    [self buildOthersLabels];
    
    totalRows = globals.gameCenterPlayer.count;
    totalPages = totalRows / TABLE_ROWS;
    currentPage = 1;
    selectedTab = 2;
    
    if (totalPages == 0) {
        totalPages = 1;
    }
    else {
        int r = totalRows - (totalPages * TABLE_ROWS);
        
        if (r > 0) {
            totalPages++;
        }
    }
    
    rightMenu.opacity = 100;
    rightMenu.enabled = NO;
    leftMenu.opacity = 100;
    leftMenu.enabled = NO;
    
    if (totalPages > 1) {
        rightMenu.enabled = YES;
        [rightMenu runAction:[CCFadeIn actionWithDuration:0.2]];
    }
    
    [self fillData];
    
    youToggle.selectedIndex = 1;
    youTable.opacity = 0;
    
    othersToggle.selectedIndex = 0;
    othersTable.opacity = 255;
}

- (void)closeSelected
{
    [globals playClick];
    
    [self runAction:[CCFadeOut actionWithDuration:0.5]];
    [[self myDelegate] closeScoresLayer];
}

- (void)showNext
{
    [globals playClick];
    
    if (currentPage < totalPages) {
        currentPage++;
        
        [self clearData];
        [self fillData];
        
        if (!leftMenu.enabled) {
            leftMenu.enabled = YES;
            [leftMenu runAction:[CCFadeIn actionWithDuration:0.2]];
        }
        
        if (currentPage == totalPages) {
            rightMenu.opacity = 100;
            rightMenu.enabled = NO;
        }
    }
}

- (void)showPre
{
    [globals playClick];
    
    if (currentPage > 1) {
        currentPage--;
        
        [self clearData];
        [self fillData];
        
        if (!rightMenu.enabled) {
            rightMenu.enabled = YES;
            [rightMenu runAction:[CCFadeIn actionWithDuration:0.2]];
        }
        
        if (currentPage == 1) {
            leftMenu.opacity = 100;
            leftMenu.enabled = NO;
        }
    }
}

- (void)getGameCenterData
{
    if ([[GameCenter sharedInstance] gameCenterAvailable]) {
        if ([[GameCenter sharedInstance] userAuthenticated]) {
            [GameCenter sharedInstance].myDelegate = self;
            
            [[GameCenter sharedInstance] retrieveTopScores];
        }
    }
}

- (void)gameCenterDataReady
{
    NSLog(@"gameCenterDataReady");
}

@end
