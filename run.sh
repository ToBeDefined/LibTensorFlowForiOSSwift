
BASE_PATH=$(cd `dirname $0`; pwd)

TensorFlowZipName="tensorflow-1.2.1"

# install Homebrew 已经安装可以注释此部分
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

if [[ ! $? -eq 0 ]]; then
	echo "install Homebrew error"
	exit 1
fi
########################################################################################################################


# download tensorflow 已经下载可以注释此部分 zip包名字需要为TensorFlowZipName的值
curl -L -o $TensorFlowZipName.zip https://github.com/tensorflow/tensorflow/archive/v1.2.1.zip

if [[ ! $? -eq 0 ]]; then
	echo "download tensorflow error"
	exit 1
fi
########################################################################################################################


# unzip  已经解压可以注释此部分 文件夹名字最终为tensorflow
unzip $BASE_PATH/$TensorFlowZipName -d $BASE_PATH

if [[ ! $? -eq 0 ]]; then
	echo "unzip or download tensorflow error"
	exit 1
fi
# delete tensorflow folde and rename
rm -rf $BASE_PATH/tensorflow
mv $TensorFlowZipName tensorflow
########################################################################################################################


# install xcode-select
xcode-select --install

brew install automake

if [[ ! $? -eq 0 ]]; then
	echo "install automake error"
	exit 1
fi

brew install libtool

if [[ ! $? -eq 0 ]]; then
	echo "install libtool error"
	exit 1
fi
########################################################################################################################



# change  TensroFlow Kernel Error 

# add to 	file `/tensorflow/tensorflow/core/kernels/cwise_op_add_1.cc`
# 			line `22`
Kernel_Add_CC="${BASE_PATH}/tensorflow/tensorflow/core/kernels/cwise_op_add_1.cc"
Kernel_Add_CC_Code="\
#if defined(__ANDROID_TYPES_SLIM__)\\
REGISTER(BinaryOp, CPU, \"Add\", functor::add, int32);\\
#endif  // __ANDROID_TYPES_SLIM__\\
\\"

echo "Kernel_Add_CC_Code is :\n"
echo $Kernel_Add_CC_Code


sed -i '' "22i\\
${Kernel_Add_CC_Code}
" $Kernel_Add_CC

# add to 	file `/tensorflow/tensorflow/core/kernels/cwise_op_less.cc`
# 			line `21`
Kernel_Less_CC="${BASE_PATH}/tensorflow/tensorflow/core/kernels/cwise_op_less.cc"
Kernel_Less_CC_Code="\
\\
#if defined(__ANDROID_TYPES_SLIM__)\\
REGISTER(BinaryOp, CPU, \"Less\", functor::less, int32);\\
#endif  // __ANDROID_TYPES_SLIM__\\
\\"
echo "Kernel_Less_CC_Code is :\n"
echo $Kernel_Less_CC_Code

sed -i '' "21i\\
${Kernel_Less_CC_Code}
" $Kernel_Less_CC

########################################################################################################################



# 编译TensorFlow
sh tensorflow/tensorflow/contrib/makefile/build_all_ios.sh

if [[ ! $? -eq 0 ]]; then
	echo "compail tensorflow error"
	exit 1
fi
########################################################################################################################


# 打开项目
open -a "Xcode" LibTensorFlowForiOSSwift.xcodeproj

exit 0


