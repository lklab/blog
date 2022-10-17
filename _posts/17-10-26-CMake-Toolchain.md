---
title: cmake에서 툴체인 사용하기
image: /assets/post/17-10-26-CMake-Toolchain/chain.jpg
author: khlee
categories:
    - Build system
layout: post
---

[지난 번](https://lklab.github.io/blog/blog/cmake/)에는 cmake를 사용하여 서로 다른 플랫폼에서 빌드하는 방법을 알아보았는데, 이번엔 한 플랫폼에서 다른 플랫폼 실행 파일을 크로스 컴파일하는 방법을 알아볼 것이다.

예제로, 데스크탑 PC(x86_64 Ubuntu 16.04)에서 ARM Linux 실행 파일을 크로스 컴파일해 볼 것이다.

먼저 툴체인을 받아와서 압축을 해제한다.

{% highlight bash %}
$ wget https://releases.linaro.org/components/toolchain/binaries/latest/arm-linux-gnueabihf/gcc-linaro-7.1.1-2017.08-x86_64_arm-linux-gnueabihf.tar.xz
$ tar xf gcc-linaro-7.1.1-2017.08-x86_64_arm-linux-gnueabihf.tar.xz
{% endhighlight %}

원하는 버전의 다른 ARM 툴체인은 [여기](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)서 찾아볼 수 있다.

이제 toolchain.arm.cmake 라는 파일을 만들어서 내용을 다음과 같이 채워 넣는다.

{% highlight cmake %}
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_PROCESSOR arm)

SET(COMPILER_ROOT /root/cmake/gcc-linaro-7.1.1-2017.08-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-)

SET(CMAKE_C_COMPILER ${COMPILER_ROOT}gcc)
SET(CMAKE_CXX_COMPILER ${COMPILER_ROOT}g++)
SET(CMAKE_LINKER ${COMPILER_ROOT}ld)
SET(CMAKE_NM ${COMPILER_ROOT}nm)
SET(CMAKE_OBJCOPY ${COMPILER_ROOT}objcopy)
SET(CMAKE_OBJDUMP ${COMPILER_ROOT}objdump)
SET(CMAKE_RANLIB ${COMPILER_ROOT}ranlib)
{% endhighlight %}

이 파일은 툴체인의 경로(절대경로)를 명시하는 역할을 한다. 나중에 cmake를 실행할 때 이 파일을 입력해서 빌드시 사용할 툴체인을 지정해줄 수 있다. 첫 번째 줄의 `COMPILER_ROOT` 변수는 각자 환경에 맞게 수정하면 된다. 여기서는 앞에서 받아온 ARM 툴체인의 실행파일(gcc, ld 등)들의 경로를 지정하였다.

예제로 빌드할 소스코드(main.c)와 cmake 파일(CMakeLists.txt)를 작성한다.

main.c

{% highlight c %}
#include <stdio.h>

int main()
{
    printf("hello arm!\n");
    return 0;
}
{% endhighlight %}

CMakeLists.txt

{% highlight cmake %}
ADD_EXECUTABLE(App main.c)
{% endhighlight %}

이제 다음 명령어를 입력하면 빌드된다.

{% highlight bash %}
$ cmake -DCMAKE_TOOLCHAIN_FILE=toolchain.arm.cmake .
$ make
{% endhighlight %}

App 이라는 실행파일이 생성되었을 것이다. file 명령어를 통해 확인해 보면 잘 컴파일 된 것을 확인할 수 있다.

![build]({{site.suburl}}/assets/post/17-10-26-CMake-Toolchain/build.png)

이 파일을 ARM 플랫폼으로 (여기서는 raspberry pi에) 전송한 후에 실행한 화면이다.

![execute]({{site.suburl}}/assets/post/17-10-26-CMake-Toolchain/execute.png)
