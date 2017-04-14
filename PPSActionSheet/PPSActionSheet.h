//
//  PPSActionSheet.h
//  PPSActionSheet
//  支持两种方式回调点击结果，delegate和block
//  Created by ppsheep on 2017/4/13.
//  Copyright © 2017年 ppsheep. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PPSActionSheet;
@class PPSActionSheetItem;
@protocol PPSActionSheetClickedDelegate <NSObject>

@required
/**
 点击选项 实现这个代理必须实现这个方法 不然点击不能实现
 
 @param actionSheet 当前显示的actionsheet 如果存在多个actionsheet 可以分别出是哪一个actionsheet
 @param item 点击的位置
 */
- (void)actionSheet:(PPSActionSheet *)actionSheet clickedButtonAtIndex:(PPSActionSheetItem *)item;

@end

@interface PPSActionSheetItem : NSObject

@property (nonatomic, readonly, copy) NSString *title;//点击title
@property (nonatomic, readonly, assign) NSInteger index;//点击的index

+ (PPSActionSheetItem *)itemWithTitle:(NSString *)title index:(NSInteger)index;

@end


typedef void(^ClickedCompleteBlock)(PPSActionSheetItem *item);//点击回调

@interface PPSActionSheet : UIView

@property (nonatomic, copy)ClickedCompleteBlock clickedCompleteBlock;

/**
 创建实例，如果使用block,delegate直接传nil即可
 
 @param delegate    代理 一般为当前的VC
 @param cancleTitle 取消的title 最下面的选项
 @param otherTitles 其他的一些选项标题
 
 @return actionsheet
 */
- (instancetype)initWithDelegate:(id<PPSActionSheetClickedDelegate>)delegate
                     cancleTitle:(NSString *)cancleTitle
                     otherTitles:(NSString *)otherTitles,... NS_REQUIRES_NIL_TERMINATION;

- (void)show;

@end
