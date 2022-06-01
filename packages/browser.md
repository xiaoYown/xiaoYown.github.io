### 剪切板事件 - ClipboardEvent

[ClipboardEvent](https://microsoft.github.io/PowerBI-JavaScript/interfaces/_node_modules_typedoc_node_modules_typescript_lib_lib_dom_d_.clipboardevent.html)

> event.clipboardData

- setData( format, data )
  - 设置剪切板中指定格式的数据
  - 只能在 copy / cut 时进行设置
- getData( format )
  - 获取剪切板中指定格式的数据
  - 只能在 paste 时获取
- clearData( format )
  - 删除剪切板中指定格式的数据

```ts
function copyIntercept(event: ClipboardEvent) {
  event.clipboardData?.setData("text/plain", "Hello, copy!");
  event.preventDefault();
}

function cutIntercept(event: ClipboardEvent) {
  event.clipboardData?.setData("text/plain", "Hello, cut!");
  event.preventDefault();
}

function pasteIntercept(event: ClipboardEvent) {
  function imgReader(_item: DataTransferItem) {
    // 图片文件
    // const file = _item.getAsFile();
  }
  const { clipboardData } = event;
  let i = 0;
  let items: DataTransferItemList;
  let item;
  let types;

  if (clipboardData) {
    items = clipboardData.items;

    if (!items) {
      return;
    }

    [item] = items;
    types = clipboardData.types || [];

    for (; i < types.length; i += 1) {
      if (types[i] === "Files") {
        item = items[i];
        break;
      }
    }
    if (item && item.kind === "file" && item.type.match(/^image\//i)) {
      // 图片对象
      imgReader(item);
    } else if (item && item.kind === "file" && item.type === "text/plain") {
      // 文本对象
      // const text = clipboardData.getData('text');
    }
  }
}

document.addEventListener("paste", copyIntercept);
document.addEventListener("copy", cutIntercept);
document.addEventListener("cut", pasteIntercept);
```

### SVG 转 canvas

```ts
interface ConvertOptions {
  width: number;
  height: number;
  svg: SVGAElement;
}

function convert(options: ConvertOptions): Promise<HTMLCanvasElement> {
  return new Promise((resolve, reject) => {
    const { width, height, svg } = options;
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    const image = new Image();

    image.onload = () => {
      canvas.width = width;
      canvas.height = height;

      ctx?.drawImage(image, 0, 0, width, height);
      resolve(canvas);
    };
    image.onerror = (error: string | Event) => {
      reject(error);
    };
    image.src = `data:image/svg+xml;charset-utf-8,${encodeURIComponent(
      svg.outerHTML
    )}`;
  });
}

// Usage
convert(
  {
    width: 300,
    height: 300,
    svg: document.querySelector("svg"),
  },
  (canvas) => {
    const base64 = canvas.toDataURL("image/png");
  }
);
```

### 禁止浏览器缩放

```ts
window.addEventListener("wheel", () => {});
```
