//
//  ViewController.m
//  OperationDownload
//
//  Created by renjinwei on 2021/1/1.
//  Copyright © 2021 renjinwei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)downloadBtn:(id)sender {
    NSLog(@"start download");
    //download 然后更新主线程
//    [self downloadSubThread];
//    [self downloadbackground];

//    [self downloadTwoPicsByDependence];
    [self downloadTwoPicsBarriedBlock];
}

#pragma mark --下载2个图片合并
- (void)downloadTwoPicsBarriedBlock
{
    __block UIImage* image1 = nil;
    __block UIImage* image2 = nil;
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation* downloadOP1 = [NSBlockOperation blockOperationWithBlock:^{
        NSURL* url = [NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fi-1.xitonghe.com%2F2019%2F9%2F5%2FKDYwMHgp%2F891838fa-f4b4-4cdc-a556-b2232f0e432f.jpg&refer=http%3A%2F%2Fi-1.xitonghe.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1612081214&t=1e3486cf9f04ae799a3837c2529cfcce"];
        
        NSData* data = [NSData dataWithContentsOfURL:url];
        image1 = [UIImage imageWithData:data];
        NSLog(@"download1 %@", [NSThread currentThread]);
    }];
    
    NSBlockOperation* downloadOP2 = [NSBlockOperation blockOperationWithBlock:^{
        NSURL* url = [NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fq_70%2Cc_zoom%2Cw_640%2Fimages%2F20190722%2F51a7ec44fc914454af77d0d3eb2f4b7f.jpeg&refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1612081214&t=e76deb86cf9d0455365364c05a58c836"];
        
        NSData* data = [NSData dataWithContentsOfURL:url];
        image2 = [UIImage imageWithData:data];
        NSLog(@"download2 %@", [NSThread currentThread]);
    }];
 
    [queue addOperation:downloadOP1];
    [queue addOperation:downloadOP2];
    
    [queue addBarrierBlock:^{
        UIGraphicsBeginImageContext(CGSizeMake(300, 300));
        [image1 drawInRect:CGRectMake(0, 0, 150, 150)];
        [image2 drawInRect:CGRectMake(150, 0, 150, 150)];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
        }];
    }];
    
}


- (void)downloadTwoPicsByDependence
{
    __block UIImage* image1 = nil;
    __block UIImage* image2 = nil;
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation* downloadOP1 = [NSBlockOperation blockOperationWithBlock:^{
        NSURL* url = [NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fi-1.xitonghe.com%2F2019%2F9%2F5%2FKDYwMHgp%2F891838fa-f4b4-4cdc-a556-b2232f0e432f.jpg&refer=http%3A%2F%2Fi-1.xitonghe.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1612081214&t=1e3486cf9f04ae799a3837c2529cfcce"];
        
        NSData* data = [NSData dataWithContentsOfURL:url];
        image1 = [UIImage imageWithData:data];
        NSLog(@"download1 %@", [NSThread currentThread]);

    }];
    
    NSBlockOperation* downloadOP2 = [NSBlockOperation blockOperationWithBlock:^{
        NSURL* url = [NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fq_70%2Cc_zoom%2Cw_640%2Fimages%2F20190722%2F51a7ec44fc914454af77d0d3eb2f4b7f.jpeg&refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1612081214&t=e76deb86cf9d0455365364c05a58c836"];
        
        NSData* data = [NSData dataWithContentsOfURL:url];
        image2 = [UIImage imageWithData:data];
        NSLog(@"download2 %@", [NSThread currentThread]);
    }];
    
    NSBlockOperation* mergePic = [NSBlockOperation blockOperationWithBlock:^{
        UIGraphicsBeginImageContext(CGSizeMake(300, 300));
        [image1 drawInRect:CGRectMake(0, 0, 150, 150)];
        [image2 drawInRect:CGRectMake(150, 0, 150, 150)];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
        }];
        
    }];
    [mergePic addDependency:downloadOP1];
    [downloadOP1 addDependency:downloadOP2];
    
    [queue addOperation:downloadOP1];
    [queue addOperation:downloadOP2];
    [queue addOperation:mergePic];
    
}


#pragma mark -- 单独下载
- (void)downloadbackground
{
    NSBlockOperation* downloadOP = [NSBlockOperation blockOperationWithBlock:^{
        NSURL* url = [NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fi-1.xitonghe.com%2F2019%2F9%2F5%2FKDYwMHgp%2F891838fa-f4b4-4cdc-a556-b2232f0e432f.jpg&refer=http%3A%2F%2Fi-1.xitonghe.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1612081214&t=1e3486cf9f04ae799a3837c2529cfcce"];
        
        NSData* data = [NSData dataWithContentsOfURL:url];
        UIImage* image = [UIImage imageWithData:data];
        NSLog(@"download %@", [NSThread currentThread]);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
        }];
    }];
    
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    [queue addOperation:downloadOP];
}


- (void)downloadSubThread
{
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
                NSURL* url = [NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fq_70%2Cc_zoom%2Cw_640%2Fimages%2F20190722%2F51a7ec44fc914454af77d0d3eb2f4b7f.jpeg&refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1612081214&t=e76deb86cf9d0455365364c05a58c836"];
        
        NSData* data = [NSData dataWithContentsOfURL:url];
        UIImage* image = [UIImage imageWithData:data];
        NSLog(@"download %@", [NSThread currentThread]);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
        }];
    }];
}
@end
