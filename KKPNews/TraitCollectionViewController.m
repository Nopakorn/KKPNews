//
//  TraitCollectionViewController.m
//  KKPNews
//
//  Created by Siam System Deverlopment on 7/4/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import "TraitCollectionViewController.h"
#import "MainViewController.h"
@interface TraitCollectionViewController ()

@end

@implementation TraitCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"containerSegue"]){
        MainViewController *dest = segue.destinationViewController;
        dest.youtube = self.youtube;
        dest.regionJp = self.regionJp;
    }
}

- (UITraitCollection *)overrideTraitCollectionForChildViewController:(UIViewController *)childViewController
{
    if (CGRectGetWidth(self.view.bounds) < CGRectGetHeight(self.view.bounds)) {
        return [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact];
    } else {
        return [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassRegular];
    }
}

@end
