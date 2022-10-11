---
title: "Automated PLC Application Generation Solution from UPPAAL Model : UPPAAL2PLC"
image: /assets/post/17-07-24-UPPAAL2PLC/system_model.png
author: khlee
categories:
    - EtherCAT
layout: post
---

## 소개

개인적으로 개발 중인 UPPAAL2PLC의 1차 버전을 github에 릴리즈했다..
(repo : [https://github.com/lklab/Uppaal2PLC](https://github.com/lklab/Uppaal2PLC))

UPPAAL2PLC는 작년에 수업 프로젝트로 시작해서 개인적으로 계속 진행하고 있던 프로젝트로, 소프트웨어 모델링 및 검증 툴인 [UPPAAL](https://uppaal.org/)을 통해 개발된 타임드 오토마타 모델을 PLC(Programmable Logic Controller)에서 동작하는 프로그램으로 자동 변환해주는 기능을 한다.

이 글에서는 UPPAAL2PLC를 포함하는 MDD(Model Driven-Development)의 개념과 UPPAAL2PLC를 사용하여 검증된 프로그램을 개발하는 예시를 다룰 것이다.

정형 기법(Formal Method)은 소프트웨어가 만족해야 하는 속성을 수학적인 증명을 통해 검증하는 방법이다. 이를 위해 검증이 가능하도록 수학적인 장치가 마련된 언어를 소프트웨어를 명세하는 데 사용하는데, 이것이 정형 언어(Formal Language)이다. 정형 언어로 기술된 소프트웨어는 비록 검증은 가능하더라도, 실제 프로그램으로 동작하기 위해서는 C나 자바 등의 개발 언어로 재작성 되어야 한다.

정형 언어와 개발 언어의 변환이 비정형적(informal)으로 이루어지면, 정형 기법을 통해 검증된 속성이 개발 언어에서도 만족한다는 보장을 할 수 없게 된다. 따라서 두 언어 사이의 변환을 자동화하는 방법으로 어느 정도 정형성을 확보하려는 노력을 하게 되는데, 이것이 바로 MDD다. 물론 완전한 정형적 보장을 위해서는 자동 변환 과정에 대한 검증도 필요하다.

UPPAAL2PLC는 정형 언어 타임드 오토마타(Timed Automata)로부터 C 코드로 변환 후 컴파일하여 PLC 응용으로 생성한다. 타임드 오토마타의 개발 및 검증 툴로 UPPAAL을 사용한다. 또한 PLC 플랫폼이나 응용이 입출력하는 데이터 등을 정의한 설정 파일도 별도 입력으로 받아, 생성된 코드나 응용에 대한 추가 작업 없이 바로 실행이 가능한 응용을 생성한다.

UPPAAL2PLC를 사용하여 PLC 응용을 개발하는 과정은 다음과 같다.
1. UPPAAL을 사용하여 타겟 시스템 모델링
2. UPPAAL을 사용하여 모델 검증 및 모델 수정
3. 검증된 모델이 정의된 UPPAAL 프로젝트 파일과 설정 파일 준비
4. UPPAAL2PLC에 두 파일 입력 후 실행하여 실행파일 생성

이 과정에서 개발자가 직접 개입하는 과정은 1번, 3번이고, 나머지는 개발자가 명령을 내리면 UPPAAL 검증기(Verifier)나 UPPAAL2PLC가 자동으로 수행하는 것들이다.
UPPAAL2PLC는 타겟 시스템이 PLC로 한정되어 있는데, 이 때문에 개발자가 개입하는 1번, 3번 과정에서 지켜야 할 규칙이 있다. 이것을 다음 예시를 통해 설명할 것이다.

## 예시 - 신호등 시스템

먼저 예시로 삼을 시스템을 정의한다. 간단하게 신호등 시스템이다. github에 올라와 있는 예제([TrafficLightControl](https://github.com/lklab/Uppaal2PLC/tree/master/examples/TrafficLightControl))이기도 하다.
보행자는 버튼을 누를 수 있고 버튼이 눌리면 일정 시간 후에 초록 불이 된다. 그 후에는 버튼 입력과 상관 없이 일정 시간 후에 빨간 불이 되며, 다시 버튼을 누를 경우 그 시점부터 일정 시간 후에 초록 불이 된다.

## 시스템 모델

먼저 UPPAAL을 사용해서 타겟 시스템을 모델링해야 한다. UPPAAL에서는 각 타임드 오토마타의 구조를 정의한 것을 템플릿이라고 하는데, 총 3종류의 템플릿으로 나누어서 모델링해야 한다. 그 종류는 시스템 모델, 환경 모델, 프로그램 모델이다. 시스템 모델은 PLC의 동작 방식을 모델링한 것으로 모든 응용에 대해 반드시 동일하게 포함해야 한다. 다음 그림은 시스템 모델을 나타낸다.

![System model]({{site.suburl}}/assets/post/17-07-24-UPPAAL2PLC/system_model.png)

PLC는 주기적으로 동일한 로직을 반복 실행한다. 각 로직은 세 가지로 구분된다. 입력, 출력, 계산. 입력은 외부 장치로부터 값을 읽어서 메모리에 저장하는 것이고 출력은 메모리에 저장된 값을 외부 장치에 출력하는 것이다. 계산은 메모리에 저장된 입력 데이터로부터 응용마다 다르게 정의된 로직에 따라 계산된 출력 데이터를 메모리에 저장하는 것이다. 이러한 동작을 모델링한 것이 위의 시스템 모델이다. `tickClock`은 주기적인 실행을 모델링하기 위해 도입한 Clock 변수이고, `exchangeData()` 함수는 입력과 출력 기능을 수행하는 함수이다. `dataExchanged` 채널은 시스템 전체의 모델들에게 입출력 교환이 완료되었음을 알려서 계산을 수행하도록 신호를 주는 역할을 한다.

`exchangeData()` 함수의 내용을 작성할 때에도 지켜야 할 규칙이 있다. 먼저 다음 그림을 보자.

![Exchange data]({{site.suburl}}/assets/post/17-07-24-UPPAAL2PLC/exchange_data.png)

함수 내에서는 앞 글자만 다른 두 변수의 값을 복사하는 것으로 이루어진다. 설명하자면, `p`로 시작하는 변수는 프로그램 모델쪽, `e`로 시작하는 변수는 환경 모델쪽 변수이다. 이렇게 같은 기능의 변수를 전역 변수 하나로 두어 공유하지 않고 분리하는 이유는 PLC의 동작 특성에 있다. 프로그램 모델은 PLC에서 동작하는 응용을 모델링한 것이고, 환경 모델은 외부 장치들을 모델링한 것이다. 이 예에서는 환경 모델에 신호등, 버튼, 보행자 등이 포함될 수 있을 것이다. PLC 시스템에서는 PLC와 외부 장치가 언제나 통신하여 데이터를 교환하는 것이 아니고 주기적인 시점에서만 데이터 교환이 일어난다. 따라서 전역 변수 하나를 공유하게 되면 이러한 특성이 드러나지 않게 되어, 모델과 실제 프로그램간 차이가 발생하며, 모델에서 검증된 속성이 실제 프로그램에서도 만족함을 보장할 수 없게 된다.

## 환경 모델

다음 그림들은 환경 모델이다.

![Environment model 1]({{site.suburl}}/assets/post/17-07-24-UPPAAL2PLC/env_model_1.png)
![Environment model 2]({{site.suburl}}/assets/post/17-07-24-UPPAAL2PLC/env_model_2.png)
![Environment model 3]({{site.suburl}}/assets/post/17-07-24-UPPAAL2PLC/env_model_3.png)

순서대로 보행자(Pedestrian), 신호등(Light), 버튼(Button) 모델인데, 자세한 내용은 설명하지 않고 동작 방식만 설명하려고 한다. 먼저 보행자 모델은 `push` 채널을 통해 버튼 모델에 신호를 보낼 수 있고 그 신호를 받으면 보튼 모델에서는 `eButton`, 즉 환경 모델 쪽 버튼 변수의 값을 `true`로 바꾼다. 이 값은 주기적인 시점, 즉 `exchangeData()` 함수가 호출될 때 프로그램 모델에 넘어갈 것이다. 신호등 모델은 주기적으로 `eLight`의 값을 확인하여 `true`이면 `Green`으로, `false`이면 `Red`로 상태를 변경한다.

## 프로그램 모델

이제 프로그램 모델이다.

![Program model]({{site.suburl}}/assets/post/17-07-24-UPPAAL2PLC/program_model.png)

프로그램 모델은 좀 복잡해 보이지만 간단히 말해서 아까 명세한 신호등의 기능을 모델링한 것이라고 보면 된다. 초기의 `LightRed` 상태에서 버튼 입력을 확인하고 `true`이면 `WAIT_TIME` 시간 동안 기다리다가 신호등 초록 불을 켜고(`pLight = true`), `GREEN_TIME` 시간 동안 기다리다가 다시 빨간 불로 돌아온다.(`pLight = false`)

실제로 응용으로 변환될 모델은 프로그램 모델이다. 환경 모델과 시스템 모델은 검증을 위해 필요한 모델들인데, 그렇다고 이들 모델링에 소홀하면 제대로 된 검증이 될 수 없다.
프로그램 모델 뿐만 아니라 환경 모델도 그 모델링 품질에 공을 들여야 한다.

## 검증

두 번째 단계는 검증이다.
앞에서 환경 모델이 본래 기능 외에도 부가적으로 복잡하게 들어있는 이유는 바로 이 검증 때문이다. 단 여기서 주의할 게, 검증을 위해 부가적으로 들어간 것이 원래 모델의 동작에 영향이 있으면 안된다.

다음은 이번 예시에서의 검증 항목들이다.

![Verification]({{site.suburl}}/assets/post/17-07-24-UPPAAL2PLC/verification.png)

첫 번째는 일반적으로 데드락을 검증하는 것이다.
두 번째는 보행자의 응답성을 검증한 것인데 보행자 모델을 보면 `push` 채널을 통해 버튼 누름을 인지하면 `Waiting` 상태로 전이하면서 Clock `waiting_green_light`의 값을 `0`으로 초기화한다. 이후 신호등으로부터 초록 불 신호를 받으면 `Waiting` 상태를 벗어난다. 즉, `Waiting` 상태에서의 Clock `waiting_green_light`의 최댓값은 보행자 응답 시간의 최대를 나타내며 이 값이 `WAIT_TIME`에 2번의 주기 시간을 더한 값을 넘지 않음을 보인다.
세 번째 항목은 신호등이 빨간 불 상태에 진입했을 때 어떤 경우에도 최소한 이를 `WAIT_TIME` 시간 동안 유지함을 검증한 것이다. 이 역시 `Green` 상태로 전이할 때 초기화되는 Clock `keep_red_light`의 값을 통해 확인이 가능하다.

## 설정 파일

이로써 검증이 모두 완료되면 UPPAAL2PLC의 입력 파일 하나가 준비된 것이다. 남은 입력 파일인 설정 파일은 간단하다. 그냥 몇 가지 제시되어야 할 설정 값들을 형식에 맞게 입력하면 된다.
다음은 이번 예시에서 사용한 설정 파일의 내용이다.

{% highlight xml %}
<platform>
    <os>linux</os>
    <protocol>soem</protocol>
    <period>10000000</period>
</platform>
<configuration>
    <task type="Controller" />
    <io varname="pButton" address="1:0x6000:0x1" type="bool" direction="in" />
    <io varname="pLight" address="1:0x7010:0x1" type="bool" direction="out" />
</configuration>
{% endhighlight %}

`os`와 `protocol` 항목의 값은 각각 PLC의 운영체제와 통신 프로토콜의 종류를 나타낸다. 이 값에 따라 UPPAAL2PLC의 resources 디렉토리 아래에 있는 플랫폼 관련 코드들이 응용 생성시에 동적으로 선택되어 컴파일된다.
`period` 항목은 PLC 시스템의 제어 주기를 설정하는 것으로 ns 단위로 입력하면 된다.

`task` 항목은 UPPAAL 프로젝트에 선언된 여러 템플릿들 중 프로그램 모델을 명시하는 것으로, 여기서는 프로그램 모델의 템플릿 이름인 `"Controller"`를 값으로 주었다. 아직 UPPAAL2PLC에서는 다중 태스크를 지원하지 않기 때문에 `task` 태그는 한 번만 선언 가능하다.
`io` 항목은 UPPAAL 모델에 선언된 변수를 실제 통신 변수에 매핑하기 위한 정보다. `varname`에는 UPPAAL 모델에 선언된 프로그램쪽 변수를 입력하면 되고, `address`에는 통신 변수를 특정하기 위해 통신 프로토콜별로 정의된 포맷에 따라 적으면 된다. 여기서는 SOEM 즉, EtherCAT을 사용하는데 이 프로토콜에서 `address`는 ":"으로 구분되는 각 세 파트에 [Slave 번호]:[OD Index]:[OD Subindex]를 적어넣으면 된다. 위 예시에서는 이들이 각각 스위치와 LED 장치를 나타낸다. `type`과 `direction`에는 각각 그 변수의 타입, 입출력 방향을 입력하면 된다.

## 데모

이제 모든 입력 파일이 완성되었으니 UPPAAL2PLC를 실행하면 된다. github에 올린 프로젝트 내에는 위에서 언급한 모든 입력 파일이 준비되어 있으니, github에서 바로 다운받았다면, 명령어를 다음과 같이 입력하면 된다.

{% highlight bash %}
$ ./Uppaal2PLC.py examples/TrafficLightControl/TrafficLightControl.xml examples/TrafficLightControl/config.xml
{% endhighlight %}

이제 생성된 응용 "PlcApp"을 실행해 볼 차례다.
[지난 번 글](https://lklab.github.io/blog/blog/Raspberry-Pi-EtherCAT/)에서처럼 라즈베리파이를 EtherCAT 마스터로, EL9800을 EtherCAT 슬레이브로 채택하였다.

<iframe class="video" src="https://www.youtube.com/embed/4VELOOvaF1w" allowfullscreen frameborder="0"></iframe>
