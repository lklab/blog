---
title: LangChain ch01 - 시작하기
image: /assets/study/llm/default/langchain_logo.jpg
author: khlee
layout: post
---

[CH01 LangChain 시작하기](https://wikidocs.net/233341)을 읽고 정리한 내용이다.

## 개요

LangChain 은 언어 모델을 활용해 다양한 애플리케이션을 개발할 수 있는 프레임워크로, 다양한 LLM을 추상화하여 어플리케이션에서 사용할 수 있도록 해 준다. LangChain에 대해 잘 설명된 글이 있어서 참고하면 좋을 것 같다. [https://brunch.co.kr/@ywkim36/147](https://brunch.co.kr/@ywkim36/147)

## 설치

다음과 같은 명령어로 설치한다.

{% highlight bat %}
> pip install langchain
> pip install -qU langchain-openai
{% endhighlight %}

## OpenAI API 키 발급 및 테스트

[OpenAI API 웹사이트](https://platform.openai.com/docs/overview)에 접속해서 로그인한 후 신용카드를 등록하고 일정 금액을 충전한다.

[Dashboard의 API keys](https://platform.openai.com/api-keys)에서 새로운 secret key를 생성한다.

프로젝트의 루트에 `apikeys.json`라는 파일을 만들고 다음과 같은 내용을 붙여넣는다. 파일이름은 바꿔도 상관 없다.

{% highlight json %}
{
    "OPENAI_API_KEY": "{발급받은 키}"
}
{% endhighlight %}

## LangSmith 추적 설정

LangSmith는 LLM 애플리케이션 개발, 모니터링 및 테스트 를 위한 플랫폼이다. 추적은 다음과 같은 문제를 추적하는 데 도움이 될 수 있다.

* 예상치 못한 최종 결과
* 에이전트가 루핑되는 이유
* 체인이 예상보다 느린 이유
* 에이전트가 각 단계에서 사용한 토큰 수

[https://smith.langchain.com/](https://smith.langchain.com/)에 접속하여 로그인한 후 API 키를 만든다. 역시 다음과 같이 `apikeys.json` 파일에 저장한다.

{% highlight json %}
{
    "OPENAI_API_KEY": "{발급받은 키}",
    "LANGCHAIN_API_KEY": "{발급받은 키}"
}
{% endhighlight %}

## OpenAI API 사용(GPT-4o 멀티모달)



