//
//  PPSActionSheet.m
//  PPSActionSheet
//
//  Created by ppsheep on 2017/4/13.
//  Copyright © 2017年 ppsheep. All rights reserved.
//

#import "PPSActionSheet.h"

@interface PPSActionSheetItem()

@property (nonatomic, readwrite, copy) NSString *title;//点击title
@property (nonatomic, readwrite, assign) NSInteger index;//点击的index

@end

@implementation PPSActionSheetItem

+ (PPSActionSheetItem *)itemWithTitle:(NSString *)title index:(NSInteger)index {
    PPSActionSheetItem *item = [[PPSActionSheetItem alloc] initWithTitle:title index:index];
    return item;
}

- (instancetype)initWithTitle:(NSString *)title index:(NSInteger)index {
    self = [super init];
    if(self) {
        _title = [title copy];
        _index = index;
    }
    return self;
}

@end


static CGFloat BtnHeight = 46.0;//每个按钮的高度
static CGFloat CancleMargin = 8.0;//取消按钮上面的间隔

//颜色制作 定义一个宏
#define PPSActionSheetColor(r, g, b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define PPSActionSheetBGColor PPSActionSheetColor(237,240,242) //背景色
#define PPSActionSheetSeparatorColor PPSActionSheetColor(226, 226, 226) //分割线颜色
#define PPSActionSheetNormalImage [self imageWithColor:PPSActionSheetColor(255,255,255)] //普通下的图片
#define PPSActionSheetHighImage [self imageWithColor:PPSActionSheetColor(242,242,242)] //高粱的图片

#define PPSActionSheetScreenWidth [UIScreen mainScreen].bounds.size.width
#define PPSActionSheetScreenHeight [UIScreen mainScreen].bounds.size.height

@interface PPSActionSheet()

@property (nonatomic, strong) UIView *sheetView;
@property (nonatomic, weak) id <PPSActionSheetClickedDelegate> delegate;
@property (nonatomic, copy) NSMutableArray *items;

@end


@implementation PPSActionSheet

-(instancetype)initWithDelegate:(id<PPSActionSheetClickedDelegate>)delegate cancleTitle:(NSString *)cancleTitle otherTitles:(NSString *)otherTitles, ... {
    self = [super init];
    if (self) {
        //设置代理
        if (delegate) {
            _delegate = delegate;
        }
        //黑色遮盖
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor blackColor];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        self.alpha = 0.0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverClick)];
        [self addGestureRecognizer:tap];
        
        // sheet
        _sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPSActionSheetScreenWidth, 0)];
        _sheetView.backgroundColor = PPSActionSheetColor(237,240,242);
        _sheetView.alpha = 0.9;
        [[UIApplication sharedApplication].keyWindow addSubview:_sheetView];
        _sheetView.hidden = YES;
        

        int tag = 0;
        _items = [NSMutableArray array];
        //首先添加取消按钮
        PPSActionSheetItem *cancleItem = [PPSActionSheetItem itemWithTitle:@"取消" index:0];
        [_items addObject:cancleItem];
        
        tag ++;
        
        NSString* curStr;
        va_list list;
        if(otherTitles)
        {
            PPSActionSheetItem *item = [PPSActionSheetItem itemWithTitle:otherTitles index:tag];
            [_items addObject:item];
            tag ++;
            
            va_start(list, otherTitles);
            while ((curStr = va_arg(list, NSString*))) {
                PPSActionSheetItem *item = [PPSActionSheetItem itemWithTitle:curStr index:tag];
                [_items addObject:item];
                tag ++;
            }
            va_end(list);
        }
        CGRect sheetViewF = _sheetView.frame;
        sheetViewF.size.height = BtnHeight * _items.count + CancleMargin;
        _sheetView.frame = sheetViewF;
        //开始添加按钮
        [self setupBtnWithTitles];
    }
    return self;
}

- (void)show {
    self.sheetView.hidden = NO;
    
    CGRect sheetViewF = self.sheetView.frame;
    sheetViewF.origin.y = PPSActionSheetScreenHeight;
    self.sheetView.frame = sheetViewF;
    
    CGRect newSheetViewF = self.sheetView.frame;
    newSheetViewF.origin.y = PPSActionSheetScreenHeight - self.sheetView.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.sheetView.frame = newSheetViewF;
        
        self.alpha = 0.3;
    }];
}

/**
 创建每个选项
 
 */
- (void)setupBtnWithTitles {
    
    for (PPSActionSheetItem *item in _items) {
        UIButton *btn = nil;
        if (item.index == 0) {//取消按钮
            btn = [[UIButton alloc] initWithFrame:CGRectMake(0, _sheetView.frame.size.height - BtnHeight, PPSActionSheetScreenWidth, BtnHeight)];
        } else {
            btn = [[UIButton alloc] initWithFrame:CGRectMake(0, BtnHeight * (item.index - 1) , PPSActionSheetScreenWidth, BtnHeight)];
            // 最上面画分割线
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPSActionSheetScreenWidth, 0.5)];
            line.backgroundColor = PPSActionSheetSeparatorColor;
            [btn addSubview:line];
        }
        btn.tag = item.index;
        [btn setBackgroundImage:PPSActionSheetNormalImage forState:UIControlStateNormal];
        [btn setBackgroundImage:PPSActionSheetHighImage forState:UIControlStateHighlighted];
        [btn setTitle:item.title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:17];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(sheetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.sheetView addSubview:btn];
    }
}

/**
 显示黑色遮罩
 */
- (void)coverClick{
    CGRect sheetViewF = self.sheetView.frame;
    sheetViewF.origin.y = PPSActionSheetScreenHeight;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.sheetView.frame = sheetViewF;
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.sheetView removeFromSuperview];
    }];
}

- (void)sheetBtnClick:(UIButton *)btn{
    PPSActionSheetItem *item = _items[btn.tag];
    if (item.index == 0) {
        [self coverClick];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self clickedButtonAtIndex:item];
    }
    
    if (self.clickedCompleteBlock) {
        self.clickedCompleteBlock(item);
    }
    
    [self coverClick];
}

/**
 根据颜色生成图片
 
 @param color 颜色
 
 @return 图片
 */
- (UIImage*)imageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end

