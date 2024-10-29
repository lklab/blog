---
title: LangChain - Chatbot
image: /assets/study/llm/default/langchain_logo.jpg
author: khlee
layout: post
last_modified_at: 2024-08-13
---

[LangChain 튜토리얼](https://python.langchain.com/docs/tutorials/chatbot/)을 읽고 정리한 내용이다.

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

## Prompt Templates

Prompt Templates을 사용해서 모델에 별도의 지침을 추가할 수 있다. 별도의 지침은 `system` 메시지라는 형태로 모델에 전달된다.

{% highlight python %}
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant. Answer all questions to the best of your ability in {language}.",
        ),
        MessagesPlaceholder(variable_name="messages"),
    ]
)

chain = prompt | model
{% endhighlight %}

`system`이라는 키로 별도의 메시지가 추가되었고, 그 메시지에는 `language`라는 템플릿 변수가 있는 것을 확인할 수 있다. 그리고 사용자 메시지는 `messages`에 담겨질 것이므로 이를 `MessagesPlaceholder`를 통해 정의하였다.

이제 여기에 message history를 적용한다.

{% highlight python %}
store = {}

def get_session_history(session_id: str) -> BaseChatMessageHistory:
    if session_id not in store:
        store[session_id] = InMemoryChatMessageHistory()
    return store[session_id]

with_message_history = RunnableWithMessageHistory(
    chain,
    get_session_history,
    input_messages_key="messages",
)
config = {"configurable": {"session_id": "abc5"}}
{% endhighlight %}

`with_message_history`를 선언하는 부분이 조금 바뀌었다. 우선 prompt template을 사용할 것이므로 `model` 대신 `chain`을 사용해야 한다. 그리고 템플릿에 변수가 `language`, `messages`로 두 개가 되었는데, 이 중에서 어떤 변수를 사용자 메시지로 사용할 것인지 정해주기 위해 `input_messages_key="messages"`를 추가하였다.

이제 메시지를 모델에 보내 보자.

{% highlight python %}
response = with_message_history.invoke(
    {"messages": [HumanMessage(content="hi! I'm todd")], "language": "Korean"},
    config=config,
)
print(response.content)

response = with_message_history.invoke(
    {"messages": [HumanMessage(content="whats my name?")], "language": "Korean"},
    config=config,
)
print(response.content)
{% endhighlight %}

{% highlight txt %}
안녕하세요, Todd님! 만나서 반가워요. 무엇을 도와드릴까요?
당신의 이름은 Todd입니다.
{% endhighlight %}

`system` 메시지를 통해 응답을 한국어로 하도록 지시했으므로 모델이 한국어로 응답하는 것을 확인할 수 있다.

## Managing Conversation History

지금까지의 구현은 message history에 별도 처리를 하지 않고 있어서 대화가 진행될수록 대화 내용이 아무런 제한 없이 계속 쌓이게 되어 있어서 LLM의 context window를 벗어날 가능성이 있다. 이를 해결하기 위한 간단한 방법 중 하나는 최근 특정 개수만큼의 대화 내용만 유지하는 것이다. LangChain에서는 이 기능을 `trim_messages`를 통해 제공한다.

{% highlight python %}
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage, trim_messages

trimmer = trim_messages(
    max_tokens=65,
    strategy="last",
    token_counter=model,
    include_system=True,
    allow_partial=False,
    start_on="human",
)

messages = [
    SystemMessage(content="you're a good assistant"),
    HumanMessage(content="hi! I'm bob"),
    AIMessage(content="hi!"),
    HumanMessage(content="I like vanilla ice cream"),
    AIMessage(content="nice"),
    HumanMessage(content="whats 2 + 2"),
    AIMessage(content="4"),
    HumanMessage(content="thanks"),
    AIMessage(content="no problem!"),
    HumanMessage(content="having fun?"),
    AIMessage(content="yes!"),
]

result = trimmer.invoke(messages)
print(result)
{% endhighlight %}

{% highlight txt %}
[
    SystemMessage(content="you're a good assistant"),
    HumanMessage(content='whats 2 + 2'),
    AIMessage(content='4'),
    HumanMessage(content='thanks'),
    AIMessage(content='no problem!'),
    HumanMessage(content='having fun?'),
    AIMessage(content='yes!')
]
{% endhighlight %}

이제 이 `trim_messages` 기능을 체인에 추가해 보자

{% highlight python %}
from operator import itemgetter
from langchain_core.runnables import RunnablePassthrough

chain = (
    RunnablePassthrough.assign(messages=itemgetter("messages") | trimmer)
    | prompt
    | model
)

response = chain.invoke(
    {
        "messages": messages + [HumanMessage(content="what's my name?")],
        "language": "English",
    }
)
print(response.content)
{% endhighlight %}

`chain`의 첫 번째 줄을 보면

{% highlight python %}
RunnablePassthrough.assign(messages=itemgetter("messages") | trimmer)
{% endhighlight %}

`RunnablePassthrough`와 `itemgetter`가 사용된 것을 볼 수 있다. 해당 줄은 `itemgetter("messages")`를 통해 `messages` 파라미터의 값, 즉 전체 대화 내역을 가져와서 `trimmer`를 통해 최근 메시지만 추려낸 후 `RunnablePassthrough.assign()`를 통해 다시 `messages` 파라미터에 대입하는 역할을 한다.

위 코드를 실행하면 이름을 전달한 부분이 `trimmer`에 의해 제거되었기 때문에 다음과 같이 모른다는 답변을 받게 된다.

{% highlight txt %}
I'm sorry, I don't have access to that information. How can I assist you today?
{% endhighlight %}

하지만 수학 문제에 관한 질문은 아직 남아있기 때문에 해당 내용에 관한 답변을 받을 수 있다.

{% highlight python %}
response = chain.invoke(
    {
        "messages": messages + [HumanMessage(content="what math problem did i ask")],
        "language": "English",
    }
)
print(response.content)
{% endhighlight %}

{% highlight txt %}
You asked "what's 2 + 2?"
{% endhighlight %}

참고로 `prompt`에서 특정 언어로 응답하라고 설정할 수 있는 변수인 `language`에 다른 언어를 대입해도 영어로만 응답하는데, 그 이유는 기존 대화 목록에 AI가 영어로 대답했기 때문일 것으로 추축된다. 모델 입장에서는 맨 처음에 다른 언어로 응답하라고 한 후 대화가 모두 영어로만 진행되었기 때문에 모델이 이번에도 영어로 응답해야 하는 것으로 판단하는 것 같다.

이제 message history를 적용한다.

{% highlight python %}
chain = (
    RunnablePassthrough.assign(messages=itemgetter("messages") | RunnableLambda(lambda x: messages + x) | trimmer)
    | prompt
    | model
)

with_message_history = RunnableWithMessageHistory(
    chain,
    get_session_history,
    input_messages_key="messages",
)
config = {"configurable": {"session_id": "abc20"}}
{% endhighlight %}

`chain`의 첫 번째 줄이 다시 바뀌었다.

{% highlight python %}
RunnablePassthrough.assign(messages=itemgetter("messages") | RunnableLambda(lambda x: messages + x) | trimmer)
{% endhighlight %}

중간에 `RunnableLambda(lambda x: messages + x)` 코드는 미리 정의된 앞선 대화 내용을 `messages`의 앞 부분에 추가하는 역할을 한다. 만약 미리 정의된 앞선 대화 내용을 사용하지 않을 경우 이 부분은 필요 없다.

이제 실행해 보면

{% highlight python %}
response = with_message_history.invoke(
    {
        "messages": [HumanMessage(content="what math problem did i ask")],
        "language": "English",
    },
    config=config,
)
print(response.content)

response = with_message_history.invoke(
    {
        "messages": [HumanMessage(content="whats my name?")],
        "language": "English",
    },
    config=config,
)
print(response.content)
{% endhighlight %}

{% highlight txt %}
You asked "what's 2 + 2?"
I'm sorry, I don't have access to your personal information.
{% endhighlight %}

잘 동작하는 것을 확인할 수 있다!
