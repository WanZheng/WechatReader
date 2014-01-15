//
//  RDRIndexViewController.m
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import "RDRIndexViewController.h"
#import "RDRContentViewController.h"
#import "UIImageView+RDRAsyncDownload.h"

static int TAG_TITLE = 1;
static int TAG_SUBTITLE = 2;
static int TAG_IMG = 3;

@interface RDRIndexViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation RDRIndexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)viewWillAppear:(BOOL)animated {
#ifndef CONFIG_APP_NAME
#   define CONFIG_APP_NAME (@"WebView测试")
#endif
    self.title = CONFIG_APP_NAME;

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:(NSUInteger)section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RDRArticle *article = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UILabel *title = (UILabel *) [cell.contentView viewWithTag:TAG_TITLE];
    if (article.title.length > 0) {
        title.hidden = NO;
        title.text = article.title;
    }else{
        title.hidden = YES;
    }

    NSString *author = @"author";
    UILabel *subtitle = (UILabel *) [cell.contentView viewWithTag:TAG_SUBTITLE];
    if (author.length > 0) {
        subtitle.hidden = NO;
        subtitle.text = author;
    }else{
        subtitle.hidden = YES;
    }


    UIImageView *imgView = (UIImageView *) [cell.contentView viewWithTag:TAG_IMG];
    if (article.imageUrl.length > 0) {
        imgView.hidden = NO;
        [imgView setImageWithURL:[[NSURL alloc] initWithString:article.imageUrl]];
    }else{
        // TODO: 如果没有照片，需拉长title
        imgView.hidden = YES;
        imgView.image = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 220, 15)];
        title.tag = TAG_TITLE;
        title.font = [UIFont systemFontOfSize:14.0];
        title.textColor = [UIColor blackColor];
        title.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [cell.contentView addSubview:title];

        UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 205, 25)];
        subtitle.tag = TAG_SUBTITLE;
        subtitle.font = [UIFont systemFontOfSize:12.0];
        subtitle.textColor = [UIColor darkGrayColor];
        subtitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [cell.contentView addSubview:subtitle];

        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(240, 0, 80, 45)];
        img.tag = TAG_IMG;
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        img.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:img];
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RDRArticle *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    RDRContentViewController *contentViewController = [[RDRContentViewController alloc] init];
    contentViewController.article = article;
    
    self.title = @"返回";
    [self.navigationController pushViewController:contentViewController animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object.
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];

        NSError *error;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.

             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - core data
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *ctimeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ctime" ascending:NO];
    NSArray *sortDescriptors = @[ctimeDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:@"articles"];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
