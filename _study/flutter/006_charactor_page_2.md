---
title: "캐릭터 페이지 디자인 3: 실전코딩 part 2"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌](https://youtu.be/qnnExhBcNTk?si=3zLvsP_-7ZrQ1GYb)를 보고 정리한 내용입니다.

![Complete]({{site.baseurl}}/assets/study/flutter/006_charactor_page_2/complete.png){: width="360" .custom-align-center-img}

오늘의 완성 화면이다.

## Row, Icon 위젯

{% highlight dart %}
Column(
  // ...
  children: [
    // ...
    const Row(
      children: [
        Icon(Icons.check_circle_outline),
        SizedBox(
          width: 10.0,
        ),
        Text(
          'using lightsaber',
          style: TextStyle(
            fontSize: 16.0,
            letterSpacing: 1.0,
          ),
        )
      ],
    ),
    // ...
  ],
)
{% endhighlight %}

* `Row` 위젯을 `Column` 위젯 안에 사용해서 가로로 배치되는 위젯들을 세로로 배치되는 위젯 안에 넣을 수 있다.
* `Icon` 위젯을 사용해서 flutter에서 제공하는 아이콘을 사용할 수 있다.

## 이미지 추가

먼저 VSCode 좌측의 Explorer 창에서 이미지 파일을 추가할 폴더를 생성한다.

![Asset folder]({{site.baseurl}}/assets/study/flutter/006_charactor_page_2/asset_folder.png){: width="280" .custom-align-center-img}

여기서는 폴더 이름을 "assets"이라고 했다.

다음으로 프로젝트에서 사용할 이미지들을 드래그해서 넣는다.

![Asset files]({{site.baseurl}}/assets/study/flutter/006_charactor_page_2/asset_files.png){: width="280" .custom-align-center-img}

이미지 출처
* [https://assetstore.unity.com/packages/2d/environments/2d-space-kit-27662](https://assetstore.unity.com/packages/2d/environments/2d-space-kit-27662)
* [https://pixabay.com/ko/gifs/%EB%B6%88-%EC%97%B4-%EC%9D%B8%EB%8F%84-%EB%A7%88%ED%98%B8%EA%B0%80%EB%8B%88-%EB%B6%88%EA%BD%83-3352/](https://pixabay.com/ko/gifs/%EB%B6%88-%EC%97%B4-%EC%9D%B8%EB%8F%84-%EB%A7%88%ED%98%B8%EA%B0%80%EB%8B%88-%EB%B6%88%EA%BD%83-3352/)

그리고 `pubspec.yaml` 파일을 열어서 `assets:` 라고 되어 있는 부분을 찾아 주석을 해제하고 다음과 같이 이미지 경로를 작성한다.

{% highlight yaml %}
# To add assets to your application, add an assets section, like this:
assets:
  - assets/Cruiser 3.png
  - assets/fire-3352_256.gif
{% endhighlight %}

## CircleAvatar 위젯

`CircleAvatar` 위젯을 사용하여 추가한 이미지를 원형으로 출력할 수 있다.

{% highlight dart %}
CircleAvatar(
  backgroundImage: const AssetImage('assets/Cruiser 3.png'),
  radius: 40.0,
  backgroundColor: Colors.amber[800],
),
{% endhighlight %}

* `backgroundImage` 파라미터에 이미지 경로를 입력해서 출력할 이미지를 지정할 수 있다.
* 이미지의 투명한 부분을 배경색과 동일하게 출력하기 위해 `backgroundColor` 파라미터를 사용하였다.

## Divider 위젯

`Divider` 위젯을 사용하여 구분선을 출력할 수 있다.

{% highlight dart %}
Divider(
  height: 60.0,
  color: Colors.grey[850],
  thickness: 0.5,
  endIndent: 30.0,
),
{% endhighlight %}

* `height` 파라미터는 위젯이 차지할 높이 값으로, 구분선의 두께와는 별개이다.
* 두께는 `thickness` 파라미터를 통해 지정할 수 있다.
* `endIndent` 파라미터를 사용하여 구분선의 끝 부분(오른쪽 부분)의 여백을 지정할 수 있다.
