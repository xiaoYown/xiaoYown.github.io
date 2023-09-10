### svg 转 canvas

```js
/**
 * img_h  生成 img 宽高
 * img_w  
 * el_h   元素宽高
 * el_w 
 */
function convert(option, cb) {
  var canvas = document.createElement('canvas');
  var ctx = canvas.getContext('2d');
  var image = new Image();

  image.onload = function load() {
    canvas.height = option.img_h;
    canvas.width  = option.img_w;

    ctx.drawImage(image, (option.img_w - option.el_w)/2, (option.img_h - option.el_h)/2, option.el_w, option.el_h);
    cb(canvas);
  };
  image.src = 'data:image/svg+xml;charset-utf-8,' + encodeURIComponent(option.svg.outerHTML);
};
convert(option, function(canvas) {
  _this.postStyle.call(_this, {
    img: canvas.toDataURL(), 
    name, 
    data, 
    type, 
    typeSub
  });
});
```