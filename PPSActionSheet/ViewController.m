//
//  ViewController.m
//  PPSActionSheet
//
//  Created by ppsheep on 2017/4/13.
//  Copyright © 2017年 ppsheep. All rights reserved.
//

#import "ViewController.h"
#import "PPSActionSheet.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clicked:(id)sender {
    PPSActionSheet *sheet1 = [[PPSActionSheet alloc] initWithDelegate:nil cancleTitle:@"取消" otherTitles:@"你好",@"我好", nil];
    sheet1.clickedCompleteBlock = ^(PPSActionSheetItem *item) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:item.title message:@"点击的item" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"%@", item.title);
    };
    [sheet1 show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
