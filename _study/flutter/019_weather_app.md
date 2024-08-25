---
title: "Weather app"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

다음 플러터 강좌들을 보고 정리한 내용입니다.

* [강좌 13 \| 날씨 앱(weather app) 만들기 1](https://youtu.be/YqKMBQYZSmw)

## Widget lifecycle

Stateless widget은 한 번 생성되면 바뀌지 않기 때문에 바꾸고 싶다면 destroy 하고 rebuild해야 한다. 그리고 Stateful widget은 state object와 결합하여 위젯이 변경될 때 state object가 이를 감지해서 내용을 업데이트할 수 있다. 따라서 Stateful widget은 Stateless widget 보다 더 긴 생명주기를 가지고 더 많은 lifecycle method를 갖는다. 다음은 대표적인 3개의 lifecycle method다.

* `initState()`: state가 최초로 초기화될 때 호출됨
* `build()`: 위젯이 빌드될 때 호출됨
* `dispose()`: 위젯이 제거될 때 호출됨

{% highlight dart %}
import 'package:flutter/material.dart';

class ScreenB extends StatefulWidget {
  const ScreenB({super.key});

  @override
  State<ScreenB> createState() => _ScreenBState();
}

class _ScreenBState extends State<ScreenB> {
  @override
  void initState() {
    super.initState();
    print('initState is called');
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose is called');
  }

  @override
  Widget build(BuildContext context) {
    print('build is called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen B'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Go to the Screen A',
            style: TextStyle(
              fontSize: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}
{% endhighlight %}

위 코드는 `StatefulWidget`의 lifecycle method를 사용하는 방법을 보여준다.

`Navigator`를 통해 다른 페이지에서 `Screen B`로 진입할 때 `initState()`와 `build()`가 순서대로 호출되어서 로그에 `initState is called`와 `build is called`가 출력된다. 그 다음 `Go to the Screen A` 버튼을 클릭해서 `Screen B`에서 벗어나면 `dispose()`가 호출되어서 로그에 `dispose is called`가 출력된다.

## 현재 위치 가져오기

[geolocator](https://pub.dev/packages/geolocator) 패키지를 설치한다. `pubspec.yaml` 파일에 다음과 같이 `geolocator: ^13.0.1`를 추가하면 된다.

{% highlight yaml %}
dependencies:
  flutter:
    sdk: flutter
  geolocator: ^13.0.1
{% endhighlight %}

그리고 안드로의드의 경우 `android/app/src/main/AndroidManifest.xml` 파일을 열어서 아래와 같이 `android.permission.ACCESS_FINE_LOCATION` 권한을 추가한다.

{% highlight xml %}
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
<!-- 생략 -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" /> <!-- 이 줄을 추가 -->
</manifest>
{% endhighlight %}

`geolocator`를 사용해 현재 위치를 가져오는 코드를 다음과 같이 `Loading` 위젯에 작성한다.

{% highlight dart %}
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            getLocation();
          },
          child: Text('Get my location'),
        ),
      ),
    );
  }

  void getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    print(position);
  }
}
{% endhighlight %}

사용자가 `ElevatedButton` 버튼을 눌렀을 때 `getLocation()` 함수가 호출되며, `getLocation()` 함수는 위치 관련 권한을 요청하고 위치 값을 가져 온 후 이 값을 출력한다.

아래는 권한을 요청하는 화면이다.

![위치 권한 요청]({{site.baseurl}}/assets/study/flutter/019_weather_app/Screenshot_1724585196.png){: width="360" .custom-align-center-img}

#### Troubleshooting

2024년 8월, Flutter SDK 3.24.0과 geolocator 13.0.1을 사용하여 바로 빌드하면 아래와 같은 오류 메시지를 출력한다.

{% highlight txt %}
e: C:/Users/user/.gradle/caches/transforms-3/604f9fb74816ffb3b0ff4f95586be650/transformed/jetified-kotlin-stdlib-common-1.9.0.jar!/META-INF/kotlin-stdlib-common.kotlin_module: Module was compiled with an incompatible version of Kotlin. The binary version of its metadata is 1.9.0, expected version is 1.7.1.
e: C:/Users/user/.gradle/caches/transforms-3/6de1df31c3f1c35e3c78be91db4e53b8/transformed/jetified-kotlin-stdlib-1.9.0.jar!/META-INF/kotlin-stdlib-jdk7.kotlin_module: Module was compiled with an incompatible version of Kotlin. The binary version of its metadata is 1.9.0, expected version is 1.7.1.
e: C:/Users/user/.gradle/caches/transforms-3/6de1df31c3f1c35e3c78be91db4e53b8/transformed/jetified-kotlin-stdlib-1.9.0.jar!/META-INF/kotlin-stdlib-jdk8.kotlin_module: Module was compiled with an incompatible version of Kotlin. The binary version of its metadata is 1.9.0, expected version is 1.7.1.
e: C:/Users/user/.gradle/caches/transforms-3/6de1df31c3f1c35e3c78be91db4e53b8/transformed/jetified-kotlin-stdlib-1.9.0.jar!/META-INF/kotlin-stdlib.kotlin_module: Module was compiled with an incompatible version of Kotlin. The binary version of its metadata is 1.9.0, expected version is 1.7.1.

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileDebugKotlin'.
> A failure occurred while executing org.jetbrains.kotlin.compilerRunner.GradleCompilerRunnerWithWorkers$GradleKotlinCompilerWorkAction
   > Compilation error. See log for more details

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.

* Get more help at https://help.gradle.org

BUILD FAILED in 9s

┌─ Flutter Fix ────────────────────────────────────────────────────────────────────────────────┐
│ [!] Your project requires a newer version of the Kotlin Gradle plugin.                       │
│ Find the latest version on https://kotlinlang.org/docs/releases.html#release-details, then   │
│ update the                                                                                   │
│ version number of the plugin with id "org.jetbrains.kotlin.android" in the plugins block of  │
│ C:\Users\user\Projects\Flutter\flutter-test\weather_app\android\settings.gradle.             │
│                                                                                              │
│ Alternatively (if your project was created before Flutter 3.19), update                      │
│ C:\Users\user\Projects\Flutter\flutter-test\weather_app\android\build.gradle                 │
│ ext.kotlin_version = '<latest-version>'                                                      │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
Error: Gradle task assembleDebug failed with exit code 1

Exited (1).
{% endhighlight %}

오류 메시지의 가이드에 따라 플러터 프로젝트의 `android/settings.gradle` 파일에서 `org.jetbrains.kotlin.android`의 버전을 다음과 같이 `1.7.10`에서 `2.0.10`로 변경하면 해결된다.

{% highlight gradle %}
id "org.jetbrains.kotlin.android" version "2.0.10" apply false
{% endhighlight %}

## API

API를 호출할 때에는 key가 필요하다.

## Exception handling

## Http package

## Json parsing

## Passing data
