---
title: LangChain ch01 - LCEL & Runnable
image: /assets/study/llm/default/langchain_logo.jpg
author: khlee
layout: post
---

[CH01 LangChain 시작하기](https://wikidocs.net/233341)을 읽고 정리한 내용이다.

## Prompt Templates

LangChain에서 프롬프트의 전체적인 구조를 정의한 것을 `Prompt Templates`이라고 한다. `Prompt Templates`을 사용하면 사용자 입력 등으로 받은 데이터를 템플릿과 조합하여 프롬프트를 쉽게 생성할 수 있다.

{% highlight python %}
from langchain_core.prompts import PromptTemplate

template = '{country}의 수도는 어디인가요?'
prompt = PromptTemplate.from_template(template)
result = prompt.invoke('대한민국')
print(result)
{% endhighlight %}

{% highlight txt %}
text='대한민국의 수도는 어디인가요?'
{% endhighlight %}

## LCEL

LangChain에서는 프롬프트 + 모델 + 파서 등으로 구성되는 일련의 과정들을 연결지을 수 있도록 [LangChain Expression Language (LCEL)](https://python.langchain.com/v0.2/docs/concepts/#langchain-expression-language-lcel)이라는 문법을 제공한다.

다음 예시와 같이 `|` 연산자를 통해 각 과정들을 연결해서 `chain`을 만들 수 있다.

{% highlight python %}
chain = prompt | model | parser
{% endhighlight %}

여기서 `prompt`, `model`, `parser`를 생성하는 것까지 포함한 전체 코드는 다음과 같다.

{% highlight python %}
from langchain_openai import ChatOpenAI
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

template = '{country}의 수도는 어디인가요?'
prompt = PromptTemplate.from_template(template)

model = ChatOpenAI(
    model='gpt-3.5-turbo',
    max_tokens=64,
    temperature=0.1,
)

parser = StrOutputParser()

chain = prompt | model | parser

answer = chain.invoke({'country': '대한민국'})
print(answer)
{% endhighlight %}

{% highlight txt %}
대한민국의 수도는 서울입니다.
{% endhighlight %}

## Runnable

`Runnable`을 사용하면 `chain`의 입력값에 대한 추가적인 처리를 하는 등 더 유연하게 LangChain을 활용할 수 있다.

{% highlight python %}
from operator import itemgetter

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnableLambda
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_template("{a} + {b} 는 무엇인가요?")
model = ChatOpenAI(
    model='gpt-3.5-turbo',
    max_tokens=64,
    temperature=0.1,
)

chain = (
    {
        "a": itemgetter("word1") | RunnableLambda(lambda x: len(x)),
        "b": itemgetter("word2") | RunnableLambda(lambda x: len(x)),
    }
    | prompt
    | model
)

answer = chain.invoke({"word1": "broccoli", "word2": "world"})
print(answer)
{% endhighlight %}

{% highlight txt %}
content='8 + 5는 13입니다.' response_metadata={'token_usage': {'completion_tokens': 9, 'prompt_tokens': 22, 'total_tokens': 31}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None} id='run-3e03983d-d822-4684-9a3d-421ad3746f1a-0' usage_metadata={'input_tokens': 22, 'output_tokens': 9, 'total_tokens': 31}
{% endhighlight %}

`itemgetter()` 함수를 사용하면 `chain`에 입력된 값을 가져올 수 있다. 위의 예시에서 `itemgetter("word1")`를 호출하면 `"broccoli"`를 얻게 된다.

`RunnableLambda`를 사용하면 특정 값에 대해 추가적인 처리를 할 수 있는 함수를 전달할 수 있다. 따라서 위의 예시에서 `itemgetter("word1") | RunnableLambda(lambda x: len(x))`를 수행하면 변수 `a`에는 `"broccoli"`의 길이인 `8`이 들어가게 된다.
