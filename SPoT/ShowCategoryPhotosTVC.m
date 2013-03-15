//
//  ShowCategoryPhotosTVC.m
//  SPoT
//
//  Created by Owen Medd on 3/13/13.
//  Copyright (c) 2013 InterGuide Communications, Inc. All rights reserved.
//

#import "ShowCategoryPhotosTVC.h"

@interface ShowCategoryPhotosTVC ()

@end

@implementation ShowCategoryPhotosTVC

- (NSString *)reuseID
{
    return @"PhotoCell";
}

- (NSString *)segueID
{
    return @"ShowPhoto";
}

- (BOOL)registerSelectionInRecents
{
    return YES;
}

@end
