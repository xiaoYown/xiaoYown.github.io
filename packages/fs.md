### 目录/文件判断

```ts
import { statSync } from "fs";

export const isFolder = (name: string): boolean => {
  try {
    const stats = statSync(name);
    return stats.isDirectory();
  } catch (_error) {
    return false;
  }
};

export const isFile = (name: string): boolean => {
  try {
    const stats = statSync(name);
    return !stats.isDirectory();
  } catch (_error) {
    return false;
  }
};
```

```js
const fs = require("fs");
const path = require("path");

/**
 * 完全删除文件夹
 * @param {String} _path - 文件夹路径
 * @param {Function} callback - 回调
 */
function folderDelete(_path) {
  return new Promise((resolve) => {
    if (fs.existsSync(_path)) {
      let dirLs = fs.readdirSync(_path).map((file) => {
        return {
          name: file,
          isDelete: false,
        };
      });
      dirLs.forEach((fileInfo) => {
        let curPath = path.join(_path, "./" + fileInfo.name);

        if (fs.statSync(curPath).isDirectory()) {
          folderDelete(curPath).then(() => {
            fileInfo.isDelete = true;
            if (!dirLs.find((__file) => !__file.isDelete)) {
              fs.rmdir(_path, resolve);
            }
          });
        } else {
          fs.unlink(curPath, () => {
            fileInfo.isDelete = true;
            if (!dirLs.find((__file) => !__file.isDelete)) {
              fs.rmdir(_path, resolve);
            }
          });
        }
      });
    }
  });
}

function folderMk(folder) {
  return new Promise((resolve) => {
    let isPathToExist = fs.existsSync(folder);
    if (!isPathToExist || !fs.statSync(folder).isDirectory()) {
      fs.mkdir(folder, resolve);
    } else {
      resolve();
    }
  });
}

/**
 * 文件夹完整复制
 * @param {String} pathFrom - 源文件目录名
 * @param {String} pathTo - 拷贝目标路径
 * @param {Function} callback - 拷贝成功回调
 */
function folderCopy(pathFrom, pathTo) {
  return new Promise((resolve) => {
    if (fs.existsSync(pathFrom) && fs.statSync(pathFrom).isDirectory()) {
      folderMk(pathTo).then(() => {
        let dirLs = fs.readdirSync(pathFrom).map((file) => {
          return {
            name: file,
            isCopyed: false,
          };
        });
        dirLs.forEach((fileInfo) => {
          let originPath = path.join(pathFrom, "./" + fileInfo.name);
          let targetPath = path.join(pathTo, "./" + fileInfo.name);

          if (fs.statSync(originPath).isDirectory()) {
            folderCopy(originPath, targetPath).then(() => {
              fileInfo.isCopyed = true;
              if (!dirLs.find((__file) => !__file.isCopyed)) {
                resolve();
              }
            });
          } else {
            fileInfo.isCopyed = true;
            fs.copyFile(originPath, targetPath, null, () => {
              if (!dirLs.find((__file) => !__file.isCopyed)) {
                resolve();
              }
            });
          }
        });
      });
    }
  });
}

module.exports = {
  folderDelete,
  folderCopy,
};
```
