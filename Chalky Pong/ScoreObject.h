//
//  ScoreObject.h
//  Chalky Pong
//
//  Created by Hadi Boojiyarnezhad on 21/04/14.
//  Copyright (c) 2014 Niloo Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScoreObject : NSObject <NSCoding> {
    int score;
    
    NSDate *date;
}

@property int score;
@property (nonatomic, strong) NSDate *date;

@end
