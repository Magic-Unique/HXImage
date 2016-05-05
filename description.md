

这篇文章是笔者在开发App过程中发现的一些内存问题, 然后学习了YYKit框架时候也发现了图片的缓存处理的<del>不够得当</del> (YYKit 作者联系了我, 说明了YYKit重写imageNamed:的目的不是为了内存管理, 而是增加兼容性, 同时也是为了YYKit中的动画服务). 以下内容是笔者在开发中做了一些实验以及总结. 如有错误望即时提出, 笔者会第一时间改正.

文章的前篇主要是对两种不同的`UIImage`工厂方法的分析, <del>以及对 YYKit 中的 YYImage 的分析</del>. 罗列出这些工厂方法的内存管理的优缺点. 

文章的后篇是本文要说明的重点, 如何结合两种工厂方法的优点做更进一步的节约内存的管理.

> PS
> 
> 本文所说的 Resource 是指使用`imageWithContentsOfFile:`创建图片的图片管理方式. 
> 
> ImageAssets 是指使用`imageNamed:`创建图片的图片管理方式.
> 
> 如果你对这两个方法已经了如指掌, 可以直接看**UIImage 与 YYImage 的内存问题**和后面的内容

[TOC]


# UIImage 的内存处理

在实际的苹果App开发中, 将图片文件导入到工程中无非使用两种方式. 一种是 Resource `(我也不知道应该称呼什么,就这么叫吧)`,还有一种是 ImageAssets 形式存储在一个图片资源管理文件中. 这两种方式都可以存储任何形式的图片文件, 但是都有各自的优缺点在内. 接下来我们就来谈谈这两种图片数据管理方式的优缺点.

## Resource 与 "imageWithContentsOfFile:"

### Resource 的使用方式

将文件直接拖入到工程目录下, 并告诉Xcode打包项目时候把这些图片文件打包进去. 这样在应用的".app"文件夹中就有这些图片. 在项目中, 读取这些图片可以通过以下方式来获取图片文件并封装成`UIImge`对象:

```objc
NSString *path = [NSBundle.mainBundle pathForResource:@"image@2x" type:@"png"];
UIImage *image = [UIImage imageWithContentsOfFile:path];
```

而底层的实现原理近似是:

```objc
+ (instancetype)imageWithContentsOfFile:(NSString *)fileName {
	NSUInteger scale = 0;
	{
		scale = 2;//这一部分是取 fileName 中"@"符号后面那个数字, 如果不存在则为1, 这一部分的逻辑省略
	}
	return [[self alloc] initWithData:[NSData dataWithContentsOfFile:fileName scale:scale];
}
```
这种方式有一个局限性, 就是图片文件必须在`.ipa`的根目录下或者在沙盒中. 在`.ipa`的根目录下创建图片文件仅仅只有一种方式, 就是通过 Xcode 把图片文件直接拖入工程中. 还有一种情况也会创建图片文件, 就是当工程支持低版本的 iOS 系统时, 低版本的iOS系统并不支持 ImageAssets 打包文件的图片读取, 所以 Xcode 在编译时候会自动地将 ImageAssets 中的图片复制一份到根目录中. 此时也可以使用这个方法创建图片.

### Resource 的特性

在 Resource 的图片管理方式中, 所有的图片创建都是通过读取文件数据得到的, 读取一次文件数据就会产生一次`NSData`以及产生一个`UIImage`, 当图片创建好后销毁对应的`NSData`, 当`UIImage`的引用计数器变为0的时候自动销毁`UIImage`. 这样的话就可以保证图片不会长期地存在在内存中.

### Resource 的常用情景


由于这种方法的特性, 所以 Resource 的方法一般用在图片数据很大, 图片一般不需要多次使用的情况. 比如说**引导页背景**(图片全屏, 有时候运行APP会显示, 有时候根本就用不到).

### Resource 的优点

图片的生命周期可以得到管理无疑是 Resource 最大的优点, 当我们需要图片的时候就创建一个, 当我们不需要这个图片的时候就让他销毁. 图片不会长期的保存在内存当中, 所以不会有很多的内存浪费. 同时, 大图一般不会长期使用, 而且大图占用内存一般比小图多了好多倍, 所以在减少大图的内存占用中, Resource 做的非常好.

## ImageAssets 与 "imageNamed:"

ImageAssets 的设计初衷主要是为了自动适配 Retina 屏幕和非 Retina 屏幕, 也就是解决 iPhone 4 和 iPhone 3GS 以及以前机型的屏幕适配问题. 现在 iPhone 3GS 以及之前的机型都已被淘汰, 非 Retina 屏幕已不再是开发考虑的范围. 但是 plus 机型的推出将 Retina 屏幕又提高了一个水平, ImageAssets 现在的主要功能则是区分 plus 屏幕和非 plus 屏幕, 也就是解决 2 倍 Retina 屏幕和 3 倍 Retina 屏幕的视屏问题.

### ImageAssets 的使用方式

iOS 开发中一般在工程内导入两个到三个同内容不同像素的图片文件, 一般如下:

1. image.png  (30 x 30)
2. image@2x.png (60 x 60)
3. image@3x.png (90 x 90)

这三张图片都是相同内容, 而且图片名称的前缀相同, 区别在与图片名以及图片的分辨率. 开发者将这三张图片拉入 ImageAssets 后, Xcode 会以图片前缀创建一个图片组(这里也就是 "image"). 然后在代码中写:

```objc
UIImage *image = [UIImage imageNamed:@"image"];
```

就会根据不同屏幕来获取对应不同的图片数据来创建图片. 如果是 3GS 之前的机型就会读取 "image.png", 普通 Retina 会读取 "image@2x.png", plus Retina 会读取 "image@3x.png", 如果某一个文件不存在, 就会用另一个分辨率的图片代替之.

### ImageAssets 的特性

与 Resources 相似, ImageAssets 也是从图片文件中读取图片数据转为 UIImage, 只不过这些图片数据都打包在 ImageAssets 中. 还有一个最大的区别就是图片缓存. 相当于有一个字典, key 是图片名, value是图片对象. 调用`imageNamed:`方法时候先从这个字典里取, 如果取到就直接返回, 如果取不到再去文件中创建, 然后保存到这个字典后再返回. 由于字典的`key`和`value`都是强引用, 所以一旦创建后的图片永不销毁.

其内部代码相似于:

```objc

+ (NSMutableDictionary *)imageBuff {
	static NSMutableDictionary *_imageBuff;
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imageBuff = [[NSMutableDictionary alloc] init];
    });
    return _imageBuff;
}

+ (instancetype)imageNamed:(NSString *)imageName {
	if (!imageName) {
		return nil;
	} 
	UIImage *image = self.imageBuff[imageName];
	if (image) {
		return image;
	}
	NSString *path = @"this is the image path"//这段逻辑忽略
	image = [self imageWithContentsOfFile:path];
	if (image) {
		self.imageBuff[imageName] = image;
	}
	return image;
}

```

### ImageAssets 的使用场景

ImageAssets 最主要的使用场景就是 icon 类的图片, 一般 icon 类的图片大小在 3kb 到 20 kb 不等, 都是一些小文件.

### ImageAssets 的优点

当一个 icon 在多个地方需要被显示的时候, 其对应的`UIImage`对象只会被创建一次, 而且多个地方的 icon 都将会共用一个 `UIImage` 对象. 减少沙盒的读取操作.

# <del>YYImage 的内存处理</del>

***由于YYImage的目的并不是为了关闭缓存, 所以此段没有分析的意义, 现已删除.***

<del>YYImage 的核心就是学习`imageWithContentsOfFile:`的方法原理去实现`imageNamed:`方法. 达到`imageNamed:`方法中没有缓存功能, 最终使得不需要图片的时候即可销毁图片对象. </del>

## <del>imageWithContentsOfFile 代替 imageNamed</del>

<del>首先看 YYImage 的代码:</del>

```objc
+ (YYImage *)imageNamed:(NSString *)name {
    if (name.length == 0) return nil;
    if ([name hasSuffix:@"/"]) return nil;
    
    NSString *res = name.stringByDeletingPathExtension;
    NSString *ext = name.pathExtension;
    NSString *path = nil;
    CGFloat scale = 1;
    
    // If no extension, guess by system supported (same as UIImage).
    NSArray *exts = ext.length > 0 ? @[ext] : @[@"", @"png", @"jpeg", @"jpg", @"gif", @"webp", @"apng"];
    NSArray *scales = [NSBundle preferredScales];
    for (int s = 0; s < scales.count; s++) {
        scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = [res stringByAppendingNameScale:scale];
        for (NSString *e in exts) {
            path = [[NSBundle mainBundle] pathForResource:scaledName ofType:e];
            if (path) break;
        }
        if (path) break;
    }
    if (path.length == 0) return nil;
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) return nil;
    
    return [[self alloc] initWithData:data scale:scale];
}
```


<del>从代码可以看出 `[YYImage imageNamed:]`这个方法底层是利用通过一定的计算获取到最佳尺寸, 然后枚举图片匹配图片文件名, 拼接成路径后利用`NSData`创建出`UIImage`. 本质上和`imageWithContentsOfFile:`没有啥区别.</del>

# UIImage <del>与 YYImage</del> 的内存问题
### Resource 的缺点

当我们需要图片的时候就会去沙盒中读取这个图片文件, 转换成`UIImage`对象来使用. 现在假设一种场景:

> 1. image@2x.png 图片占用 5kb 的内存
> 2. image@2x.png 在多个界面都用到, 且有7处会同时显示这个图片

通过代码分析就可以知道 Resource 这个方式在这个情景下会占用 **5kb/个 X 7个 = 35kb** 内存. 然而, 在 ImageAssets 方式下, 全部取自字典缓存中的`UIImage`, 无论有几处显示图片, 都只会占用 **5kb/个 X 1个 = 5kb** 内存. 此时 Resource 占用内存将会更大.

<del>由于 YYImage 的核心就是利用`imageWithContentsOfFile:`代替`imageNamed:`, 所以这也是 YYImage 的缺陷之处</del>

### ImageAssets 的缺点

第一次读取的图片保存到缓冲区, 然后永不销毁. 如果这个图片过大, 占用几百 kb, 这一块的内存将不会释放, 必然导致内存的浪费, 而且这个浪费的周期与APP的生命周期同步.

# 解决方案

为了解决 Resource 的多图共存问题, 可以学习 ImageAssets 中的字典来形成键值对, 当字典中`name`对应的`image`存在就不创建, 如果不存在就创建. 字典的存在必然导致 UIImage 永不销毁, 所以还要考虑字典不会影响到 UIImage 的自动销毁问题. 由此可以做出如下总结:

1. 需要一个字典存储已经创建的 Image 的 name-image 映射
2. 当除了这个字典外, 没有别的对象持有 image, 则从这个字典中删除对应 name-image 映射

第一个要求的实现方式很简单, 接下来探讨第二个要求.

首先可以考虑如何判断**除了字典外没有别的对象持有 image**? 字典是强引用 key 和 value 的, 当 image 放入字典的时候, image 的引用计数器就会 + 1. 我们可以判断字典中的 image 的引用计数器是否为 1, 如果为 1 则可以判断出目前只有字典持有这个 image, 因此可以从这个字典里删除这个 image.

这样即可提出一个方案 **MRC+字典**

我们还可以换一种思想, 字典是强引用容器, 字典存在必然导致内部value的引用计数器大于等于1. 如果字典是一个弱引用容器, 字典的存在并不会影响到内部value的引用计数器, 那么 image 的销毁就不会因为字典而受到影响.

于是又有一个方案 **弱引用字典**

接下来对这两个方案作深入的分析和实现:

## 方案一之 MRC+字典

该方案具体思路是: 找到一个合适的时机, 遍历所有 value 的 引用计数器, 当某个 value 的引用计数器为 1 时候(说明只有字典持有这个image), 则删除这个key-value对.

### 第一步, 在ARC下获取某个对象的引用计数器:

首先 ARC 下是不允许使用`retainCount`这个属性的, 但是由于 ARC 的原理是编译器自动为我们管理引用计数器, 所以就算是 ARC 环境下, 引用计数器也是 Enable 状态, 并且仍然是利用引用计数器来管理内存. 所以我们可以使用 KVC 来获取引用计数器:

```objc
@implementation NSObject (MRC)

// 无法直接重写 retainCount 的方法, 所以加了一个前缀
- (NSUInteger)obj_retainCount {
	return [[self valueForKey:@"retainCount"] unsignedLongValue];
}

@end

```

### 第二步 遍历 value的引用计数器

```objc
// 由于遍历键值对时候不能做添加和删除操作, 所以把要删除的key放到一个数组中
NSMutableArray *keyArr = [NSMutableArray array];
[self.imageDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSObject * _Nonnull obj, BOOL * _Nonnull stop) {
	NSInteger count = obj.obj_retainCount;
	if(count == 2) {// 字典持有 + obj参数持有 = 2
		[keyArr addObject:key];
	}
}];
[keyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
	[self.imageDic removeObjectForKey:obj];
}];
```

然后处理遍历时机. 选择遍历时机是一个很困难的, 不能因为遍历而大量占有系统资源. 可以在每一次通过 name 创建(或者从字典中获取)时候遍历一次, 但这个方法有可能会长时间不调用(比如一个用户在某一个界面上呆很久). 所以我们可以在每一次 runloop 到来时候来做一次遍历, 同时我们还需要标记遍历状态, 防止第二次 runloop 到来时候第一次的遍历还没结束就开始新的遍历了(此时应该直接放弃第二次遍历).代码如下:

```objc
CFRunLoopObserverRef oberver= CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
	if (activity == kCFRunLoopBeforeWaiting) {
		static enuming = NO;
		if (!enuming) {
			enuming = YES;
			// 这里是遍历代码
			enuming = NO;
		}
	}
});

CFRunLoopAddObserver(CFRunLoopGetMain(), oberver, kCFRunLoopCommonModes);
```

具体实现请看代码.

## 方案二之 弱引用字典

在上面那个方案中, 会在每一次 runloop 到来之时开辟一个线程去遍历键值对. 通常来说, 每一个 APP 创建的图片个数很大, 所以遍历键值对虽然不会阻塞主线程, 但仍然是一个非常耗时耗资源的工作.

**弱引用容器**是指基于`NSArray`, `NSDictionary`, `NSSet`的容器类, 该容器与这些类最大的区别在于, 将对象放入容器中并不会改变对象的引用计数器, 同时容器是以一个弱引用指针指向这个对象, 当对象销毁时自动从容器中删除, 无需额外的操作.

目前常用的弱引用容器的实现方式是**block封装解封**

利用block封装一个对象, 且block中对象的持有操作是一个弱引用指针. 而后将block当做对象放入容器中. 容器直接持有block, 而不直接持有对象. 取对象时解包block即可得到对应对象.

### 第一步 封装与解封

```objc

typedef id (^WeakReference)(void);

WeakReference makeWeakReference(id object) {
    __weak id weakref = object;
    return ^{
        return weakref;
    };
}

id weakReferenceNonretainedObjectValue(WeakReference ref) {
    return ref ? ref() : nil;
}

```
### 第二步 改造原容器

```objc
- (void)weak_setObject:(id)anObject forKey:(NSString *)aKey {
    [self setObject:makeWeakReference(anObject) forKey:aKey];
}

- (void)weak_setObjectWithDictionary:(NSDictionary *)dic {
    for (NSString *key in dic.allKeys) {
        [self setObject:makeWeakReference(dic[key]) forKey:key];
    }
}

- (id)weak_getObjectForKey:(NSString *)key {
    return weakReferenceNonretainedObjectValue(self[key]);
}
```

这样就实现了一个**弱引用字典**, 之后用弱引用字典代替`imageNamed:`中的强引用字典即可.
