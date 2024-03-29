## 1. 字体标准

| 字体标准                 | 后缀                   |
| ------------------------ | ---------------------- |
| TrueType                 | .ttf                   |
| OpenType                 | .otf, .ttf, .otc, .ttc |
| Web Open Font Format     | .woff                  |
| Embedded Open Type       | .eot                   |
| Scalable Vector Graphics | .svg                   |

### 1.1 TrueType

TrueType 是由美国苹果公司和微软公司共同开发的一种电脑轮廓字体(曲线描边字)类型标准.
这种类型字体文件的扩展名是 .ttf, 类型代码是 tfil.
TrueType 的主要强项在于它能给开发者提供关于字体显示、不同字体大小的像素级显示等的高级控制.

### 1.2 OpenType

penType 是 Adobe 和 Microsoft 联合开发的跨平台字体文件格式, 也叫 Type 2 字体, 它的字体格式采用 Unicode 编码, 是一种兼容各种语言的字体格式.
OpenType 也是一种轮廓字体, 比 TrueType 更为强大, 并且还支持多个平台, 支持很大的字符集, 还有版权保护.可以说它是 Type 1 和 TrueType 的超集.
OpenType 标准定义了 OpenType 文件名称的后缀名:

- 包含 TrueType 字体的 OpenType 文件后缀名为 .ttf.
- 包含 PostScript 字体的文件后缀名为 .OTF.
- 如果是包含一系列 TrueType 字体的字体包文件, 那么后缀名为 .TTC.

OTF 的主要优点有:

- 增强的跨平台功能;
- 更好的支持 Unicode 标准定义的国际字符集;
- 支持高级印刷控制能力;
- 生成的文件尺寸更小;
- 支持在字符集中加入数字签名, 保证文件的集成功能.

同一个 OpenType 字体文件可以用于 Mac OS, Windows 和 Linux 系统, 这种跨平台的字库非常方便于用户的使用, 用户再也不必为不同的系统配制字库而烦恼了.
OTF 的兼容性和 TTF 相同.

### 1.3 Web Open Font Format

Web 开放字体格式是一种网页所采用的字体格式标准.此字体格式发展于 2009 年, 现在正由万维网联盟的 Web 字体工作小组标准化, 以求成为推荐标准.
此字体格式不但能够有效利用压缩来减少档案大小, 并且不包含加密也不受 DRM(数位著作权管理)限制.
WOFF 本质上是包含了基于 sfnt 的字体(如 TrueType、OpenType 或开放字体格式), 且这些字体均经过 WOFF 的编码工具压缩, 以便嵌入网页中.这个字体格式使用 zlib 压缩, 文件大小一般比 TTF 小 40%.

WOFF 2 标准在 WOFF1 的基础上, 进一步优化了体积压缩, 带宽需求更少, 同时可以在移动设备上快速解压.

与 WOFF 1.0 中使用的 Flate 压缩相比, WOFF 2.0 是使用 Brotli 方法进行的压缩, 压缩率更高, 所以文件体积更小.

### 1.4 Embedded Open Type

EOT (Embedded Open Type) 字体是微软设计用来在 Web 上使用的字体. 是一个在网页上试图绕过 TTF 和 OTF 版权的方案. 你可以使用微软的工具从现有的 TTF/OTF 字体转成 EOT 字体使用, 其中对字体进行压缩和裁剪使得文件体积更小. 同时为了避免一些收版权保护的字体被随意复制, EOT 还集成了一些特性来阻止复制行为, 以及对字体文件进行加密保护. 听起来很有前途？嗯哼, 可惜 EOT 格式只有 IE 支持.

### 1.5 Scalable Vector Graphics

SVG (Scalable Vector Graphics font) 字体格式使用 SVG 的字体元素定义. 这些字体包含作为标准 SVG 元素和属性的字形轮廓, 就像它们是 SVG 映像中的单个矢量对象一样. SVG 字体最大的缺点是缺少字体提示（font-hinting）. 字体提示是渲染小字体时为了质量和清晰度额外嵌入的信息. 同时, SVG 对文本（body text）支持并不是特别好. 因为 SVG 的文本选择（text selection）目前在 Safari、Safari Mobile 和 Chrome 的一些版本上完全崩坏, 所以你不能选择单个字符、单词或任何自定义选项, 你只能选择整行或段落文本.

然而, 如果你的目标是 iPhone 和 iPad 用户, 需要说 SVG 字体是 iOS 上 Safari 4.1 以下唯一允许的字体格式.

## 2. 字体类型

常见的字体可以分为“衬线(serif)”、“无衬线(sans serif)”、“等宽(monospace)”等类型.衬线是指在字体笔画末端有小装饰.在论文写作中常用的 Times New Roman 字体和中文宋体便是衬线字体.无衬线字体的字体线条则相对简约, 例如 Arial 和“微软雅黑”以及“苹方”.等宽字体则表示每个字符占据相等的宽度, 这一点衬线和无衬线字体是无法保证的, 例如小写字母 i 在非等宽字体中往往占据较小的字宽.

由于衬线字体具有更丰富的细节且更加精致, 所以多用于印刷和高清显示.无衬线字体在屏幕显示上更加普遍, 主流浏览器和操作系统的默认字体一般都是无衬线字体.但随着屏幕分辨率的提高和显示技术的提升, 在屏幕显示中使用衬线字体可以使文本页面更加精致具备设计感.

## 3. 字体家族 Font Family

前文提到的诸如“Times New Roman“, “微软雅黑”等字体其实都是字体家族的概念.字体家族代表了统一的设计风格, 但字体往往需要不同的粗细(字重)和样式(斜体、字宽等).因此一个字体家族可以包含不同的子字体来实现不同的字体样式.具体地, 字体样式包括字重、字宽、倾斜和视觉尺寸等方面, 通过这些样式的组合便产生不同的子字体.但除非特别需要, 对于屏幕显示来说常用的子字体样式一般只包括字重和倾斜.例如, 苹方字体家族字体包括常规体(Regular)、极细体(Ultralight)、纤细体(Thin)、细体(Light)、中黑体(Medium)和中粗体(Semibold)6 个子字体.当然也有一些发布较早的字体只包含一种样式, 即一个字体文件.

当我们使用文字处理软件或者 CSS 属性对字体应用“加粗”和“倾斜”等样式时, 系统会查找对应样式的子字体是否可用, 如果可用则使用对应的子字体, 否则则通过计算对字体进行强制的加粗和倾斜.虽然这两种方式最终都将字体进行了加粗或倾斜, 但效果是完全不一样的.子字体不同的样式通过了严格的设计, 使其具备统一的美感.而后者只是简单粗暴的加粗或倾斜, 视觉效果往往比不上前者.例如, 下图中分别使用思源宋体的常规体进行计算加粗(上)和直接使用思源宋体的 Bold 字体(下), 可以明显看出上面的文字在细节和观感上相去甚远.

## 4. 可变字体(Variable Font)

一款优秀的字体会提供多种字重的子字体, 这样能保证在使用不同字重时能够保持优秀的观感.但每一款单独的字重或样式的字体往往需要单独的字体文件, 这导致了当字体样式变多时字体文件数量增加, 尤其对于网络页面来说会增加请求次数和流量负担.

为了解决这一问题, 在 OpenType 规范的中, Adobe、微软、苹果和谷歌于 2016 年共同推出了可变字体(Variable font)的标准, 这一标准改变了字体样式的设计和使用[5].就字重来说, 不再需要多个字重的字体文件, 一个字体文件即可使用多种字重.并且, 字体字重不再被离散的划分为“常规”, “中黑”等有限的个数, 而是能够通过调整字重参数获得任意粗细, 实现字重的无级调节.

OpenType 要求可变字体文件需要在命名使用 VF 标注, 例如 Selawik-VF.ttf. 因此我们从字体文件名往往可以分辨该字体是否是可变字体.

## 5. 默认字体名称

CSS 属性 font-family 用于指定字体, 并且规定了 5 种默认的字体名称：serif, sans-serif, monospace, cursive, fantasy, 除了前面提到的 3 种字体, cursive 和 fantasy 分别表示手写字体和装饰字体. 当使用这些默认字体名称时, 具体使用何种字体是由浏览器决定的, 往往也会根据操作系统的不用有所不同. 以下是五种默认字体在当前浏览器的显示效果：

| font-family | 显示效果                                                                            |
| ----------- | ----------------------------------------------------------------------------------- |
| serif       | <font style="font-family: serif;">这是衬线字体 This is serif font<font>             |
| sans-serif  | <font style="font-family: sans-serif;">这是无衬线字体 This is sans serif font<font> |
| monospace   | <font style="font-family: monospace;">这是等宽字体 This is monospace font<font>     |
| cursive     | <font style="font-family: cursive;">这是手写字体 This is cursive font<font>         |
| fantasy     | <font style="font-family: fantasy;">这是装饰字体 This is fantasy font<font>         |

虽然使用默认的字体属性可能会造成跨平台字体表现不一致的情况, 但对于大多数功能性网页来说不必过分担心, 因为在主流平台中字体经过了严格设计, 规范性和易用性是完全经得住考验的.

## 6. Weights

| Value | Name        |
| ----- | ----------- |
| 100   | Thin        |
| 200   | Ultra Light |
| 300   | Light       |
| 400   | Normal      |
| 500   | Medium      |
| 600   | Semi Bold   |
| 700   | Bold        |
| 800   | Ultra Bold  |
| 900   | Heavy       |

## 7. 网络安全字体

前文提到, 在不同的浏览器和操作系统中网页的默认字体会有所不同. 当对页面有跨平台时保持字体统一的要求时, 可以使用“网络安全字体“, 安全字体即挑选出在主流平台都默认安装的字体, 来保证跨平台时字体的可用性.

以下是拉丁文字体的网络安全字体：

| 字体名称        | 泛型       | 注意                                             |
| --------------- | ---------- | ------------------------------------------------ |
| Arial           | sans-serif | 使用 Helvetica 作为 Arial 首选替代               |
| Georgia         | serif      |                                                  |
| Times New Roman | serif      | 使用 Times 作为 Times New Roman 的首选替代方案   |
| Courier New     | monospace  | 使用 Courier 作为 Courier New 的首选替代方案     |
| Trebuchet MS    | sans-serif | 应该小心使用这种字体——它在移动操作系统上并不广泛 |
| Verdana         | sans-serif |                                                  |

其中“首选替代方案”往往是因为同一款字体的不同版本在新旧操作系统上安装情况或名称不一致, 使用字体栈包含各种可能的名称来保证可用性.

## 参考文献

- [TTF、TOF、WOFF 和 WOFF2 的相关概念](https://juejin.cn/post/7059026988941443085)
- [前端工程师需要知道的字体知识](https://www.hozen.site/archives/64/)
- [Web 字体简介: TTF, OTF, WOFF, EOT & SVG](https://zhuanlan.zhihu.com/p/28179203)
- [字体支持查询](https://caniuse.com/?search=WOFF2)
