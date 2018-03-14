//
//  HelpLayer.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 26/04/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "HelpLayer.h"

#define TOTAL_PAGES 2

@implementation HelpLayer

@synthesize myDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        arrScreens = [[NSMutableArray alloc] init];
        currentPage = 0;
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    NSLog(@"HelpLayer");
    
    CCSprite *bg = [CCSprite spriteWithFile:@"help.png"];
    bg.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    [self addChild:bg z:1];
    
    CCMenuItem *right = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"help_arrow_right_o.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"help_arrow_right_n.png"] target:self selector:@selector(showNext)];
    CCMenuItem *left = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"help_arrow_left_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"help_arrow_left_o.png"] target:self selector:@selector(showPre)];
    
    rightMenu = [CCMenu menuWithItems:right, nil];
    rightMenu.opacity = 100;
    rightMenu.enabled = NO;
    [self addChild:rightMenu z:2];
    
    leftMenu = [CCMenu menuWithItems:left, nil];
    leftMenu.opacity = 100;
    leftMenu.enabled = NO;
    [self addChild:leftMenu z:2];
    
    CCMenuItem *close = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"help_close_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"help_close_o.png"] target:self selector:@selector(closeSelected)];
    
    CCMenu *closeMenu = [CCMenu menuWithItems:close, nil];
    [self addChild:closeMenu z:2];
    
    rightMenu.position = ccp(662, 510);
    leftMenu.position = ccp(106, 510);
    closeMenu.position = ccp(657, 912);
    
    if (!IT_IS_iPad) {
        rightMenu.position = [globals uniPoint:rightMenu.position withXGap:-20 withYGap:0];
        leftMenu.position = [globals uniPoint:leftMenu.position withXGap:20 withYGap:0];
        closeMenu.position = [globals uniPoint:closeMenu.position withXGap:-20 withYGap:-25];
    }
    
    if (TOTAL_PAGES > 1) {
        rightMenu.enabled = YES;
        [rightMenu runAction:[CCFadeIn actionWithDuration:0.2]];
    }
    
    helpScreen1 = [CCSprite spriteWithFile:@"helpscreen1.png"];
    helpScreen1.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - YSCALE(100));
    helpScreen1.opacity = 0;
    [arrScreens addObject:helpScreen1];
    
    helpScreen2 = [CCSprite spriteWithFile:@"helpscreen2.png"];
    helpScreen2.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - YSCALE(100));
    helpScreen2.opacity = 0;
    [arrScreens addObject:helpScreen2];
    
    dotMenu = [CCMenu node];
    dotMenu.position = ccp(396, 80);
    
    if (!IT_IS_iPad) {
        dotMenu.position = [globals uniPoint:dotMenu.position withXGap:0 withYGap:35];
    }
    
    for (int i = 0; i < TOTAL_PAGES; i++) {
        CCMenuItem *itemN = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"help_dot_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"help_dot_n.png"] target:self selector:nil];
        CCMenuItem *itemO = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"help_dot_o.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"help_dot_o.png"] target:self selector:nil];
        
        CCMenuItemToggle *toggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(dotSelected) items:itemN, itemO, nil];
        
        [dotMenu addChild:toggle];
    }
    
    [dotMenu alignItemsHorizontallyWithPadding:YSCALE(20)];
    [self addChild:dotMenu z:2];
    
    CCMenuItemToggle *toggle = [[dotMenu children] objectAtIndex:0];
    toggle.selectedIndex = 1;
    
    currentPage = 1;
    
    [self loadScreen];
}

- (void)dotSelected
{
}

- (void)loadScreen
{
    currentScreen = [arrScreens objectAtIndex:currentPage - 1];
    [self addChild:currentScreen z:3];
    
    [currentScreen runAction:[CCFadeIn actionWithDuration:1.0]];
}

- (void)showNext
{
    [globals playClick];
    
    if (currentPage < TOTAL_PAGES) {
        [currentScreen runAction:[CCFadeOut actionWithDuration:1.0]];
        [currentScreen removeFromParentAndCleanup:YES];
        currentScreen = nil;
        
        currentPage++;
        
        [self loadScreen];
        
        if (!leftMenu.enabled) {
            leftMenu.enabled = YES;
            [leftMenu runAction:[CCFadeIn actionWithDuration:0.2]];
        }
        
        if (currentPage == TOTAL_PAGES) {
            rightMenu.enabled = NO;
            rightMenu.opacity = 100;
        }
    }
}

- (void)showPre
{
    [globals playClick];
    
    if (currentPage > 1) {
        [currentScreen runAction:[CCFadeOut actionWithDuration:1.0]];
        [currentScreen removeFromParentAndCleanup:YES];
        currentScreen = nil;
        
        currentPage--;
        
        [self loadScreen];
        
        if (!rightMenu.enabled) {
            rightMenu.enabled = YES;
            [rightMenu runAction:[CCFadeIn actionWithDuration:0.2]];
        }
        
        if (currentPage == 1) {
            leftMenu.enabled = NO;
            leftMenu.opacity = 100;
        }
    }
}

- (void)closeSelected
{
    [globals playClick];
    
    [self runAction:[CCFadeOut actionWithDuration:0.5]];
    [[self myDelegate] closeHelpLayer];
}

@end
