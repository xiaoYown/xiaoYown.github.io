1. 安装 selenium：

```
pip install selenium
```

2. 安装 chromedriver

[淘宝镜像](https://npm.taobao.org/mirrors/chromedriver/)


3. 添加 chromedriver 到 bin

```
sudo mv ~/Downloads/chromedriver /usr/local/bin
```

4. 测试 chrome 调用

```
from selenium import webdriver

driver = webdriver.Chrome()
url = 'http://127.0.0.1:84'
driver.get(url)
```

5. 解决 Chrome 出现 Your Connection is not private 问题

```
点击空白处
输入: thisisunsafe 或 badidea
code: driver.find_element_by_tag_name('body').send_keys('thisisunsafe')
```