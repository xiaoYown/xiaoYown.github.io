## 1. 学习要点

### 1.1 原理简析

### 1.2 软件安装

### 1.3 文图生成基本逻辑

### 1.4 提示词使用方法

**人物及主体特征**

1. 服饰穿搭(white dress)
2. 发型发色(blonde hair, long hair)
3. 五官特征(small eyes, big mouth)
4. 面部表情(smiling)
5. 肢体动作(stretching arms)

**场景特征**

1. 室内/室外(indoor, outdoor)
2. 大场景(forest, city, street)
3. 小细节(tree, bush, white flower)

**环境光照**

1. 白天黑夜(day/night)
2. 特定时段(morning, sunset)
3. 光环境(sunlight, bright, dark)
4. 天空(blue sky, starry sky)

**补充: 画幅视角**

1. 距离(close-up, distant)
2. 人物比例(full body, upper body)
3. 观察视角(from above, view of back)
4. 镜头类型(wide angle, Sony A7 III)

**画质**

1. 通用高画质(best quality, ultra-detailed, masterpiece, hires 8k)
2. 特定高分辨率(extremely detailed CG unity 8k wallpaper - 超精细的 8k Unity 游戏 CG, unreal engine rendered - 虚幻引擎渲染)

**画风**

1. 插画风(illustration, painting, paintbrush)
2. 二次元(anime, comic, game CG)
3. 写实系(photorealistic, realistic, photograph)

**权重**

1. 给提示提加 "()", 每多加一个 "()" 提示词的权重 \*1.1
2. "()" + ":", 分号后面为指定权重, eg: (white flower:1.5)

### 1.5. 生成图的基本参数设置(尺寸, 采样步数, 采样方法, CFGScale 等)

### 1.6 批量初入处理(批次/单批个数)

### 1.7 负面提示词的影响

### 1.8 提示词简单入门

#### 提示词魔咒

正向提示词:
```
(masterpiece: 1,2), best quality, masterpiece, highres, original, extremely detailed wallpaper, perfect lighting. (extremely detailed CG:1.2), drawing, paintbrush,
```

反向提示词:
```
NSFW, (worst quality:2), (low quality:2), (normal quality:2), lowres, normal quality, ((monochrome)). ((grayscale)), skin spots, acnes, skin blemishes, age spot, (ugly:1.331), (duplicate:1.331), (morbid:1.21), (mutilated:1.21), (tranny:1.331), mutated hands, (poorly drawn hands:1.5), blurry, (bad anatomy:1.21), (bad proportions:1.331), extra limbs, (disfigured:1.331), (missing arms:1.331), (extra legs:1.331), (fused fingers:1.61051), (too many fingers:1.61051), (unclear eyes:1.331), lowers, bad hands, missing fingers, extra digit,bad hands, missing fingers, ((extra arms and legs))),
```
### 1.9 采样方法

> 带 + 号的为改进过的算法, 内容生成更为稳定

- Euler - 插画风格, 出图朴素
- DPM 2M/2M Karras - 速度快
- SDE Karras - 细节丰富

## 2. models

### 2.1 checkpoint

### 2.2 lora

### 2.3 embedding

### 2.4 hypernetwork

## 3. extensions

### 3.1 必装扩展

### 3.2 推荐扩展

### 抄作业

[Stable Diffusion 的 AIGC 社区](https://civitai.com/)
[arthub](https://arthub.ai/)
[mage](https://www.mage.space/explore)


