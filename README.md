# HXImage

A automatically reference manager for icon image.

自动创建销毁图片资源

[中文说明](https://www.jianshu.com/p/5be5febe73ac)

Author: [@冷秋](http://www.weibo.com/magicunique) [@Forever波波哥哥](http://weibo.com/u/2336714285)

## Usage 使用

### CocoaPods

```ruby
pod 'HXImage'
```

```objc
#import <HXImage.h>
```

If you import HXImage with CocoaPods, the Plan-C will be used.

使用 CocoaPods 会自动导入 Plan C 目录

### Source

Drag any *Plan* folder(Plan C for best) into your project.

选择任意 Plan 目录(推荐 Plan C), 导入到工程中:

```objc
#import "UIImage+HXImage.h"
```

### Release Your Image File

HXImage is not supporting image in Assets.car. So you must release your image to the main bundle.

HXImage 不支持 Assets.car 中的文件，所以你必须把图片文件放到 Bundle 中。

### Create UIImage Instance

Create an UIImage instance.

创建 UIImage 对象

```objc
// default
UIImage *image = [UIImage hx_imageNamed:@"image"];

// in special folder
UIImage *image = [UIImage hx_imageNamed:@"image" inDirectory:@"Documents"];

// contents of file
UIImage *image = [UIImage hx_imageWithContentsOfFile:@"path/to/image"];
```

* **The *image* will be dealloc atomically if there is not any reference to the instance.**
* **当没有任何引用到 *image* 对象时，该对象会自动销毁**

```objc
// default
UIImage *image = [UIImage hx_imageNamed:@"image"];
image = nil; // call -[UIImage dealloc]
```
 
* **The same image will not be created
before dealloc.**
* **在旧的图片销毁之前，重复取相同名字的图片，不会用到多余的内存**

```objc
//	repeat creating
UIImage *image = [UIImage hx_imageNamed:@"image"];
UIImage *newImage = [UIImage hx_imageNamed:@"image"]; // image == newImage
image = nil;
newImage = nil; //	call -[UIImage dealloc]
```