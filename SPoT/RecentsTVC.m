//
//  RecentsTVC.m
//  SPoT
//
//  Created by Owen Medd on 3/13/13.
//  Copyright (c) 2013 InterGuide Communications, Inc. All rights reserved.
//

#import "FlickrFetcher.h"
#import "RecentsTVC.h"
#import "SPoTPhotoDB.h"

@interface RecentsTVC ()

@end

@implementation RecentsTVC

- (BOOL)sortPhotos
{
    return NO;
}

- (NSString *)reuseID
{
    return @"RecentsCell";
}

- (NSString *)segueID
{
    return @"ShowRecent";
}

- (BOOL)registerSelectionInRecents
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setPhotos:[[SPoTPhotoDB class] recentPhotos]];
}

@end
