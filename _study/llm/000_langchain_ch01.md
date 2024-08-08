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

만약 다른 모델을 사용하고 싶은 경우 `langchain-` 뒤에 다음 예시와 같이 해당 모델을 적으면 된다. 자세한 내용은 [여기](https://python.langchain.com/v0.2/docs/tutorials/llm_chain/#using-language-models) 참고.

* Anthropic: `pip install -qU langchain-anthropic`
* Google: `pip install -qU langchain-google-vertexai`
* Cohere: `pip install -qU langchain-cohere`
* NVIDIA: `pip install -qU langchain-nvidia-ai-endpoints`
* FireworksAI: `pip install -qU langchain-fireworks`
* Groq: `pip install -qU langchain-groq`
* MistralAI: `pip install -qU langchain-mistralai`

## OpenAI API 키 발급 및 테스트

[OpenAI API 웹사이트](https://platform.openai.com/docs/overview)에 접속해서 로그인한 후 신용카드를 등록하고 일정 금액을 충전한다.

[Dashboard의 API keys](https://platform.openai.com/api-keys)에서 새로운 secret key를 생성한다.

프로젝트의 루트에 `apikeys.json`라는 파일을 만들고 다음과 같은 내용을 붙여넣는다. 파일이름은 바꿔도 상관 없다.

{% highlight json %}
{
    "OPENAI_API_KEY": "{발급받은 키}"
}
{% endhighlight %}

## OpenAI API 사용

파이썬 파일을 하나 만들고 다음과 같이 API key를 읽어온다.

{% highlight python %}
import json
import os

# load API key
with open('apikeys.json') as f:
    keys = json.load(f)

os.environ["OPENAI_API_KEY"] = keys['OPENAI_API_KEY']
{% endhighlight %}

모델을 생성하고 초기화한다.

{% highlight python %}
# initialize model
from langchain_openai import ChatOpenAI
model = ChatOpenAI(model="gpt-4")
{% endhighlight %}

모델에 보낼 메시지를 생성하고 보낸다.

{% highlight python %}
# send messages
from langchain_core.messages import HumanMessage, SystemMessage

messages = [
    SystemMessage(content="Translate the following from English into Italian"),
    HumanMessage(content="hi!"),
]

aiMessage = model.invoke(messages)
print(aiMessage)
{% endhighlight %}

실행하면 다음과 같은 결과를 출력한다.

{% highlight txt %}
content='Ciao!' response_metadata={'token_usage': {'completion_tokens': 3, 'prompt_tokens': 20, 'total_tokens': 23}, 'model_name': 'gpt-4-0613', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None} id='run-4571bf06-060e-4799-acfd-08837c9b09c7-0' usage_metadata={'input_tokens': 20, 'output_tokens': 3, 'total_tokens': 23}
{% endhighlight %}

`OutputParsers`를 사용해서 응답 문자열만 가져온다.

{% highlight python %}
# parse output
from langchain_core.output_parsers import StrOutputParser

parser = StrOutputParser()
result = parser.invoke(aiMessage)
print(result)
{% endhighlight %}

다음과 같은 결과를 출력한다.

{% highlight txt %}
Ciao!
{% endhighlight %}
