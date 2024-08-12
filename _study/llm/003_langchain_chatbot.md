---
title: LangChain - Chatbot
image: /assets/study/llm/default/langchain_logo.jpg
author: khlee
layout: post
---

[LangChain 튜토리얼](https://python.langchain.com/v0.2/docs/tutorials/chatbot/)을 읽고 정리한 내용이다.

## 이전 대화 기억하기

{% highlight python %}
from langchain_openai import ChatOpenAI
model = ChatOpenAI(model="gpt-3.5-turbo")

from langchain_core.messages import HumanMessage
result = model.invoke([HumanMessage(content="Hi! I'm Bob")])
print(result.content)

result = model.invoke([HumanMessage(content="What's my name?")])
print(result.content)
{% endhighlight %}

위 코드에서는 LLM 모델에 `Hi! I'm Bob`, `What's my name?`이라는 두 개의 메시지를 보냈다. 각각의 응답을 보자.

{% highlight txt %}
Hello Bob! How can I assist you today?
I'm sorry, I do not have the ability to know your name as I am an AI assistant.
{% endhighlight %}

이전 대화에서 사용자는 모델에 자신의 이름이 `Bob`이라고 알려주었음에도, 자신의 이름을 묻는 질문에 적절한 대답을 하지 못하고 있다. 이는 각각의 메시지가 독립적으로 처리되어 이전의 메시지를 알지 못하기 때문이다. 이를 해결하기 위해 다음과 같이 이전 대화 내역을 모델에 모두 전달하는 방법이 있다.

{% highlight python %}
from langchain_core.messages import HumanMessage
from langchain_core.messages import AIMessage

result = model.invoke(
    [
        HumanMessage(content="Hi! I'm Bob"),
        AIMessage(content="Hello Bob! How can I assist you today?"),
        HumanMessage(content="What's my name?"),
    ]
)
print(result.content)
{% endhighlight %}

{% highlight txt %}
Your name is Bob.
{% endhighlight %}

이제 모델이 이전의 대화 내용을 참고하여 이름을 정확히 알려줄 수 있게 되었다.

## Message History

`Message History`를 사용하면 모델과의 대화 내용을 별도의 저장소에 저장해서 이후에 활용할 수 있다. 우선 다음과 같이 `langchain_community` 설치가 필요하다.

{% highlight bat %}
> pip install langchain_community
{% endhighlight %}

이제 `Message History`를 사용하기 위한 기본적인 코드를 구현한다.

{% highlight python %}
from langchain_core.chat_history import (
    BaseChatMessageHistory,
    InMemoryChatMessageHistory,
)
from langchain_core.runnables.history import RunnableWithMessageHistory

store = {}

def get_session_history(session_id: str) -> BaseChatMessageHistory:
    if session_id not in store:
        store[session_id] = InMemoryChatMessageHistory()
    return store[session_id]

with_message_history = RunnableWithMessageHistory(model, get_session_history)
{% endhighlight %}

각각의 대화 내용은 `session_id`를 통해 구분된다. 이를 저장하기 위해 `store` dictionary를 사용하였다.

이제 다음과 같이 `session_id`를 설정하는 `config`를 정의한다.

{% highlight python %}
config = {"configurable": {"session_id": "abc2"}}
{% endhighlight %}

{% highlight python %}
response = with_message_history.invoke(
    [HumanMessage(content="Hi! I'm Bob")],
    config=config,
)
print("[abc2] " + response.content)

response = with_message_history.invoke(
    [HumanMessage(content="What's my name?")],
    config=config,
)
print("[abc2] " + response.content)
{% endhighlight %}

`config`와 함께 사용자 메시지를 모델에 전달하면 다음과 같이 원하는 응답을 얻을 수 있다.

{% highlight txt %}
[abc2] Hello Bob! How can I assist you today?
[abc2] Your name is Bob.
{% endhighlight %}

한편 세션을 변경하고 동일한 메시지를 전달하면 이전의 대화 내역이 없기 때문에 다음과 같이 모른다는 응답을 받게 된다.

{% highlight python %}
config = {"configurable": {"session_id": "abc3"}}
response = with_message_history.invoke(
    [HumanMessage(content="What's my name?")],
    config=config,
)
print("[abc3] " + response.content)
{% endhighlight %}

{% highlight txt %}
[abc3] I'm sorry, I don't know your name as I am an AI assistant.
{% endhighlight %}

언제든지 다시 원래 세션으로 돌아갈 수 있다.

{% highlight python %}
config = {"configurable": {"session_id": "abc2"}}
response = with_message_history.invoke(
    [HumanMessage(content="What's my name?")],
    config=config,
)
print("[abc2] " + response.content)
{% endhighlight %}

{% highlight txt %}
[abc2] Your name is Bob.
{% endhighlight %}
