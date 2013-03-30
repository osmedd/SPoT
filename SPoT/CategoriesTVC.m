//
//  CategoriesTVC.m
//  SPoT
//
//  Created by Owen Medd on 3/10/13.
//  Copyright (c) 2013 InterGuide Communications, Inc. All rights reserved.
//

#import "CategoriesTVC.h"
#import "SPoTPhotoDB.h"

@interface CategoriesTVC ()

@property (strong, nonatomic) SPoTPhotoDB *photoDB;
@property (strong, nonatomic) NSArray *categories;

@end

@implementation CategoriesTVC

- (SPoTPhotoDB *)photoDB
{
    if (_photoDB == nil) _photoDB = [[SPoTPhotoDB alloc] init];
    return _photoDB;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.photoDB loadStanfordPhotos];
    self.categories = [[self.photoDB.categories allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photoDB.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self.categories[indexPath.item] capitalizedString];
    NSUInteger photoCount = [self.photoDB.categories[self.categories[indexPath.item]] count];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", photoCount];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"ShowCategoryPhotos"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    NSMutableArray *categoryPhotos = [[NSMutableArray alloc] init];
                    NSString *category = self.categories[indexPath.item];
                    for (int i = 0; i < [self.photoDB.categories[category] count]; i++) {
                        int photoIdx = [self.photoDB.categories[category][i] intValue];
                        [categoryPhotos addObject:[self.photoDB getPhotoData:photoIdx]];
                    }
                    [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:categoryPhotos];
                    [segue.destinationViewController setTitle:[self.categories[indexPath.item] capitalizedString]];
                }
            }
        }
    }
}

@end
