//
//  PointSprite.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 22/07/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "PointsSprite.h"

@implementation PointsSprite

- (id)initWithPoints:(int)points
{
    self = [super init];
    if (self) {
        globals = [GameGlobals sharedGlobal];
        
        pointsSprite = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%d", points] fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(36)];
        shadowSprite = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%d", points] fontName:@"DK Crayon Crumble.ttf" fontSize:FONTSCALE(36)];
        
        shadowSprite.position = ccp(2, -2);
        shadowSprite.color = ccc3(0, 0, 0);
        [self addChild:shadowSprite z:0];
        
        pointsSprite.position = ccp(0, 0);
        pointsSprite.color = ccc3(252, 252, 50);
        [self addChild:pointsSprite z:1];
        
        [pointsSprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.5 scale:0.7], [CCScaleTo actionWithDuration:0.5 scale:1.2], nil]]];
        [shadowSprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.5 scale:0.7], [CCScaleTo actionWithDuration:0.5 scale:1.2], nil]]];
    }
    
    return self;
}

- (void)go
{
    [self scheduleOnce:@selector(removeMe) delay:2];
    
    [pointsSprite runAction:[CCFadeOut actionWithDuration:1.5]];
    [shadowSprite runAction:[CCFadeOut actionWithDuration:1.5]];
}

- (void)removeMe
{
    [self stopAllActions];
    [self removeFromParentAndCleanup:YES];
}

@end
