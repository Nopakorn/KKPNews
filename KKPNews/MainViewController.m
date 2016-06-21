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
    
    BOOL isSeekForward;
    BOOL isSeekBackward;
}
@synthesize youtube;

- (void)viewDidLoad {
    [super viewDidLoad];
    //testing UI
    receivedVideo = NO;
    [self.navigationController setNavigationBarHidden:YES];
    self.playerView.delegate = self;
    item = 0;
    
    self.youtubeTableView.dataSource = self;
    self.youtubeTableView.delegate = self;
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
    self.progressSlider.value = 0;
    self.currentTime.text = @"00:00";
    self.totalTime.text = @"00:00";
     [self.progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.playerView playVideo];
}


- (IBAction)sliderValueChanged:(UISlider *)sender
{
//    [self hideNavWithFact:NO];
//    [hideNavigation invalidate];
//    hideNavigation = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hideNavigation) userInfo:nil repeats:NO];
    NSInteger startTime = sender.value * self.playerTotalTime;
    [self.timerProgress invalidate];
    self.progressSlider.value = (double)startTime / self.playerTotalTime;
    
    double currentTimeChange = sender.value * self.playerTotalTime;
    NSTimeInterval currentTimeInterval = currentTimeChange;
    self.currentTime.text = [self stringFromTimeInterval:currentTimeInterval];
    
    [self.playerView seekToSeconds:currentTimeChange allowSeekAhead:YES];
}



- (void)makeProgressBarMoving:(NSTimer *)timer
{
    float total = [self.progressSlider value];
    double currentTime = [self.playerView currentTime];
    NSTimeInterval currentTimeInterval = currentTime;
    self.currentTime.text = [self stringFromTimeInterval:currentTimeInterval];
    
    if (isSeekForward) {
        if (total < 1) {
            float playerCurrentTime = [self.playerView currentTime];
            playerCurrentTime+=5;
            self.progressSlider.value = (playerCurrentTime / (float)self.playerTotalTime);
            [self.playerView seekToSeconds:playerCurrentTime allowSeekAhead:YES];
            
        } else {
            [self.timerProgress invalidate];
        }
        
    } else if (isSeekBackward){
        if (total < 1) {
            float playerCurrentTime = [self.playerView currentTime];
            playerCurrentTime-=5;
            self.progressSlider.value = (playerCurrentTime / (float)self.playerTotalTime);
            [self.playerView seekToSeconds:playerCurrentTime allowSeekAhead:YES];
            
        } else {
            [self.timerProgress invalidate];
        }
        
    }else {
        if (total < 1) {
            float playerCurrentTime = [self.playerView currentTime];
            self.progressSlider.value = (playerCurrentTime / (float)self.playerTotalTime);
        } else {
            [self.timerProgress invalidate];
        }
        
    }
}

- (void)buttonPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (sender == self.playButton) {
        if ([btn.currentTitle isEqualToString:@"Play"]) {
            [self.playerView playVideo];
            [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        } else {
            [self.playerView pauseVideo];
            [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        }
    }
}



- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    if (state == kYTPlayerStateEnded) {
        item+=1;
        [self.timerProgress invalidate];
        [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
        [self.youtubeTableView reloadData];
        
    } else if (state == kYTPlayerStatePlaying) {
        [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.playerTotalTime = [self.playerView duration];
        self.totalTime.text = [self stringFromTimeInterval:self.playerTotalTime];
        double currentTime = [self.playerView currentTime];
        NSTimeInterval currentTimeInterval = currentTime;
        
        self.currentTime.text = [self stringFromTimeInterval:currentTimeInterval];
        
        self.timerProgress = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(makeProgressBarMoving:) userInfo:nil repeats:YES];

    } else if (state == kYTPlayerStatePaused) {
        [self.timerProgress invalidate];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
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
