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
    
    NSMutableArray *channelListJP;
    NSMutableArray *channelListEN;
    NSInteger count;
    NSString *videoIdString;
    NSInteger countDuration;
    BOOL refreshFact;
    BOOL spinnerFact;
    BOOL firstTime;
}

@synthesize youtube;

- (void)viewDidLoad {
    [super viewDidLoad];
    //testing UI
    receivedVideo = NO;
    firstTime = YES;
    [self.navigationController setNavigationBarHidden:YES];
    self.playerView.delegate = self;
    item = 0;
    
    self.youtubeTableView.dataSource = self;
    self.youtubeTableView.delegate = self;
    self.youtubeTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *dateText = [NSString stringWithFormat:@"%@: %@",[NSString stringWithFormat:NSLocalizedString(@"Last Updated", nil)],[dateFormatter stringFromDate:[NSDate date]]];
    self.dateTimeLabel.text = dateText;
    // will change later
    //self.regionJp = YES;
    refreshFact = NO;
    spinnerFact = NO;
    self.loadingSpinner.hidden = YES;
    [self playlingYoutube];
    
    //customize progressbar
    UIImage *new = [UIImage imageNamed:@"thumbnail.png"];
    UIImage *myNewThumbnail = [MainViewController imageWithImage:new scaledToSize:CGSizeMake(20, 20)];
    [self.progressSlider setThumbImage:myNewThumbnail forState:UIControlStateNormal];
    UIImage *minImage = [[UIImage imageNamed:@"min"] stretchableImageWithLeftCapWidth:9 topCapHeight:0];
    UIImage *maxImage = [[UIImage imageNamed:@"max"] stretchableImageWithLeftCapWidth:9 topCapHeight:0];
    minImage = [MainViewController imageWithImage:minImage scaledToSize:CGSizeMake(4, 4)];
    maxImage = [MainViewController imageWithImage:maxImage scaledToSize:CGSizeMake(4, 4)];
    [self.progressSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [self.progressSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    
    //[self hideNavWithFact:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
   

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [hidingView invalidate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UITapGestureRecognizer *tgpr_webView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(handleTapPressedOnWebView:)];
    tgpr_webView.delegate = self;
    [self.playerView addGestureRecognizer:tgpr_webView];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
# pragma resize image
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

# pragma oreintation
- (void)orientationChanged:(NSNotification *)notification
{
    if (spinnerFact) {
       // spinner.center = CGPointMake(self.youtubeTableView.center.x, 85.5);
    }
}

- (void)viewDidLayoutSubviews
{
    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        if (self.youtubeTableView.hidden == true) {
            self.btmControlAreaConstraint.constant = 0;
            self.heightControllerAreaConstraint.constant = 0;
        } else {
            self.btmControlAreaConstraint.constant = 320;
            self.heightControllerAreaConstraint.constant = 44;
        }
    } else {
        
        if (self.youtubeTableView.hidden == true) {
            
            self.playerViewTrailingConstraint.constant = 0;
            self.heightControllerAreaConstraint.constant = 0;
            
        } else {
            
            self.playerViewTrailingConstraint.constant = 320;
            self.heightControllerAreaConstraint.constant = 44;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handleTapPressedOnWebView:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"tap on");
    [self hideWithFact:NO];
    [hidingView invalidate];
     hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

- (void)hideWithFact:(BOOL )fact
{
    if (fact) {
        self.btmControlAreaConstraint.constant = 0;
        self.heightControllerAreaConstraint.constant = 0;
        self.youtubeTableView.hidden = YES;
        
    } else {

        self.btmControlAreaConstraint.constant = 320;
        self.heightControllerAreaConstraint.constant = 44;
        self.youtubeTableView.hidden = NO;
    }
}

- (void)hide
{
      if ( self.youtubeTableView.hidden == YES) {
    
          self.btmControlAreaConstraint.constant = 320;
          self.heightControllerAreaConstraint.constant = 44;
          self.youtubeTableView.hidden = NO;
      } else {
    
          self.btmControlAreaConstraint.constant = 0;
          self.heightControllerAreaConstraint.constant = 0;
          self.youtubeTableView.hidden = YES;
      }
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

#pragma Call apis refresh
- (void)callYoutube:(BOOL )jp
{
    [hidingView invalidate];
    [self.youtube.durationList removeAllObjects];
    [self.youtube.data removeAllObjects];
    [self.youtubeTableView reloadData];
    self.youtube = [[Youtube alloc] init];
    
    refreshFact = YES;
    self.loadingSpinner.hidden = NO;
    spinnerFact = YES;
    if (jp) {
        channelListJP = [NSMutableArray arrayWithObjects:@"ANNnewsCH", @"tbsnewsi", @"NHKonline", @"JiJi", @"sankeinews", @"YomiuriShimbun", @"tvasahi", @"KyodoNews", @"asahicom", @"UCYfdidRxbB8Qhf0Nx7ioOYw", nil];
        count = [channelListJP count];
        countDuration = 1;
        for (int i = 0; i < [channelListJP count]; i++) {
            if ( i == [channelListJP count]-1 ) {
                [self.youtube getVideoPlaylistFromUploadIds:[channelListJP objectAtIndex:i] withNextPage:NO];
            } else {
                [self.youtube getChannelIdFromPlaylistName:[channelListJP objectAtIndex:i]];
            }
            
        }

    } else {
        channelListEN = [NSMutableArray arrayWithObjects:@"Euronews", @"bbcnews", @"AlJazeeraEnglish", @"AssociatedPress", @"RussiaToday", @"WashingtonPost", @"France24english", @"thenewyorktimes", @"CSPAN", @"NYPost", @"ReutersVideo", @"Bloomberg", @"Foxnewschannel", @"afpbbnews"  @"UCCcey5CP5GDZeom987gqTdg", nil];
        count = [channelListEN count];
        countDuration = 1;
        for (int i = 0; i < [channelListEN count]; i++) {
            if ( i == [channelListEN count]-1 ) {
                [self.youtube getVideoPlaylistFromUploadIds:[channelListEN objectAtIndex:i] withNextPage:NO];
            } else {
                [self.youtube getChannelIdFromPlaylistName:[channelListEN objectAtIndex:i]];
            }
            
        }

    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoId)
                                                 name:@"LoadVideoId" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoDuration)
                                                 name:@"LoadVideoDuration" object:nil];
}

- (void)receivedLoadVideoId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        count--;
        item++;
        if (count == 0) {
            //new ways--
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            NSDate *dateFromString;
            for (NSDictionary* a in self.youtube.jsonRes) {
                NSArray *arr = a[@"items"];
                for (NSDictionary* q in arr) {
                    if (q[@"snippet"][@"thumbnails"][@"default"][@"url"] != nil) {
                        
                        dateFromString = [dateFormatter dateFromString:q[@"snippet"][@"publishedAt"]];
                        NSDictionary *data = @{ @"videoId":q[@"contentDetails"][@"videoId"],
                                                @"publishedAtList":dateFromString,
                                                @"thumbnail":q[@"snippet"][@"thumbnails"][@"default"][@"url"],
                                                @"title":q[@"snippet"][@"title"] };
                        
                        [self.youtube.data addObject:data];
                    }
                }
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoId" object:nil];
            //sort
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedAtList" ascending:NO];
            [self.youtube.data sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
            
            NSString *reqVideoIds = @"";
            for (int i = 0; i < [self.youtube.data count]; i++) {
                reqVideoIds = [NSString stringWithFormat:@"%@,%@", reqVideoIds, [[self.youtube.data objectAtIndex:i] objectForKey:@"videoId"]];
            }
            
            if ([reqVideoIds characterAtIndex:0] == ',') {
                reqVideoIds = [reqVideoIds substringFromIndex:1];
            }
            
            videoIdString = reqVideoIds;
            [self callAllVideoDuration:videoIdString];
        }
    });
    
}

- (void)callAllVideoDuration:(NSString *)reqVideoIds
{
    int start = (int)[self.youtube.durationList count];
    NSInteger lengthCall = countDuration * 50;
    NSArray *arrString = [reqVideoIds componentsSeparatedByString:@","];
    
    if (lengthCall <= [arrString count]) {
        
        NSString *newArr = @"";
        for (int i = start; i < lengthCall; i++) {
            newArr = [NSString stringWithFormat:@"%@,%@", newArr, [arrString objectAtIndex:i]];
        }
        
        if ([newArr characterAtIndex:0] == ',') {
            newArr = [newArr substringFromIndex:1];
        }
        
        [self.youtube getVideoDurations:newArr];
    } else {
        [self receivedLoadVideoDuration];
    }
    
    
}

- (void)receivedLoadVideoDuration
{
    dispatch_async(dispatch_get_main_queue(), ^{
        countDuration+=1;
        item = 0;
        if (self.regionJp) {
            
            if (countDuration == [channelListJP count]) {
                spinnerFact = NO;
                refreshFact = NO;
                self.loadingSpinner.hidden = YES;
                [spinner stopAnimating];
                if (self.playerView.playerState == kYTPlayerStateEnded) {
                    NSLog(@"state: playing %ld",(long)self.playerView.playerState);
                    [self.timerProgress invalidate];
                    [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                } else if (self.playerView.playerState == kYTPlayerStatePlaying) {
                    refreshFact = YES;
                }
                
                [self.youtubeTableView reloadData];
                hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoDuration" object:nil];
            } else {
                [self callAllVideoDuration:videoIdString];
            }
        } else {
            
            if (countDuration == [channelListEN count]) {
                spinnerFact = NO;
                refreshFact = NO;
                self.loadingSpinner.hidden = YES;
                [spinner stopAnimating];
                if (self.playerView.playerState == kYTPlayerStateEnded) {
                    NSLog(@"state: playing %ld",(long)self.playerView.playerState);
                    [self.timerProgress invalidate];
                    [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                    
                } else if (self.playerView.playerState == kYTPlayerStatePlaying) {
                    refreshFact = YES;
                }
                [self.youtubeTableView reloadData];
                hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoDuration" object:nil];
            } else {
                [self callAllVideoDuration:videoIdString];
            }
        }
        
        
    });
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
    [self hideWithFact:NO];
    [hidingView invalidate];
    hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
    
    NSInteger startTime = sender.value * self.playerTotalTime;
    [self.timerProgress invalidate];
    self.progressSlider.value = (double)startTime / self.playerTotalTime;
    
    double currentTimeChange = sender.value * self.playerTotalTime;
    NSTimeInterval currentTimeInterval = currentTimeChange;
    self.currentTime.text = [self stringFromTimeInterval:currentTimeInterval];
    [self.playerView seekToSeconds:currentTimeChange allowSeekAhead:YES];
     self.timerProgress = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(makeProgressBarMoving:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timerProgress forMode:NSRunLoopCommonModes];
}

- (void)makeProgressBarMoving:(NSTimer *)timer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
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
            
        } else {
            if (total < 1) {
                float playerCurrentTime = [self.playerView currentTime];
                self.progressSlider.value = (playerCurrentTime / (float)self.playerTotalTime);
                self.currentTime.text = [self stringFromTimeInterval:currentTimeInterval];
            } else {
                [self.timerProgress invalidate];
            }
            
        }
 
}

- (IBAction)refeshButtonPressed:(id)sender
{
    if (!spinnerFact) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        NSString *dateText = [NSString stringWithFormat:@"%@: %@",[NSString stringWithFormat:NSLocalizedString(@"Last Updated", nil)],[dateFormatter stringFromDate:[NSDate date]]];
        self.dateTimeLabel.text = dateText;

        [self callYoutube:self.regionJp];
    }

}

- (IBAction)buttonPressed:(id)sender
{
    UIImage *btnImagePause = [UIImage imageNamed:@"pause"];
    UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
    if (sender == self.playButton) {
        if ([[self.playButton imageForState:UIControlStateNormal] isEqual:btnImagePlay]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback Started" object:self];
            [self.playerView playVideo];
            [self.playButton setImage:btnImagePause forState:UIControlStateNormal];
        } else {
            [self.playerView pauseVideo];
            [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
        }
    }
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{

    if (state == kYTPlayerStateEnded) {
        if(spinnerFact){
            NSLog(@"still loading");
        } else {
            if (refreshFact) {
                item = 0;
                refreshFact = NO;
            } else {
                item+=1;
            }

            [self.timerProgress invalidate];
            [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
            [self.youtubeTableView reloadData];
        }
        
        
    } else if (state == kYTPlayerStatePlaying) {
        UIImage *btnImagePause = [UIImage imageNamed:@"pause"];
        [self.playButton setImage:btnImagePause forState:UIControlStateNormal];
        self.playerTotalTime = [self.playerView duration];
        self.totalTime.text = [self stringFromTimeInterval:self.playerTotalTime];
        double currentTime = [self.playerView currentTime];
        NSTimeInterval currentTimeInterval = currentTime;
        
        self.currentTime.text = [self stringFromTimeInterval:currentTimeInterval];

        [self.timerProgress invalidate];
        self.timerProgress = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(makeProgressBarMoving:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timerProgress forMode:NSRunLoopCommonModes];
        if (firstTime) {
            [hidingView invalidate];
            hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
            firstTime = NO;
        }
        
        
    } else if (state == kYTPlayerStatePaused) {
        [self.timerProgress invalidate];
        UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
        [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
        
    } else if (state == kYTPlayerStateUnstarted) {
        
        if(spinnerFact){
            NSLog(@"still loading");
        } else {
            if (refreshFact) {
                item = 0;
                refreshFact = NO;
            } else {
                item+=1;
            }
            
            [self.timerProgress invalidate];
            [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
            [self.youtubeTableView reloadData];
        }

    } else if (state == kYTPlayerStateBuffering){
        NSLog(@"bufferring");
        //self.timerProgress = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(makeProgressBarMoving:) userInfo:nil repeats:YES];
    } else {
        NSLog(@"what state == %ld",(long)self.playerView.playerState);
    }
}

# pragma table delegate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (spinnerFact) {
        return 0;
    } else {
        if ([self.youtube.durationList count] != 0) {
            //return 50;
            return [self.youtube.durationList count];
        }else{
            return 0;
        }
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
    if (refreshFact) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    } else {
        if (indexPath.row == item) {
            cell.contentView.backgroundColor = UIColorFromRGB(0xDADADA);
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
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
    refreshFact = NO;
    item = indexPath.row;
    [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
    [self.youtubeTableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.youtubeTableView reloadData];
}

@end
