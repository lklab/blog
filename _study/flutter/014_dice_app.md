---
title: "Dice login app"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

다음 플러터 강좌들을 보고 정리한 내용입니다.
* [Part 1](https://youtu.be/mQX_kJKnZzk)
* 
* 

## 로그인 페이지 구현하기

아래와 같은 화면을 구현할 것이다. [전체 코드](https://github.com/lklab/flutter-test/blob/cc9ab8301a192f6ca75be30ba782dca68ad26ab3/login_dice/lib/main.dart)

![Login complete]({{site.baseurl}}/assets/study/flutter/014_dice_app/login_complete.png){: width="360" .custom-align-center-img}

#### Form 위젯

{% highlight dart %}
Form(
  child: Theme(
    data: ThemeData(
      primaryColor: Colors.teal,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(
          color: Colors.teal,
          fontSize: 15.0,
        ),
      ),
    ),
    child: // ...
  ),
),
{% endhighlight %}

`TextField` 위젯으로 정보를 입력 받을 때 일반적으로 `Form` 위젯을 사용한다. 여기서는 `ThemeData`를 사용해서 입력 필드가 선택되었을 때의 강조 색상을 설정하고 레이블의 색상과 크기도 설정하였다.

#### TextField 위젯

{% highlight dart %}
TextField(
  decoration: InputDecoration(
    labelText: 'Enter "dice"',
  ),
  keyboardType: TextInputType.emailAddress,
  // obscureText: true,
),
{% endhighlight %}

`InputDecoration`의 `labelText` 속성을 통해 레이블 텍스트를 설정할 수 있고, `keyboardType` 속성을 통해 키보드 타입(키보드 자판의 구성)을 지정할 수 있다. 비밀번호와 같이 입력된 내용을 안 보이게 하려는 경우 `obscureText` 속성을 `true`로 설정하면 된다.

#### SingleChildScrollView 위젯

키보드가 화면에 올라와서 위젯의 일부가 가려진 경우 디버그 모드에서 아래와 같은 경고 문구가 출력된다.

![View overflowed]({{site.baseurl}}/assets/study/flutter/014_dice_app/login_overflow.png){: width="360" .custom-align-center-img}

여기서는 `SingleChildScrollView` 위젯을 사용해서 스크롤될 수 있게 하는 방법으로 해결하였다. 앱바를 제외한 화면 전체에 적용되어야 하므로 `Scaffold`의 `body`로 `SingleChildScrollView`을 사용하고 모든 컨텐츠를 그 `child`로 넣었다.

{% highlight dart %}
return Scaffold(
  appBar: // ...
  body: SingleChildScrollView(
    child: Column(
      children: [
        // ...
        Form(
          // ...
        ),
      ],
    ),
  ),
);
{% endhighlight %}
