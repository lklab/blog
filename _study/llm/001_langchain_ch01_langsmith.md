---
title: LangChain ch01 - LangSmith
image: /assets/study/llm/default/langchain_logo.jpg
author: khlee
layout: post
last_modified_at: 2024-08-08
---

[CH01 LangChain 시작하기](https://wikidocs.net/233341)을 읽고 정리한 내용이다.

## LangSmith 추적 설정

LangSmith는 LLM 애플리케이션 개발, 모니터링 및 테스트 를 위한 플랫폼이다. LangSmith는 다음과 같은 문제를 추적하는 데 도움이 될 수 있다.

* 예상치 못한 최종 결과
* 에이전트가 루핑되는 이유
* 체인이 예상보다 느린 이유
* 에이전트가 각 단계에서 사용한 토큰 수

[https://smith.langchain.com/](https://smith.langchain.com/)에 접속하여 로그인한 후 API 키를 만든다. 역시 다음과 같이 API 키를 `apikeys.json` 파일에 저장한다.

{% highlight json %}
{
    "OPENAI_API_KEY": "{발급받은 키}",
    "LANGCHAIN_API_KEY": "{발급받은 키}"
}
{% endhighlight %}

## LangSmith 적용

앞서서 OpenAI API를 적용했던 것과 마찬가지로 API 키를 읽어와서 LangSmith를 사용 설정한다.

{% highlight python %}
with open('apikeys.json') as f:
    keys = json.load(f)

os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = keys['LANGCHAIN_API_KEY']
{% endhighlight %}

그러면 이렇게 추적 결과를 알 수 있다.

![LangSmith]({{site.baseurl}}/assets/study/llm/001_langchain_ch01_langsmith/2024-08-08-153823.png)
