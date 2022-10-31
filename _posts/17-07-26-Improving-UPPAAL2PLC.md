---
title: UPPAAL2PLC 개선작업
image: /assets/post/17-07-26-UPPAAL2PLC/concurrency_hypothesis.png
author: khlee
categories:
    - MDD
layout: post
---

[지난 글]({{ site.baseurl }}{% post_url 17-07-24-UPPAAL2PLC %})에서 소개한 UPPAAL2PLC는 아직 개선해야 할 점이 남아있다. 현재 UPPAAL2PLC는 UPPAAL에서 모델링 가능한 모든 모델을 지원하지 못하고 제한적으로 지원한다. 예를 들어 태스크는 하나만 있어야 하고, 비결정적 전이를 올바르게 구현하지 않는다는 제한사항이 있다.
이번 글에서는 UPPAAL2PLC의 추후 개선 방향과, 정형 모델과 실제 시스템의 차이로 인한 상호 변환의 어려움에 대해 기술할 것이다.

## 시간의 연속성과 동시성 가설

UPPAAL에서 사용하는 정형 언어인 타임드 오토마타의 의미론(Semantics)에서는 시간 값, 즉 clock 변수의 값은 연속적이다. 그러나 컴퓨터 시스템에서는 시간성을 구현하기 위해서 일정 주기 단위로 반복 수행하는 방법을 사용하는데, 이 경우 각 주기마다 시간은 동일한 것으로 표현되어 이산적인 시간 값을 갖게 된다.

![continuous time and discrete time]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/continuous_time_discrete_time.png){: .custom-align-center-img}
*\<연속적인 실제 시간과 이산적인 시간\><br>
실제 시간은 각 시점마다 연속적인 실수 값으로 표현되지만 이산적인 시간은 한 주기 내에서 동일한 값으로 표현된다.*{: .custom-caption}

이를 해결하기 위해 주기를 짧게 해서 이산적인 시간 값으로 최대한 연속적인 시간을 흉내 내게 하는 방법이 있을 것이다. 하지만 이것은 엄격한 의미가 중요시되는 정형 기법에서는 허용되지 않는다. 이러한 차이로 인해 모델과 실제 동작 사이에 차이가 생길 수 있기 때문이다.
그렇다면 타임드 오토마타의 의미론을 약간 수정하면 어떨까? 연속적인 시간 값을 사용하지 않는 것이다. 사실 이것을 위한 준비가 이미 되어 있다. 지난 글에서 UPPAAL에서 모델을 개발할 때 반드시 포함해야 하는 템플릿, 시스템 템플릿이 있다고 했다. 이 템플릿에서 연속적인 clock 값을 이용하여 주기적으로 `dataExchanged` 채널을 출력한다. 이 채널의 출력 주기가 바로 이산적인 시간을 의미하게 된다. 프로그램 템플릿에서는 이 채널을 수신하여 이산적인 시간을 모델링할 수 있다. 또한, 주기 clock 값의 배수만 사용하는 것으로 제한해도 이산적인 시간을 표현하는 것이 된다. 단, 환경 템플릿에서는 이 제한을 지키지 않아도 된다. 더 좋은 검증을 위해서는 환경 템플릿에 한해 이러한 제한을 지키지 않는 것이 좋다.

![system template]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/system_template.png){: .custom-align-center-img}
*\<시스템 템플릿\><br>
주기적으로 dataExchanged 채널을 출력한다. 이 채널을 받을 때마다 시간 값이 주기만큼 증가한다고 모델링한다.*{: .custom-caption}

동시성 가설은 어떤 실행이 한 순간에 완료된다고 가정하는 것이다. 타임드 오토마타의 의미론에서는 동시성 가설이 적용되어, 전이라던가 guard 검사, update 수행 등이 모두 시간의 흐름 없이 진행된다. 또한 urgent, committed location 등과 같이 아예 의미적으로 시간이 흐르지 않고 바로 다음 상태로 전이되어야 하는 상태도 존재한다. 이것은 앞에서 언급한 모델에 이산적인 시간을 도입하는 것으로 어느 정도 해결된다. 한 주기 내에서는 시간이 동일한 것으로 표현되므로, 그 주기 내에 실행되는 것들은 모두 실행 시간이 없는 것이 된다. 다만 로드가 심해서 한 주기 동안 수행되어야 할 모든 일을 주기 내에 마치지 못하면 왜곡이 발생한다. 이전 주기에 시작되어 다음 주기에 끝난 태스크는 그 수행 시간이 이미 한 주기 만큼의 시간이 되기 때문이다.

![concurrency hypothesis]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/concurrency_hypothesis.png){: .custom-align-center-img}
*\<동시성 가설의 구현\><br>
이산적인 시간 표현에서는 한 주기 내에 태스크가 실행되고 종료되면 그 수행 시간이 0인 것으로 표현된다. 그러나 주기를 넘어가게 되면 수행 시간이 한 주기 만큼의 시간이 된다.*{: .custom-caption}

보다 근본적으로 모델의 시간을 구현하기 위해선 엄밀한 주기성이 필수적이다. 즉 주기가 실제 시간으로 얼마나 시간을 정확히 맞추느냐는 것이다. 따라서 실시간 성능이 좋은 플랫폼 상에서만 모델의 시간이 실제 시간으로 잘 구현될 수 있다.
모델의 시간은 주기의 횟수로 구현된다고 생각하면 의미적으로 정확하다. 예를 들어 모델 시간으로 3을 주기라고 생각한다면, "clock 값이 0에서 12까지 증가하는 동안"이라는 의미는 구현 관점에서 "4번의 주기가 수행되는 동안"과 동일한 의미가 된다.
정리해서, UPPAAL에서 `dataExchanged` 채널과 주기 클럭의 배수만 사용하도록 제한하고, 한 주기 내에 필요한 모든 작업이 반드시 완료되면 시간의 연속성과 동시성 가설 문제는 해결될 수 있다.

## 비결정적 전이

타임드 오토마타의 의미론에서는, 현재 상태에서 채널이나 guard 조건 등을 만족한 전이가 여러 개 있을 경우 그것들 중 하나를 랜덤으로 선택하여 전이를 수행하거나, invariant 등의 조건이 만족한다면 아예 전이가 일어나지 않을 수 있다. 즉, 수행 트레이스를 정확히 예측할 수 없는 비결정성이 존재한다.

![non-deterministic transition]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/non-deterministic_transition_01.png){: .custom-align-center-img}
*\<비결정적인 전이가 일어날 수 있는 예\><br>
value의 값이 150이라면, 초기 Initial 상태에서 다음 상태에 L0이나 L1 또는 L2 상태가 될 수 있고 그대로 Initial 상태에 머무를 수도 있다.*{: .custom-caption}

이러한 특징을 구현하기 위해서는 현재 상태에서 모든 가능한 다음 상태를 리스트로 구한 다음 그들 중 하나를 랜덤함수를 이용하여 선택하는 방법이 사용될 수 있다. 그러나 비결정성이 반드시 필요한가? 게임 등에서는 여러분의 장비를 강화할 때 일정 확률로 부서지게 하는 기능에는 사용될 수 있겠지만 산업 장치들을 제어하는 프로그램에서 어떻게 실행될지 예측하지 못하는 기능이 효용성이 있을지는 생각해 봐야 한다. 물론, 타임드 오토마타의 시멘틱스를 온전하게 구현하면 정형 검증에 대한 보장을 가져갈 수 있지만, 쓸모 없는 기능을 위해 계산 시간을 낭비하는 것도 피해야 할 요소이다.

![non-deterministic transition]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/non-deterministic_transition_02.png){: .custom-align-center-img}
*\<모델 수준에서 비결정성의 제거\><br>
guard의 검사 범위 구분, 채널 동기화 committed / urgent location, invariant(그림에는 나와있지 않음) 등을 사용하여 비결정성을 제거할 수 있다.*{: .custom-caption}

따라서 필자는 비결정성을 구현하는 대신, 앞의 1번 항목과 같이 모델을 제한하고자 한다. 방법은 비결정성이 없도록 프로그램 모델을 구현하는 것이다. (아까도 말했지만 환경 모델은 해당되지 않는다. 환경 모델은 비결정성을 많이 둘수록 더 포괄적인 검증이 가능하게 된다.) 그렇지만 어떻게 비결정성이 없도록 모델을 구현할 수 있을까? 여러 전이 사이의 guard에 겹치는 구간을 없도록 하고, 채널이나 invariant, committed/urgent 기능들을 사용하여 시간적 비결정성도 없게 하는 등의 가이드라인이 제시될 수 있다. 아니면 모델을 파싱하는 과정에서 이러한 조건을 만족하도록 모델을 구현했는지 검사하는 기능을 넣을 수도 있겠다.

![TCTL]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/TCTL.png){: .custom-align-center-img}
*\<TCTL 검증의 검사 조건\><br>
A 검증이 참이기 위해서는 모든 가능한 트레이스에 대해 참이어야 하고, E 검증이 참이려면 그러한 조건이 만족하는 트레이스가 하나 이상 존재해야 한다.<br>
\[출처 : UPPAAL Tutorial, [http://people.cs.aau.dk/~adavid/publications/21-tutorial.pdf](http://people.cs.aau.dk/~adavid/publications/21-tutorial.pdf)\]*{: .custom-caption}

정형 검증에 대해서는 비결정성을 내포하고 있는 의미론을 결정적 모델로 구현을 하더라도 일부는 정형적으로 보장이 가능하다. UPPAAL에서는 TCTL(Timed Computation Tree Logic) 문법에 의거한 검증 식이 주어지는데, 크게 A 검증과 E 검증이 존재한다. A는 모든 트레이스에 대해\~ 라는 의미고 E는 어떤 하나 이상의 트레이스에 대해\~ 라는 의미이다. 다시 말해서 A 검증은 모든 트레이스에서 조건이 만족해야 참이고, E 검증은 조건이 만족하는 트레이스가 하나라도 있으면 참이 된다. A 검증으로 검증된 조건은 모든 트레이스에서 만족하게 되는데, 결정적인 트레이스는 비결정적인 트레이스의 부분집합(subset)이므로, 결정적으로 구현하더라도 여전히 조건이 만족하게 된다. 반면 E 검증으로 검증된 조건은 그 조건을 만족하는 트레이스가 결정적 트레이스에서 존재하지 않을 수 있으므로 결정적으로 구현했을 때 그 조건이 만족하지 않을 수 있다. 요약하면 A 검증은 비결정적인 의미론을 결정적으로 구현하더라도 여전히 정형적으로 보장된다.

## 다중 태스크

여기서 말하는 다중 태스크의 의미는 컴퓨터에서 여러 개의 스레드나 프로세스를 의미하는 것이 아니고, 하나 이상의 타임드 오토마타로 구성된 네트워크를 의미한다. 좀 더 엄밀히 정의하자면, 프로그램 템플릿이 하나 이상의 인스턴스로 구성된 것을 의미한다. 현재는 프로그램 템플릿이 하나인 것만 지원하고 있으나 필연적으로 다중 태스크를 지원해야 할 것이다. 다중 태스크를 지원하기 위해서 주로 신경써야 할 부분은 태스크 간 실행 우선순위와 다음 항목에서 얘기할 채널 처리 문제다.
UPPAAL2PLC는 single thread로 동작하는 프로그램을 생성한다. 따라서 태스크가 여러 개인 경우 순차적으로 어떤 태스크부터 처리할지 결정해야 한다. 설정 파일에 정의된 task 태그의 순서대로 실행하는 것으로 구현할 예정이다.

## 채널 처리

다중 태스크를 지원하게 되면 필연적으로 채널도 구현해야 한다. 채널은 그 종류도 다양하고 그 종류에 따라 구현 방법이 다르다. 채널 종류인 일반, urgent, broadcast와 UPPAAL2PLC에서 특별히 정의하는 `dataExchanged` 각각에 대해 구현 방법을 설명할 것이다.

![channel 1]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/channel_01.png){: .custom-align-center-img}
![channel 2]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/channel_02.png){: .custom-align-center-img}
*\<채널 동기화 시에 update 수행 순서\><br>
채널을 송신하는 쪽(! 기호)의 update가 먼저 수행된다. 위 그림의 경우 채널 동기화가 수행되면 x의 값은 2가 된다.*{: .custom-caption}

일반 채널은 송신자와 수신자가 1:1로 결정된다. 송신자가 해당 채널을 출력할 준비(guard 조건이나 목적지 location의 invariant 조건 등)가 되었을 때 똑같이 해당 채널을 입력받을 준비가 되어있는 태스크들 중 하나를 선택해서 동시에 전이를 수행한다. 동시에 수행되므로 출력 채널의 update와 입력 채널의 update의 실행 순서가 애매한데, UPPAAL에서는 출력 채널의 update를 먼저 실행하고 입력 채널의 update를 실행하는 것으로 보인다. 일반 채널을 구현하기 위해서는 각 채널마다 참조되는 태스크와 location, transition들을 리스트로 유지해놓는 것이 편할 것이다.

urgent 채널은 송신자와 수신자가 1:1로 결정되는 것은 일반 채널과 같지만, 송신자와 수신자의 해당 채널을 가진 전이가 모두 준비되었을 경우 그 시점에서 시간이 흐르지 않은 시점 내에 반드시 해당 전이가 일어나야 한다. 준비된 시점부터 전이가 일어나는 시점 사이에 시간은 흐르지 않지만 그 동안에 다른 동작은 일어날 수 있다. 그 동작으로 인해 urgent 채널이 있는 전이의 guard가 바뀌어서 전이가 disable되면 해당 전이는 동작하지 않을 수 있다. 구현 관점에서는 앞에서 결정적 동작으로 구현한다고 하였으므로, 일반 채널도 조건이 만족하면 즉시 전이를 수행할 것이니까 urgent 채널과 일반 채널은 동일하게 구현하면 된다.

![broadcast_channel 1]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/broadcast_channel_01.png){: .custom-align-center-img}
![broadcast_channel 2]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/broadcast_channel_02.png){: .custom-align-center-img}
![broadcast_channel 3]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/broadcast_channel_03.png){: .custom-align-center-img}
*\<broadcast 채널의 update 실행 순서\><br>
먼저 송신하는 쪽의 update가 수행되고, System declarations에 정의된 템플릿 순서대로 update가 수행된다. 위 그림의 경우 채널 동기화가 수행되고 나면 x의 값은 3이 된다. (위에서부터 아래 순서대로 정의된 경우)*{: .custom-caption}

broadcast 채널은 송신자와 수신자가 1:n으로 결정된다. n은 0일수도 있으며, 채널의 송신자가 준비되어 채널을 출력할 때 모든 준비된 채널 수신자가 동시에 전이를 수행한다. 역시 update의 실행 순서가 애매한데, 우선 송신자의 update가 먼저 실행되고 수신자들의 update가 순차적으로 실행된다. 실행 순서는 System declarations에 정의된 순서 대로다. 구현 관점에서는 준비된 전이에 broadcast 채널이 있는 경우 우선 동작시키고 그 채널의 수신자들을 모두 검색해 준비된 전이를 모두 수행하는 것으로 구현한다.

`dataExchanged` 채널은 주기가 시작되었음을 알리는 채널이다. 모든 태스크는 주기가 시작되었을 때 현재 location에서 `dataExchanged` 채널을 수신하는 전이가 있다면 그것을 1회 먼저 실행하도록 구현된다. 또한 한 주기 내에서 태스크 당 dataExchanged 채널은 1회 수신될 수 있도록 구현해야 한다.

## invariant

Invariant는 어떤 location에서 정의되며 태스크가 그 상태에 있을 때 반드시 만족해야 하는 조건을 의미한다. clock 변수 등의 변화로 인해 현재 location에서 더 이상 invariant를 만족하지 않게 될 경우 그 전에 location을 벗어나야 한다. 벗어날 수 없으면 그 invariant를 만족하지 않게 하는 수행, 시간의 흐름이나 변수의 변경이 불가능하다. 이렇게 invariant를 더 이상 만족하지 않을 수밖에 없는데 벗어날 조건이 만족하는 전이가 없으면 deadlock이 발생하게 된다.

![system template]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/system_template.png){: .custom-align-center-img}
*\<시스템 템플릿에 쓰인 invariant (tickClock <= PERIOD)\><br>
invariant가 없다면 전이 조건 tickClock >= PERIOD가 참이 되었다고 해도 WaitStep에 계속 머무를 수 있다. 이러한 동작을 제한하기 위해 invariant를 도입하면 tickClock 값이 PERIOD 값이 되는 순간 전이가 일어나도록 모델링할 수 있다.*{: .custom-caption}

구현 관점에서 invariant는 정말 복잡하다. 어떤 전이를 수행하고자 할 때, 그 전이의 guard나 채널 외에도 invariant 계산량이 상당하다. 우선 정확히 invariant를 계산하기 위해서는 update를 먼저 수행해야 한다. update에서 변경하는 값이 invariant에서 검사하는 조건 값과 의존성이 있을수도 있기 때문이다. 따라서 update를 임시적으로 수행해야 하는데, 이 때 전역변수와 해당 템플릿의 지역변수를 백업하고, update를 수행한 후 invariant를 검사하고 다시 백업한 데이터를 돌려놔야 하기 때문이다. 또한 하나의 전이의 수행 조건을 검사하기 위해 검사할 invariant의 양도 상당하다. 간단하게 구현한다면 전이가 수행되었을 상태를 기준으로 전체 태스크의 현재 location에 대한 invariant를 검사해야 한다. 그게 아니면 전이의 update와 의존성이 있는 invariant만 찾아서 검사해보는 것도 생각해볼 수 있다.

## Declarations 지원 문법

여기에서 제시하는 것들은 지금은 구현되어있지 않지만 그 구현 여부가 타임드 오토마타 의미론 구현에 크게 영향이 없는 것들이다. UPPAAL에서 지원하는 부수적인 기능들이며 대부분 parsing & generation 알고리즘을 변경하여 구현이 가능하다.

* range 타입 변수
* 변수를 콤마로 이어서 선언
* 템플릿 파라미터
* select
* 기타 등등

## urgent & committed location

location에도 채널처럼 타입이 존재한다. 일반 location은 별도의 제약이 없는 일반적인 location이며 의미론에서는 조건이 만족하면 이 상태에서 계속 머무를 수 있다. urgent location은 이 location에 들어온 시점부터 나가는 시점까지 시간이 흐르지 않아야 하는 것을 의미한다. 차이점은 urgent location은 단지 시간이 흐르지만 않으면 될 뿐이지만 committed location은 다른 태스크의 전이보다 반드시 해당 location에서 빠져나가는 전이가 먼저 수행되어야 한다는 것이다.

![urgent location]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/urgent_location.png){: .custom-align-center-img}
![committed location]({{site.baseurl}}/assets/post/17-07-26-UPPAAL2PLC/committed_location.png){: .custom-align-center-img}
*\<urgent location과 committed location\>*{: .custom-caption}

위 그림의 경우 가능한 트레이스는 다음과 같다.
* (U0, C0) -> (U1, C0) -> (U1, C1) -> (U1, C2) -> (U2, C2)
* (U0, C0) -> (U0, C1) -> (U0, C2) -> (U1, C2) -> (U2, C2)
* (U0, C0) -> (U1, C0) -> (U2, C0) -> (U2, C1) -> (U2, C2)

C1 상태로 진입했다면 다음 상태는 반드시 C2 상태여야 하며, 모든 경우에서 U1 상태나 C1 상태로 진입한 순간부터 둘 모두 U2, C2 상태가 될 때까지 시간 흐름이 없다. (수행 시간이 0이다, 즉 같은 주기 내에 반드시 실행되어야 한다.)

구현 관점에서는 결정적 동작으로 구현하였을 때 일반 location과 urgent location은 동작이 동일하다. 반면 committed location은 우선순위를 높게 두어서 별도로 처리해야 한다. 현재 시점에서 가능한 전이를 파악하기 전에 현재 committed location에 들어가 있는 태스크가 있다면 해당 태스크를 먼저 실행하도록 구현하면 된다.
