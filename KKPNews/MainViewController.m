//
//  MainViewController.m
//  KKPNews
//
//  Created by Siam System Deverlopment on 6/13/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import "MainViewController.h"
#import "YoutubeListCustomCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MainViewController ()

@end

@implementation MainViewController
{
    BOOL receivedVideo;
    NSInteger item;
}
@synthesize youtube;

- (void)viewDidLoad {
    [super viewDidLoad];
    //testing UI
    receivedVideo = NO;
    [self.navigationController setNavigationBarHidden:YES];
    self.playerView.delegate = self;
    item = 0;

    self.youtubeTableView.delegate = self;
    self.youtubeTableView.dataSource = self;
    //self.youtube = [[Youtube alloc] init];
    //[self makeYoutubeData];
    NSLog(@"Youtube count %lu",(unsigned long)[self.youtube.titleList count]);
    [self playlingYoutube];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
- (void)playlingYoutube
{
    self.playerVars =  @{ @"playsinline" : @1,
                          @"controls" : @0,
                          @"showinfo" : @1,
                          @"modestbranding" : @0,
                          @"origin" :@"http://www.youtube.com"   };
    
    [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
}



#pragma YTPlayerView delegate
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
     [self.playerView playVideo];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    if (state == kYTPlayerStateEnded) {
        item+=1;
        [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
        [self.youtubeTableView reloadData];
    } else if (state == kYTPlayerStatePlaying) {
        NSLog(@"--check time %@", [self stringFromTimeInterval:[self.playerView duration]]);
        NSLog(@"--time from obj %@",[self.youtube.durationList objectAtIndex:item]);
    }
}

# pragma table delegate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.youtube.data count] != 0) {
        return [self.youtube.data count];
    }else{
        return 5;
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"YoutubeListCustomCell";
    YoutubeListCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YoutubeListCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    if ([self.youtube.data count] != 0) {
        
        cell.name.text = [[self.youtube.data objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.tag = indexPath.row;
        NSString *duration = [self.youtube.durationList objectAtIndex:indexPath.row];
        cell.duration.text = [self durationText:duration];
        cell.thumnail.image = nil;
        
        if([[self.youtube.data objectAtIndex:indexPath.row] objectForKey:@"thumbnail"] != [NSNull null] ){
            [cell.thumnail sd_setImageWithURL:[NSURL URLWithString:[[self.youtube.data objectAtIndex:indexPath.row] objectForKey:@"thumbnail"]]
                                   placeholderImage:nil];
        }

    } else {
        cell.name.text = @"";
    }
    
    if (indexPath.row == item) {
        cell.contentView.backgroundColor = UIColorFromRGB(0xFFCCCC);
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }

    return cell;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    if (hours > 0) {
        
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
}
- (NSString *)durationText:(NSString *)duration
{
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    duration = [duration substringFromIndex:[duration rangeOfString:@"T"].location];
    
    while ([duration length] > 1) { //only one letter remains after parsing
        duration = [duration substringFromIndex:1];
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:duration];
        
        NSString *durationPart = [[NSString alloc] init];
        [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] intoString:&durationPart];
        
        NSRange rangeOfDurationPart = [duration rangeOfString:durationPart];
        
        duration = [duration substringFromIndex:rangeOfDurationPart.location + rangeOfDurationPart.length];
        
        if ([[duration substringToIndex:1] isEqualToString:@"H"]) {
            hours = [durationPart intValue];
            
        }
        if ([[duration substringToIndex:1] isEqualToString:@"M"]) {
            minutes = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"S"]) {
            seconds = [durationPart intValue];
        }
    }
    if (hours != 0) {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 89;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.playerView pauseVideo];
    item = indexPath.row;
    [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
    [self.youtubeTableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.youtubeTableView reloadData];
}

@end
