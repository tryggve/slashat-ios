//
//  SlashatArchiveTableViewController.m
//  Slashat
//
//  Created by Johan Larsson on 2013-01-03.
//  Copyright (c) 2013 Johan Larsson. All rights reserved.
//

#import "SlashatArchiveTableViewController.h"
#import "SlashatEpisode.h"
#import "SlashatAPIManager.h"
#import "SlashatArchiveEpisodeViewController.h"
#import "SlashatApplication.h"

@interface SlashatArchiveTableViewController ()

@end

@implementation SlashatArchiveTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        (void)[self.tabBarItem initWithTitle:@"Avsnitt" image:[UIImage imageNamed:@"tab-bar_archive_inactive.png"] selectedImage:[UIImage imageNamed:@"tab-bar_archive_active.png"]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl.tintColor = [UIColor slashatOrange];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

    self.allEntries = [NSMutableArray array];
    [self refresh];
}

- (void) refresh {
    
    [[SlashatAPIManager sharedClient] fetchArchiveEpisodesWithSuccess:^(NSArray *episodes) {
        self.allEntries = [[NSMutableArray alloc] initWithArray:episodes];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"SlashatArchiveTableViewController: refresh: Error: %@", error);
    }];
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
    // Return the number of rows in the section.
    return self.allEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SlashatArchiveTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    SlashatEpisode *episode = [self.allEntries objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"#%i - %@", episode.episodeNumber, episode.title];
    cell.detailTextLabel.text = episode.itemDescription;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];    
    SlashatArchiveEpisodeViewController *episodeViewController = segue.destinationViewController;
    [episodeViewController setEpisode:[self.allEntries objectAtIndex:indexPath.row]];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Subscribe button
- (IBAction) subscribeButtonPressed:(id)sender
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"podcast://"]]) {
        NSURL *podcastUrl = [NSURL URLWithString:@"podcast://slashat.se/avsnitt.rss"];
        [((SlashatApplication *)[UIApplication sharedApplication]) openCustomURL:podcastUrl];
    } else {
        NSURL *itunesUrl = [NSURL URLWithString:@"http://slashat.se/avsnitt.rss"];
        [((SlashatApplication *)[UIApplication sharedApplication]) openCustomURL:itunesUrl];
    }
}


@end
