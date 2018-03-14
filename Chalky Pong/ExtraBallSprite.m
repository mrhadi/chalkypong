//
//  ExtraBallSprite.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 7/08/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "ExtraBallSprite.h"


@implementation ExtraBallSprite

- (id)init {
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        menuItems = [[NSMutableArray alloc] init];
        products = [[NSMutableArray alloc] init];
        itemRestored = NO;
        
        CCSprite *backgroundImage = [CCSprite spriteWithSpriteFrameName:@"buy_panel.png"];
        backgroundImage.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - YSCALE(100));
        [self addChild:backgroundImage];
        
        myWidth = [backgroundImage boundingBox].size.width;
        myHeight = [backgroundImage boundingBox].size.height;
        
        CCMenuItem *btClose = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"close_o.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"close_n.png"] target:self selector:@selector(doClose)];
        CCMenu *close = [CCMenu menuWithItems:btClose, nil];
        close.position = ccp(iPadPhone5(590, 265, 265), iPadPhone5(589, 280, 325));
        [self addChild:close];
        
        messageShadow = [CCLabelTTF labelWithString:@"" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(34)];
        messageShadow.position = ccp(backgroundImage.contentSize.width / 2, YSCALE(140));
        messageShadow.color = ccGRAY;
        [backgroundImage addChild:messageShadow];
        
        message = [CCLabelTTF labelWithString:@"" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(34)];
        message.position = ccp(backgroundImage.contentSize.width / 2 - 2, YSCALE(140) + 2);
        message.color = ccBLACK;
        [backgroundImage addChild:message];
        
        header = [CCLabelTTF labelWithString:@"Buy More Balls" fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(44)];
        header.position = ccp(backgroundImage.contentSize.width / 2, backgroundImage.contentSize.height - YSCALE(90));
        header.color = ccBLACK;
        [backgroundImage addChild:header];
        
        rowPos = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - YSCALE(100));
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotTransactionState:) name:@"TransactionState" object:nil];
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    if (globals.inAppProducts.count > 0) {
        [self showProducts];
    }
    else {
        [self showMessage:@"Can't connect to iTunes Store!"];
    }
}

- (void)doClose
{
    [globals playClick];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnableMenus" object:nil];
    
    [menuItems removeAllObjects];
    
    [self removeFromParentAndCleanup:YES];
}

- (void)doBuy:(CCMenuItem *)item
{
    [globals playClick];
    
    if (item.tag > 0) {
        item.isEnabled = NO;
        
        [self showLoading];
        
        SKProduct *product = [globals.inAppProducts objectAtIndex:item.tag - 1];

        SKPayment *payment = [SKPayment paymentWithProduct:product];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)doRestore:(CCMenuItem *)item
{
    [globals restorePurchases];
    
    [self showLoading];
}

- (void)showProducts
{
    int productId = 0;
    
    [products removeAllObjects];
    
    for (SKProduct *product in globals.inAppProducts) {
        if ([product.productIdentifier isEqualToString:TWO_BALLS_Pack1]) {
            productId++;
            
            CCSprite *twoBallsRow = [CCSprite spriteWithSpriteFrameName:@"buy_2balls.png"];
            twoBallsRow.position = rowPos;
            [self addChild:twoBallsRow];
            [products addObject:twoBallsRow];
            
            if ([globals.inAppPurchase containsObject:product.productIdentifier] && itemRestored) {
                 CCSprite *tick = [CCSprite spriteWithSpriteFrameName:@"buy_tick.png"];
                 tick.position = ccp(iPadPhone5(535, 235, 235), iPadPhone5(464, 218, 262));
                 [self addChild:tick];
                 [products addObject:tick];
                 
                 [self showMessage:@"Your previous purchases restored"];
            }
            else if ([globals.inAppPurchase containsObject:product.productIdentifier]) {
                CCMenuItem *btRestore = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"buy_res_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"buy_res_o.png"] target:self selector:@selector(doRestore:)];
                btRestore.tag = productId;
                
                [menuItems addObject:btRestore];
                
                CCMenu *restore = [CCMenu menuWithItems:btRestore, nil];
                restore.position = ccp(iPadPhone5(535, 235, 235), iPadPhone5(464, 218, 262));
                [self addChild:restore];
                [products addObject:restore];
                
                [header setString:@"Restore Purchases"];
            }
            else {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [numberFormatter setLocale:product.priceLocale];
                NSString *formattedString = [numberFormatter stringFromNumber:product.price];
                
                CCLabelTTF *price = [CCLabelTTF labelWithString:formattedString fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(40)];
                price.position = rowPos;
                price.color = ccBLACK;
                [self addChild:price];
                [products addObject:price];
                
                CCMenuItem *btBuy = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"buy_bt_n.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"buy_bt_o.png"] target:self selector:@selector(doBuy:)];
                btBuy.tag = productId;
                
                [menuItems addObject:btBuy];
                
                CCMenu *buy = [CCMenu menuWithItems:btBuy, nil];
                buy.position = ccp(iPadPhone5(535, 235, 235), iPadPhone5(464, 218, 262));
                [self addChild:buy];
                [products addObject:buy];
            }
        }
    }
}

- (void)showLoading
{
    loadingSprite = [CCSprite spriteWithSpriteFrameName:@"buy_loading_bg.png"];
    loadingSprite.position = rowPos;
    loadingSprite.opacity = 230;
    [self addChild:loadingSprite];
    
    CCSprite *loading = [CCSprite spriteWithSpriteFrameName:@"buy_loading.png"];
    loading.position = ccp(loadingSprite.contentSize.width / 2, loadingSprite.contentSize.height / 2);
    [loadingSprite addChild:loading];
    
    CCSprite *ball = [CCSprite spriteWithSpriteFrameName:@"buy_loading_ball.png"];
    ball.position = ccp(iPadPhone5(108, 55, 55), iPadPhone5(80, 40, 40));
    [loadingSprite addChild:ball];
    
    [ball runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle: 360]]];
}

- (void)hideLoading
{
    [loadingSprite removeFromParentAndCleanup:YES];
    
    for (CCMenuItem *item in menuItems) {
        item.isEnabled = YES;
    }
}

- (void)showMessage:(NSString *)msg
{
    [messageShadow setString:msg];
    [message setString:msg];
    
    [self flashMessage];
}

- (void)gotTransactionState:(NSNotification *)notification
{
    SKPaymentTransaction *transaction = [[notification userInfo] valueForKey:@"transaction"];
    
    switch (transaction.transactionState) {
        case SKPaymentTransactionStatePurchased:
            for (CCNode *node in products) {
                [self removeChild:node cleanup:YES];
            }
            
            itemRestored = YES;
            
            [self showProducts];
            [self showMessage:@"You got two more balls :)"];
            [self hideLoading];
            break;
            
        case SKPaymentTransactionStateFailed:
            [self showMessage:@"Can't connect to iTunes Store!"];
            [self hideLoading];
            
            break;
            
        case SKPaymentTransactionStatePurchasing:
            break;
            
        case SKPaymentTransactionStateRestored:
            itemRestored = YES;
            
            [self hideLoading];
            
            for (CCNode *node in products) {
                [self removeChild:node cleanup:YES];
            }
            
            [self showProducts];
            break;
            
        default:
            break;
    }
}

- (void)flashMessage
{
    [message runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.3], [CCFadeIn actionWithDuration:0.3], [CCFadeOut actionWithDuration:0.3], [CCFadeIn actionWithDuration:0.3], nil]];
    [messageShadow runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.3], [CCFadeIn actionWithDuration:0.3], [CCFadeOut actionWithDuration:0.3], [CCFadeIn actionWithDuration:0.3], nil]];
}

@end
