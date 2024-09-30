---
title: 1강 헬로 언리얼!
image: /assets/study/main/unreal_logo_2.png
author: khlee
layout: post
last_modified_at: 2024-01-18
---

[이득우의 언리얼 프로그래밍 Part1](https://www.inflearn.com/course/%EC%9D%B4%EB%93%9D%EC%9A%B0-%EC%96%B8%EB%A6%AC%EC%96%BC-%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%B0%8D-part-1/dashboard) 강의를 듣고 정리한 내용입니다. 유료 강의이기 때문에 일반적인 내용으로만 구성했으며, 생략한 부분이 많고 공개되지 않은 예제 코드나 이미지를 첨부하지 않았습니다. 내용을 제대로 알고자 한다면 해당 강의를 수강하기 바랍니다.

## GameInstance

`GameInstance` 클래스를 상속받는 `MyGameInstance` 클래스를 생성하고 `Init()` 함수를 오버라이드한다.

{% highlight cpp %}
// MyGameInstance.h

UCLASS()
class HELLOUNREAL_API UMyGameInstance : public UGameInstance
{
	GENERATED_BODY()

public:
	virtual void Init() override;
}
{% endhighlight %}

{% highlight cpp %}
// MyGameInstance.cpp

void UMyGameInstance::Init()
{
	Super::Init();
}
{% endhighlight %}

언리얼에서는 `Super`라고 쓰면 자동으로 부모 클래스를 가리키게 됨

## 로그 출력

`UE_LOG` 매크로 사용
* `LogTemp`: 로그 카테고리
* `Log`: 로그 수준 (경고 또는 에러가 될 수 있음)

{% highlight cpp %}
// MyGameInstance.cpp

void UMyGameInstance::Init()
{
	Super::Init();
	UE_LOG(LogTemp, Log, TEXT("%s"), TEXT("Hello Unreal"));
}
{% endhighlight %}

## MyGameInstance로 교체

엔진 기본 사용하는 `GameInstance`가 아닌 우리가 만든 `MyGameInstance`로 교체해야 함

Project Settings -> Maps & Modes -> Game Instance 항목의 값을 `MyGameInstance`로 변경

## 빌드 관련 단축키

* 언리얼 에디터 켜져 있는 상태에서는 라이브 코딩을 실행하기: Ctrl + Alt + F11
* 언리얼 에디터 꺼져 있는 상태에서 빌드하고 에디터 실행하기: Ctrl + F5
* 언리얼 에디터 꺼져 있는 상태에서 컴파일만 하기: Ctrl + F7
