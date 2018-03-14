//
//  PadLayer.m
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 18/02/14.
//  Copyright 2014 Niloo Games. All rights reserved.
//

#import "PadLayer.h"
#import "CCShake.h"

@implementation PadLayer

@synthesize chipmunkObjects;
@synthesize sprite;
@synthesize padScale;

- (id)init
{
    self = [super init];
    if (self) {
        padScale = 1.1;

        globals = [GameGlobals sharedGlobal];
        chipmunkObjects = [[NSMutableSet alloc] init];
		cpFloat mass = INFINITY;
        
        sprite = [CCPhysicsSprite spriteWithSpriteFrameName:@"pad.png"];
        sprite.scaleX = padScale;
        
		body = [ChipmunkBody bodyWithMass:mass andMoment:cpMomentForBox(mass, sprite.contentSize.width + XSCALE(15), sprite.contentSize.height + YSCALE(25))];
		body.data = self;
		
        shape = [ChipmunkPolyShape boxWithBody:body width:(sprite.contentSize.width * padScale) + XSCALE(15) height:sprite.contentSize.height + YSCALE(25)];
        shape.friction = 1.0;
        shape.elasticity = 0.5;
        shape.data = self;
        shape.collisionType = @"MyPad";
        
        sprite.chipmunkBody = body;
        sprite.position = ccp(body.pos.x, body.pos.y);
        [self addChild:sprite z:0];
        
        [chipmunkObjects addObject:body];
        [chipmunkObjects addObject:shape];
        
    }
    return self;
}

- (void)myScale:(float)scale
{
    padScale = scale;
    sprite.scaleX = padScale;
    
    [chipmunkObjects removeObject:shape];
    
    shape = [ChipmunkPolyShape boxWithBody:body width:(sprite.contentSize.width * padScale) + XSCALE(15) height:sprite.contentSize.height + YSCALE(25)];
    shape.friction = 1.0;
    shape.elasticity = 0.5;
    shape.data = self;
    shape.collisionType = @"MyPad";
    
    [chipmunkObjects addObject:shape];
}

- (void)shake
{
    [sprite runAction:[CCShake actionWithDuration:0.3 amplitude:ccp(XSCALE(15),YSCALE(15)) dampening:NO shakes:6]];
}

- (void)reset
{
    sprite.position = ccp(SCREEN_WIDTH / 2, globals.myPadHeight);
}

- (void)moveTo:(CGPoint)location
{
    int halfSprite = sprite.contentSize.width / 2;
    
    if (location.x + halfSprite > globals.screenSize.width) {
        sprite.position = ccp(globals.screenSize.width - halfSprite, sprite.position.y);
    }
    else if (location.x > halfSprite) {
        sprite.position = ccp(location.x, sprite.position.y);
    }
    else {
        sprite.position = ccp(halfSprite, sprite.position.y);
    }
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    
    if (location.y <= sprite.position.y + YSCALE(200)) {
        [self moveTo:location];
        
        return YES;
    }
    else {
        return NO;
    }
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    
    [self moveTo:location];
}

@end
