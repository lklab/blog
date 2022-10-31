---
title: Unity에서 Bluetooth Controller 제어
image: /assets/post/17-10-18-Unity-Bluetooth-Controller/controller_02.jpeg
author: khlee
categories:
    - Unity
layout: post
---

## 컨트롤러 소개

VR 앱을 개발하기 위해 아이페가 PG-9068 TOMAHAWK 모델의 블루투스 컨트롤러를 구입하였다.

![controller]({{site.baseurl}}/assets/post/17-10-18-Unity-Bluetooth-Controller/controller_01.jpeg){: .custom-align-center-img}

집에 도착한 모습

![controller]({{site.baseurl}}/assets/post/17-10-18-Unity-Bluetooth-Controller/controller_02.jpeg){: .custom-align-center-img}
![controller]({{site.baseurl}}/assets/post/17-10-18-Unity-Bluetooth-Controller/controller_03.jpeg){: .custom-align-center-img}

Xbox 컨트롤러와 유사한 구조를 갖고 있다.

## Unity에서 컨트롤러 입력값을 읽어오기

Unity에서 컨트롤러의 입력값을 읽어오기 위해서는 각 버튼이 어떻게 매핑되어 있는지 알아야 한다. 직접 테스트해본 결과 다음 그림과 같이 매핑되어 있었다.

![mapping]({{site.baseurl}}/assets/post/17-10-18-Unity-Bluetooth-Controller/mapping.png)

OS와 컨트롤러에 따라 매핑 정보는 달라질 수 있다. 따라서 출시되는 VR 앱에는 이를 잘 파악하여 동적으로 매핑 정보를 파악할 수 있도록 해야 한다.

그림에서 "JoystickButton\*" 로 매핑되는 버튼은 Digital 값이고, "\*th axis"로 매핑되는 조이스틱이나 버튼은 Analog 값이다. Digital인가 Analog인가에 따라 Unity에서 값을 읽어오는 방식이 다르다.
(LT, RT 버튼은 Digital과 Analog 방식 모두 동작한다.)

## Digital 입력

먼저 Digital 값은 스크립트에서 다음과 같이 쉽게 읽어올 수 있다.

{% highlight csharp %}
bool key_value = Input.GetKey(KeyCode.JoystickButton0);
{% endhighlight %}

[Unity reference](https://docs.unity3d.com/kr/current/ScriptReference/KeyCode.html)를 확인해 보면 `KeyCode`의 다양한 값을 볼 수 있다. 최대 8개까지의 조이스틱(컨트롤러)를 구분할 수 있으며 각 컨트롤러마다 최대 20개의 버튼을 구분할 수 있다. 이 값을 `Input.GetKey()` 함수의 인자로 주면 버튼 값을 `True`나 `False`로 돌려 준다. 물론 `Input.GetKeyDown()` 이나 `Input.GetKeyUp()` 등의 다른 함수도 사용할 수 있다.

## Analog 입력

Analog 값은 조금 복잡한데, 우선 스크립트에서 읽는 방법은 다음과 같다. -1.0 \~ 1.0 범위의 값을 얻을 수 있다.

{% highlight csharp %}
float key_value = Input.GetAxis("Horizontal");
{% endhighlight %}

`Input.GetAxis()` 함수를 사용하는데, 인자로 주는 string은 읽으려는 axis의 이름이다. Unity는 기본적으로 컨트롤러의 첫 번째 조이스틱에 `"Horizontal"`, `"Vertical"` axis가 매핑되어 있다. 이러한 정보는 Edit -> Project Settings -> Input에서 설정 가능하다.

![input settings]({{site.baseurl}}/assets/post/17-10-18-Unity-Bluetooth-Controller/input_settings.png)

설정 창을 열게 되면 Inspector에 다음과 같이 InputManager가 보일 것이다.

![input manager]({{site.baseurl}}/assets/post/17-10-18-Unity-Bluetooth-Controller/input_manager.png)

다양한 Axis 이름들이 정의되어 있는데, 그 중에서 `"Horizontal"`, `"Vertical"` axis가 미리 정의되어 있는 것을 볼 수 있다. 또 다른 Analog 입력을 추가하고 싶다면 InputManager의 가장 위에 있는 속성인 `Size` 값을 늘린 후에 추가된 항목에 값을 채워넣으면 된다.

여기서는 다음과 같이 오른쪽 조이스틱을 입력으로 추가했다.

![joystick settings]({{site.baseurl}}/assets/post/17-10-18-Unity-Bluetooth-Controller/joystick_settings.png)

각 속성에 대한 상세한 내용은 [여기](https://docs.unity3d.com/kr/2018.4/Manual/ConventionalGameInput.html) 참조

가장 위에 있는 Name 속성에 입력하는 string을 스크립트에서 `Input.GetAxis()` 등의 함수에 인자로 사용하여 해당 Analog 입력 값을 받아올 수 있다. Axis 속성에는 앞서 언급했던, 버튼과 조이스틱이 매핑된 axis를 선택하면 된다. 오른쪽 조이스틱은 X 축이 3rd axis에, Y 축이 4th axis에 매핑되어 있다고 했으므로 그에 맞게 설정하였다.
