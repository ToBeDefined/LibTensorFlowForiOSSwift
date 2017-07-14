# LibTensorFlowForiOSSwift


changed by [`emoji-tf-ios`](https://github.com/h4x3rotab/emoji-tf-ios)

use `emoji_frozen.pb` model from `emoji-tf-ios`


### how to run

- open terminal and go to project root folder

- input `sh run.sh`. 

In the end, will automatically open Xcode 

you can run the project now

### about `run.sh`

it will compile the `TensorFlow for iOS` automatically

### about project setting 
> how to import TensorFlow in ios project


- download TensorFlow to the root folder and compile

- about `libtensorflow-core.a`
	- in `Other Link Flags` add `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/gen/lib/libtensorflow-core.a`
	- in `Library Search Paths` add `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/gen/lib`

- about `libprotobuf.a & libprotobuf-lite.a`
	- in `Build Phases | Link Binary With Libraries` add `libprotobuf.a & libprotobuf-lite.a` (path: `tensorflow/tensorflow/contrib/makefile/gen/protobuf_ios/lib/`)
	- in `Library Search Paths` add `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/gen/protobuf_ios/lib` 

- in `Header Search Paths` add flows
	- `$(SRCROOT)/tensorflow/`
	- `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/downloads/protobuf/src/`
	- `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/downloads`
	- `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/downloads/eigen`
	- `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/gen/proto`

- in `Other Link Flags` add `-force_load`

- in `Build Phases | Link Binary With Libraries` add `Accelerate.framework`

- in `C++ Language Dialect` select `GNU++11` or `GNU++14`

- in `C++ Standard Library` select `libc++`

- `Enable Bitcode` set `No`

- remove any `-all_load` ，use `-ObjC` replace it
	> Remove any use of the `-all_load` flag in your project. The protocol buffers libraries (full and lite versions) contain duplicate symbols, and the `-all_load` flag will cause these duplicates to become link errors. If you were using `-all_load` to avoid issues with Objective-C categories in static libraries, you may be able to replace it with the `-ObjC` flag.

- suppress TensorFlow warning：
	- in `Other C Flags` & `Other C++ Flags` add `-isystem $(SRCROOT)/tensorflow`


### reference:
- compile TensorFlow:https://github.com/tensorflow/tensorflow/tree/master/tensorflow/contrib/makefile

- import TensorFlow to iOS:https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/ios/README.md

- suppress warning of TensorFlow:https://clang.llvm.org/docs/UsersManual.html%23id27


# 中文介绍

在 [`emoji-tf-ios`](https://github.com/h4x3rotab/emoji-tf-ios)基础上进行修改；

使用了`emoji-tf-ios` 的 `emoji_frozen.pb` 模型

### 如何运行

- 打开终端进入项目的根目录

- 输入 `sh run.sh` 运行

最后会自动的打开Xcode，此时应该可以运行项目

### 关于 `run.sh` 

run.sh会自动的编译 `TensorFlow for iOS`

### 关于项目配置
> 如何在iOS项目中导入TensorFlow


- 下载TensorFlow到项目根目录并编译

- `libtensorflow-core.a`
	- `Other Link Flags` 中加入 `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/gen/lib/libtensorflow-core.a`
	- `Library Search Paths` 中加入 `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/gen/lib`

- `libprotobuf.a & libprotobuf-lite.a`
	- `Build Phases | Link Binary With Libraries` 中加入 `libprotobuf.a & libprotobuf-lite.a` (path: `tensorflow/tensorflow/contrib/makefile/gen/protobuf_ios/lib/`)
	- `Library Search Paths` 中加入 `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/gen/protobuf_ios/lib` 

- `Header Search Paths`中加入
	- `$(SRCROOT)/tensorflow/`
	- `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/downloads/protobuf/src/`
	- `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/downloads`
	- `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/downloads/eigen`
	- `$(SRCROOT)/tensorflow/tensorflow/contrib/makefile/gen/proto`

- `Other Link Flags` 中加入 `-force_load`

- `Build Phases | Link Binary With Libraries` 中加入 `Accelerate.framework`

- `C++ Language Dialect` 设置为 `GNU++11` or `GNU++14`

- `C++ Standard Library` 设置为 `libc++`

- `Enable Bitcode` 设置为 `No`

- 删除所有使用的 `-all_load` ，替换为 `-ObjC`
	> Remove any use of the `-all_load` flag in your project. The protocol buffers libraries (full and lite versions) contain duplicate symbols, and the `-all_load` flag will cause these duplicates to become link errors. If you were using `-all_load` to avoid issues with Objective-C categories in static libraries, you may be able to replace it with the `-ObjC` flag.

- 忽略TensorFlow编译的警告：
	- 在`Other C Flags` & `Other C++ Flags`中加入`-isystem $(SRCROOT)/tensorflow`




### 参考：
- 编译TensorFlow：https://github.com/tensorflow/tensorflow/tree/master/tensorflow/contrib/makefile

- 项目中导入TensorFlow静态库：https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/ios/README.md

- 忽略TensorFlow警告：https://clang.llvm.org/docs/UsersManual.html%23id27