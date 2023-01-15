---
title: Windows에서 ARM Linux 크로스 컴파일 환경 구성하기
image: /assets/post/17-10-27-ARM-Linux-Cross-Compile/satellite.jpg
image-source: https://unsplash.com/photos/8Hjx3GNZYeA
author: khlee
categories:
    - Build system
layout: post
---

IDE 등으로 배포하기 위해 Windows 플랫폼에서 ARM 크로스 컴파일 환경을 Standalone으로 구성하려고 한다.

## 준비하기

준비물 : mingw32 arm linux toolchain, cmake, mingw32-make

우선 작업을 위한 폴더를 만든다. 나는 D: 바로 아래에 arm이라는 폴더를 만들었다.
그 폴더 안에 다음 링크를 통해 받은 파일을 저장한다.

mingw32 arm liunux 툴체인 : [https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/](https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/)<br>
이 사이트에서 "gcc-linaro-\[버전\]-\[날짜\]-i686-mingw32_arm-linux-gnueabihf.tar.xz" 파일을 다운받는다.<br>
(다른 버전은 [여기](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads) 참조)

cmake : [https://cmake.org/files/v3.10/cmake-3.10.0-rc3-win64-x64.zip](https://cmake.org/files/v3.10/cmake-3.10.0-rc3-win64-x64.zip)<br>
(역시 다른 버전을 원하면 [여기](https://cmake.org/download/) 참조)

Standalone으로 구성하기 위해 cmake는 zip 파일로 내려받는다.

위 파일들을 받고 압축을 해제한다.

mingw32-make는 정식 경로에서 Standalone으로 받는 방법은 찾지 못했다. 대신에 다음 사이트에서 mingw-get을 받아 설치한 후 mingw32-make.exe를 가져오는 방법을 사용하였다.<br>
[https://sourceforge.net/projects/mingw/](https://sourceforge.net/projects/mingw/)

설치 후 mingw-get GUI에서 다음과 같이 mingw32-make를 선택해서 설치하거나

![install mingw gui]({{site.baseurl}}/assets/post/17-10-27-ARM-Linux-Cross-Compile/install_mingw_gui.png)

명령 프롬프트에서 설치할 수 있다.

{% highlight batch %}
> C:\MinGW\bin\mingw-get.exe install mingw32-make
{% endhighlight %}

어떤 방법으로든 설치하고 나면 MinGW 설치 폴더 아래 bin 폴더에 다음과 같은 파일이 생길 것이다.

![mingw files]({{site.baseurl}}/assets/post/17-10-27-ARM-Linux-Cross-Compile/mingw_files.png)

이 파일들 중 mingw-get.exe를 제외한 5개 파일을 작업 폴더에 mingw32-make라는 폴더를 만들고 그 아래에 복사한다.

준비물을 모두 챙기고 나면 작업 폴더는 다음과 같이 될 것이다.

![working directory]({{site.baseurl}}/assets/post/17-10-27-ARM-Linux-Cross-Compile/working_directory.png)

## 빌드 형상 정의하기

이제 툴체인을 명시한 toolchain.arm.cmake 파일을 작성한다.

{% highlight cmake %}
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_PROCESSOR arm)

SET(COMPILER_ROOT "D:/arm/gcc-linaro-7.1.1-2017.08-i686-mingw32_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-")

SET(CMAKE_C_COMPILER ${COMPILER_ROOT}gcc.exe)
SET(CMAKE_CXX_COMPILER ${COMPILER_ROOT}g++.exe)
SET(CMAKE_LINKER ${COMPILER_ROOT}ld.exe)
SET(CMAKE_NM ${COMPILER_ROOT}nm.exe)
SET(CMAKE_OBJCOPY ${COMPILER_ROOT}objcopy.exe)
SET(CMAKE_OBJDUMP ${COMPILER_ROOT}objdump.exe)
SET(CMAKE_RANLIB ${COMPILER_ROOT}ranlib.exe)
{% endhighlight %}

경로는 각자 환경에 맞게 수정하면 된다.
파일 구분자를 백슬래시(\\)로 입력하면 cmake가 escape character로 처리해서 오류가 생기기 때문에 슬래시(/)로 입력했다.

## 예제 코드 작성하기

다음과 같이 간단한 예제 소스코드를 작성했다.

main.c

{% highlight c %}
#include <stdio.h>

int main()
{
    printf("hello arm!!\n");
    return 0;
}
{% endhighlight %}

CMakeLists.txt

{% highlight cmake %}
ADD_EXECUTABLE(App main.c)
{% endhighlight %}

## 빌드하고 실행하기

이제 준비는 모두 끝났으니 빌드하면 된다.

빌드를 편하게 하기 위해 배치 파일을 만들었다.

build.bat

{% highlight batch %}
mkdir build
cd build

"../cmake-3.10.0-rc3-win64-x64/bin/cmake.exe" -DCMAKE_MAKE_PROGRAM="D:/arm/mingw32-make/mingw32-make.exe" -DCMAKE_TOOLCHAIN_FILE=../toolchain.arm.cmake -G "MinGW Makefiles" ..

"../cmake-3.10.0-rc3-win64-x64/bin/cmake.exe"  --build .

@echo off
set /p str=completed
{% endhighlight %}

준비물들이랑 빌드 결과물이 섞이면 곤란하니 build 폴더를 생성하고 그 아래에 빌드 결과물이 생성되도록 하였다.

세 번째 명령어가 매우 긴데, 다음과 같은 일을 한다.

* `-DCMAKE_MAKE_PROGRAM`: mingw32-make.exe의 경로를 지정한다.(절대경로)<br>
mingw-get을 설치하고 나서는 이 옵션이 없어도 cmake가 알아서 mingw32-make의 경로를 찾아내는데, mingw-get 없이 Standalone으로 실행하려면 이 옵션이 반드시 필요하다.

* `-DCMAKE_TOOLCHAIN_FILE`: 툴체인을 명시한 toolchain.arm.cmake 파일의 경로를 지정한다.

* `-G "MinGW Makefiles"`: mingw32-make.exe가 이해할 수 있는 Makefile을 생성한다.

build.bat 파일을 실행하고 나면 build 폴더 안에 App이라는 파일이 생성되었을 것이다.

이것을 ARM Linux 플랫폼에 옮기고 실행한다.

![execute]({{site.baseurl}}/assets/post/17-10-27-ARM-Linux-Cross-Compile/execute.png)
