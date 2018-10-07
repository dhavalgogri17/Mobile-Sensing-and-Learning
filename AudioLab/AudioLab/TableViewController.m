//
//  TableViewController.m
//  AudioLab
//
//  Created by Dhaval Gogri on 9/20/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"
#import "ViewControllerModuleB.h"

@interface TableViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// has 2 rows in the table for 2 modules.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
            ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerModuleA"];
            [self.navigationController pushViewController:viewController animated:YES];
    }
    else if(indexPath.row == 1){
        NSLog(@"View DID Load 1");
        ViewControllerModuleB *viewControllerB = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerModuleB"];
        [self.navigationController pushViewController:viewControllerB animated:YES];
        NSLog(@"View DID Load 2");
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    if(indexPath.row == 0){
        cell.textLabel.text = @"Module A";
    }
    else if(indexPath.row == 1){
        cell.textLabel.text = @"Module B";
    }
    return cell;
}


@end
