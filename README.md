# HXImage

如有疑问请: [@冷秋](http://www.weibo.com/magicunique) [@Forever波波哥哥](http://weibo.com/u/2336714285)

## Usage 使用

选择任意 Plan 目录, 导入到工程中:

### 导入头文件
```objc
#import "UIImage+HXImage.h"
```

### 创建图片

使用该方法, 对于重复创建的ImageName仅仅只会创建一个 UIImage 对象, 对于不需要的Image会自动销毁.

```objc
UIImage *image = [UIImage hx_imageNamed:@"image"];
```