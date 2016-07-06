//
//  Youtube.m
//  KKPNews
//
//  Created by Siam System Deverlopment on 6/13/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import "Youtube.h"

@implementation Youtube
{
    NSString *checkResult;
    NSString *checkDurationEachVideo;
    NSInteger nextVideo;
    int indexNexPage;
    int indexCount;
}

- (id)init
{
    if(self = [super init]){
        //will change later
        self.siteURLString = [NSString stringWithFormat:@"http://www.googleapis.com/youtube/v3/"];
        self.durationList = [[NSMutableArray alloc] initWithCapacity:10];
        self.data = [[NSMutableArray alloc] initWithCapacity:10];
        self.jsonRes = [[NSMutableArray alloc] initWithCapacity:10];
        self.search = @"search?";
        self.video = @"video?";
        self.youtube_api_key = @"AIzaSyAPT3PRTZdTQDdoOtwviiC0FQPpJvfQlWE";
        self.videoIdListForGetDuration = @"";
        nextVideo = 0;
        indexNexPage = 0;
        indexCount = 0;
        NSLocale *currentLocale = [NSLocale currentLocale];
        self.regionCode = [currentLocale objectForKey:NSLocaleCountryCode];
        self.hl = @"en-US";
    }
    return self;
}
- (void)changeIndexNextPage:(int)newIndexNexPage
{
    indexNexPage = newIndexNexPage;
}

#pragma new method
- (void)getChannelIdFromPlaylistName:(NSString *)playlistName
{
     NSString* urlString;
    urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/channels?part=id%%2Csnippet%%2CcontentDetails&forUsername=%@&key=%@",playlistName ,self.youtube_api_key];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [req setHTTPMethod:@"GET"];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if(!error)
        {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.channelsResults = json;
            [self fetchChannelInfo];
        }
    }] resume];

}

- (void)fetchChannelInfo
{
    NSArray *items = self.channelsResults[@"items"];
    NSString *uploadsId;
    for (NSDictionary *q in items) {
        uploadsId = q[@"contentDetails"][@"relatedPlaylists"][@"uploads"];
    }
    [self getVideoPlaylistFromUploadIds:uploadsId withNextPage:NO];
}

- (void)getVideoPlaylistFromUploadIds:(NSString *)uploadsId withNextPage:(BOOL)nextPage
{
    NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?part=id%%2Csnippet%%2CcontentDetails&maxResults=50&playlistId=%@&key=%@", uploadsId, self.youtube_api_key];
        
    NSURL *url = [[NSURL alloc] initWithString:urlString];
        
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
    [req setHTTPMethod:@"GET"];
        
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if(!error)
        {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.searchResults = json;
            if (json[@"items"] != nil) {
                [self.jsonRes addObject:json];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoId" object:self];
            checkResult = @"LoadVideoId";
        }else{
            NSLog(@"%@",error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorResponse" object:self];
        }
            
    }] resume];

}

- (void)getVideoDurations:(NSString *)videoId
{
    NSString* urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=%@&key=%@", videoId, self.youtube_api_key];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [req setHTTPMethod:@"GET"];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        if(!error)
        {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.searchResults = json;
            checkDurationEachVideo = @"done";
            nextVideo++;
            [self fetchVideosDuration];
        }else{
            NSLog(@"%@",error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorRespones" object:self];
        }
        
    }] resume];
}

- (void)fetchVideosDuration
{
    NSArray *items = self.searchResults[@"items"];
    for (NSDictionary* q in items) {
        [self.durationList addObject:q[@"contentDetails"][@"duration"]];
    }

    //[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoId" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoDuration" object:self];
    
}

-(void)fetchVideos:(BOOL)nextPage
{
    NSArray* items = self.searchResults[@"items"];
    self.nextPageToken = self.searchResults[@"nextPageToken"];
    self.prevPageToken = self.searchResults[@"prevPageToken"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *dateFromString;
    if ([items count] == 0) {
        NSLog(@"no items %@",self.searchResults[@"etag"]);
    } else {
        for (NSDictionary* q in items) {
            if (q[@"snippet"][@"thumbnails"][@"default"][@"url"] != nil) {
                
                dateFromString = [dateFormatter dateFromString:q[@"snippet"][@"publishedAt"]];
                NSDictionary *data = @{ @"videoId":q[@"contentDetails"][@"videoId"],
                                        @"publishedAtList":dateFromString,
                                        @"thumbnail":q[@"snippet"][@"thumbnails"][@"default"][@"url"],
                                        @"title":q[@"snippet"][@"title"] };
                
                [self.data addObject:data];
                
                
            }
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadVideoId" object:self];
}

@end

