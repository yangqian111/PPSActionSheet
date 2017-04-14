# PPSActionSheet
一个actionsheet，目前还是比较简单的阶段，后期加入扩展，主标题，副标题之类的都可以丰富

在之前，这个ActionSheet是已经写过的，之前是因为觉得iOS9的ActionSheet有点看不大习惯，就自己写了一个简单的，之前还发过一篇介绍了一下，最近要用到这个ActionSheet，然后拿出来用，觉得之前写的还是比较粗糙，这里再重新加工一下

同样的，还是先看一下效果图

![](http://o8bxt3lx0.bkt.clouddn.com/ppsheep/gk8a2.gif)

首先根据效果，我们可以分析一下，怎样来实现这样一个效果，其实无论什么UI效果，第一步都是先分析我们怎么样来实现这个，后面才是怎么样来将这个效果实现的更好，代码更清晰简洁，扩展性更高。

* 首先，我们需要一个全遮罩的背景，在点击的时候需要将actionsheet隐藏掉
* 然后这个actionsheet，需要根据选项来生成，可以想到这选项是一个个的button，我看见有的实现里是将它做成一个tableview，我感觉是做麻烦了
* 另外一个就是点击回调了，这里我做了两种，一个是delegate回调，一个是block回调

#### 回调的item
很多实现的actionsheet，回调都是一个index的值，我之前实现的也是一个点击的索引，但是这样扩展起来比较麻烦，很有局限性，所以这次，我将回调做成了一个model，这个model里你可以自己定义一些属性，根据传入的参数，来自定义这个model，这样，扩展性稍微强一些

```objc
@interface PPSActionSheetItem : NSObject

@property (nonatomic, readonly, copy) NSString *title;//点击title
@property (nonatomic, readonly, assign) NSInteger index;//点击的index

+ (PPSActionSheetItem *)itemWithTitle:(NSString *)title index:(NSInteger)index;
@end

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
```

#### delegate && block

点击的回调，和之前没什么差别，只是回调的数据变成了item

##### delegate

<font color=red>在点击事件里面 回传actionsheet的目的  是因为在一个viewcontroller里面可能会有多个 actionsheet展现，在同一个VC里面就需要区分 是哪个actionsheet 来区分操作

不同的actionsheet当然可以使用tag来区分 当然也可以用其他的方法区分</font>

```objc
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
```

##### block

```objc
//点击回调
typedef void(^ClickedCompleteBlock)(PPSActionSheetItem *item);
```

#### 实现

##### 初始化

在初始化的时候，提供了初始化方法,如果想使用block回调方式，直接将delegate置为nil就行

初始化方法的选项，采用的是传入可变参数的形式，这样，在初始化的时候，显得更简洁明了一些

```objc
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
```

#### 效果实现

整个actionsheet是继承自UIView，我们之前说到的黑色遮罩，我将actionsheet的本身设置为一个全屏的view，给它加一个背景颜色效果，再alpha设置一下，就达到了效果。

然后选项的view，都将他们加到了actionsheet的一个子view sheetView中

在初始化的时候，首先将选项item，根据传入的参数生成

```objc
int tag = 0;//记录item的index值
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
```
在选项item生成完成之后，我们需要计算一下sheetview的frame，然后就可以开始添加按钮到sheetview上了

```objc
CGRect sheetViewF = _sheetView.frame;
sheetViewF.size.height = BtnHeight * _items.count + CancleMargin;
_sheetView.frame = sheetViewF;
//开始添加按钮
[self setupBtnWithTitles];
```

在添加按钮的时候，将每个按钮计算一下frame，添加到sheetview上就行，实现起来都是不麻烦的

```objc
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
```

在使用的时候，可以通过block，也可使用delegate

```objc
PPSActionSheet *sheet1 = [[PPSActionSheet alloc] initWithDelegate:nil cancleTitle:@"取消" otherTitles:@"你好",@"我好", nil];
sheet1.clickedCompleteBlock = ^(PPSActionSheetItem *item) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:item.title message:@"点击的item" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    NSLog(@"%@", item.title);
};
[sheet1 show];
```

这个actionsheet还可以丰富很多，比如可以传入主标题，副标题之类的，还可以将它丰富成具体购买商品选择数量，或者几个选项的控制开关等等。
有这个想法，后面应该是先从主副标题开始吧

其他的也没什么要讲的了，这个actionsheet，也是在用到图片浏览器的时候，需要用到它，然后一看之前的写的有点丑，就稍微整理了一下，那个关于查看的图片的小工具，也会重新整理优化一下，那个图片查看器上还有一个下载的progress的小view，那个view我也准备拎出来单独成一个仓库，这些小的view都是可以优化很多，还能丰富很多，拎出来做个准备

源码我就放上去了：

https://github.com/yangqian111/PPSActionSheet

**欢迎关注微博：ppsheep_Qian**
 
http://weibo.com/ppsheep

**欢迎关注公众号**

![](http://ac-mhke0kuv.clouddn.com/830a4ead8294ceff5160.jpg)