---
title: 2강 C++ 코딩 표준
image: /assets/study/main/unreal_logo_2.png
author: khlee
layout: post
---

[이득우의 언리얼 프로그래밍 Part1](https://www.inflearn.com/course/%EC%9D%B4%EB%93%9D%EC%9A%B0-%EC%96%B8%EB%A6%AC%EC%96%BC-%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%B0%8D-part-1/dashboard) 강의를 듣고 정리한 내용입니다. 유료 강의이기 때문에 일반적인 내용으로만 구성했으며, 생략한 부분이 많고 공개되지 않은 예제 코드나 이미지를 첨부하지 않았습니다. 내용을 제대로 알고자 한다면 해당 강의를 수강하기 바랍니다.

[언리얼 코딩 표준](https://docs.unrealengine.com/4.27/ko/ProductionPipelines/DevelopmentSetup/CodingStandard/) 문서를 보면서 진행

## 명명 규칙

* 언리얼 엔진은 PascalCasing을 사용함
* 접두사
	* 템플릿 클래스 접두사는 T입니다.
	* UObject 에서 상속하는 클래스 접두사는 U입니다.
	* AActor 에서 상속하는 클래스 접두사는 A입니다.
	* SWidget 에서 상속하는 클래스 접두사는 S입니다.
	* 추상 인터페이스인 클래스 접두사는 I입니다.
	* Enum(열거형)의 접두사는 E입니다.
	* Boolean(부울) 변수의 접두사는 b입니다(예: bPendingDestruction 또는 bHasFadedIn).
	* 그 외 대부분 클래스의 접두사는 F이나, 일부 서브시스템은 다른 글자를 사용하기도 합니다.
* 필수는 아니지만, 함수 파라미터 중 레퍼런스로 전달된 이후 함수가 그 값에 출력할 것으로 기대되는 것의 경우 이름 앞에 'Out' 접두사를 붙일 것을 추천합니다. 그래야 이 인수로 전달되는 값은 함수로 대체될 것임이 명확해집니다.

## 포팅 가능한 C++ 코드

C++의 `int`, `long` 등은 플랫폼에 따라 크기가 변할 수 있으므로 크기가 명시된 `int32`, `int64` 등을 사용해야 함. 그러나 루프 반복 변수 등 크기가 별로 중요하지 않은 경우 그냥 `int`를 사용해도 됨.

## 표준 라이브러리 사용

동일한 API에서 UE 언어와 표준 라이브러리 언어를 혼합하여 사용하지 않도록 합니다.

## Const

{% highlight cpp %}
const int* ptr = &num;
{% endhighlight %}

`ptr` 변경 가능, `*ptr` 변경 불가

{% highlight cpp %}
int* const ptr = &num;
{% endhighlight %}

`ptr` 변경 불가, `*ptr` 변경 가능

{% highlight cpp %}
const int* const ptr
{% endhighlight %}

`ptr` 변경 불가, `*ptr` 변경 불가

{% highlight cpp %}
// 나쁨 - const 배열 반환
const TArray<FString> GetSomeArray();

// 좋음 - const 배열로의 레퍼런스 반환
const TArray<FString>& GetSomeArray();

// 좋음 - const 배열로의 포인터 반환
const TArray<FString>* GetSomeArray();

// 나쁨 - const 배열로의 const 포인터 반환
const TArray<FString>* const GetSomeArray();
{% endhighlight %}

## 물리적 종속성

* 헤더 include 대신 앞선 선언(전방 선언)이 가능하면, 그리 하세요.
* 헤더 include는 꼭 필요한 경우만!

## 일반적인 스타일 문제

포인터 선언 시

{% highlight cpp %}
// Good
FShaderType* Ptr

// Bad
FShaderType *Ptr
FShaderType * Ptr
{% endhighlight %}


## API 디자인 지침

* 인터페이스(접두사가 'I' 인) 클래스는 항상 추상형이어야 하며, 멤버 변수가 있어서는 안 됩니다. 인터페이스는 순수 가상이 아닌 메서드를 포함할 수 있으며, 심지어 인라인 구현되는 한 가상이 아니거나 정적인 메서드도 포함할 수 있습니다.
