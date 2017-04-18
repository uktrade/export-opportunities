# path-format

> Node.js [`path.format(pathObject)`](https://nodejs.org/api/path.html#path_path_format_pathobject) polyfill.

## Install

```
$ npm install --save path-format
```

## Usage

```js
var pathFormat = require('path-format');

pathFormat({
    root : "/",
    dir : "/home/user/dir",
    base : "file.txt",
    ext : ".txt",
    name : "file"
})
//=> '/home/user/dir/file.txt'
```

## API

### pathFormat(path)

See [`path.format(pathObject)`](https://nodejs.org/api/path.html#path_path_format_pathobject) docs.

### pathFormat.posix(path)

The Posix specific version.

### pathFormat.win32(path)

The Windows specific version.
