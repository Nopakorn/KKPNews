//
//  FirstScreenViewController.m
//  KKPNews
//
//  Created by Siam System Deverlopment on 6/15/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import "FirstScreenViewController.h"
#import "MainViewController.h"

@interface FirstScreenViewController ()

@end

@implementation FirstScreenViewController
{
    NSInteger count;
    NSInteger countDuration;
    NSInteger item;
    NSMutableArray *channelList;
    NSString *videoIdString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    
    channelList =[NSMutableArray arrayWithObjects:@"ANNnewsCH", @"tvasahi", @"NHKonline", @"JiJi", @"sankeinews", @"YomiuriShimbun", @"tbsnewsi", @"KyodoNews", @"asahicom", nil];
    
    count = [channelList count];
    countDuration = 1;
    item = 0;
    videoIdString = @"";
    self.youtube = [[Youtube alloc] init];
    [self callYoutube];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoId)
                                                 name:@"LoadVideoId" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoDuration)
                                                 name:@"LoadVideoDuration" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (void)callYoutube
{
    for (int i = 0; i < [channelList count]; i++) {
         [self.youtube getChannelIdFromPlaylistName:[channelList objectAtIndex:i]];
    }
    //[self.youtube getChannelIdFromPlaylistName:[channelList objectAtIndex:item]];
}

- (void)receivedLoadVideoId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"count id %lu and thumbnail %lu and duration %lu", (unsigned long)[self.youtube.videoIdList count], (unsigned long)[self.youtube.thumbnailList count], (unsigned long)[self.youtube.durationList count]);
        count--;
        item++;
        if (count == 0) {
            NSLog(@"all done objects = %lu", (unsigned long)[self.youtube.videoIdList count]);
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
    NSString *newArr = @"";
    for (int i = start; i < lengthCall; i++) {
        newArr = [NSString stringWithFormat:@"%@,%@", newArr, [arrString objectAtIndex:i]];
    }
    
    if ([newArr characterAtIndex:0] == ',') {
        newArr = [newArr substringFromIndex:1];
    }

    [self.youtube getVideoDurations:newArr];

}

- (void)receivedLoadVideoDuration
{
    dispatch_async(dispatch_get_main_queue(), ^{
        countDuration+=1;
        if (countDuration == [channelList count]) {
            [self performSegueWithIdentifier:@"mainSegue" sender:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoDuration" object:nil];
        } else {
            [self callAllVideoDuration:videoIdString];
        }
       
    });
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"mainSegue"]){
        
        MainViewController *dest = segue.destinationViewController;
        dest.youtube = self.youtube;
    }
}


@end
