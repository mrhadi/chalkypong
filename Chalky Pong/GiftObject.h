//
//  GiftObject.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 19/07/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftObject : NSObject {
    int scoreValue;
    NSString *spriteName;
}

@property (readonly) int scoreValue;
@property (readonly, nonatomic, strong) NSString *spriteName;

- (id)initWithSprite:(NSString *)sprite withScore:(int)score;

@end
