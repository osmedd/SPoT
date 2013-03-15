//
//  SPoTPhotoDB.h
//  SPoT
//
//  Created by Owen Medd on 3/12/13.
//  Copyright (c) 2013 InterGuide Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPoTPhotoDB : NSObject

@property (readonly, nonatomic) NSDictionary *categories;

- (void)loadStanfordPhotos;
- (NSDictionary *)getPhotoData:(int)photoIdx;
+ (void)registerRecentPhoto:(NSDictionary *)photo;
+ (NSArray *)recentPhotos;

@end
