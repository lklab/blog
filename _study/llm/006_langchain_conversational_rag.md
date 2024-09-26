---
title: LangChain - Conversational RAG
image: /assets/study/llm/default/langchain_logo.jpg
author: khlee
layout: post
last_modified_at: 2024-08-28
---

[LangChain 튜토리얼](https://python.langchain.com/v0.2/docs/tutorials/qa_chat_history/)을 읽고 정리한 내용이다.

## 개요

[지난 글]({{ site.baseurl }}/study/llm/005_langchain_rag/)에서는 [RAG](https://brunch.co.kr/@ywkim36/146)에 대해 공부하였다. 이번에는 대화 형식으로 RAG를 구현하는 것에 알아 볼 것이다. 우선 다음 예시를 보자.

> Human: What is Task Decomposition? <br/>
> AI: Task decomposition involves breaking down complex tasks ... <br/>
> Human: What are common ways of doing it?

마지막 질문에 답을 하기 위해서는 [Chatbot]({{ site.baseurl }}/study/llm/003_langchain_chatbot/)에서 구현했던 것 처럼 지난 대화를 기억하고 있어야 할 것이다. 그리고 마지막 질문만 가지고는 무엇을 검색해야 하는지 알 수 없으므로 마지막 질문을 재구성하는 작업도 필요하다. 다음 그림은 이 과정을 도식화한 것이다.

![Conversational RAG chain]({{site.baseurl}}/assets/study/llm/006_langchain_conversational_rag/conversational_retrieval_chain-5c7a96abe29e582bc575a0a0d63f86b0.png)*출처: [https://python.langchain.com/v0.2/docs/tutorials/qa_chat_history/](https://python.langchain.com/v0.2/docs/tutorials/qa_chat_history/)*{: .custom-caption}

기존에는 Input query -> retriever -> LLM -> answer의 흐름대로 진행되었다면, 이번에는 Chat history와 `history_aware_retriever`라는 것이 추가되었다. `history_aware_retriever`는 현재 질문과 채팅 내역으로부터 LLM을 사용하여 현재 질문을 가공하고(Contextualizing the question) 이로부터 해당 질문에 관한 문서를 검색해오는(Retriever) 과정으로 구성되어 있다.

## Contextualizing the question

먼저 질문을 재구성하는 기능을 구현한다.

{% highlight python %}
from langchain.chains import create_history_aware_retriever
from langchain_core.prompts import MessagesPlaceholder

contextualize_q_system_prompt = (
    "Given a chat history and the latest user question "
    "which might reference context in the chat history, "
    "formulate a standalone question which can be understood "
    "without the chat history. Do NOT answer the question, "
    "just reformulate it if needed and otherwise return it as is."
)

contextualize_q_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", contextualize_q_system_prompt),
        MessagesPlaceholder("chat_history"),
        ("human", "{input}"),
    ]
)

history_aware_retriever = create_history_aware_retriever(
    llm, retriever, contextualize_q_prompt
)
{% endhighlight %}

프롬프트를 보면 `chat_history` 변수명을 가진 `MessagesPlaceholder`가 있다. 이것은 `system`과 `human` 메시지(사용자의 최근 질문) 사이에 기존의 대화 목록을 추가하는 역할을 한다. 그리고 [create_history_aware_retriever](https://python.langchain.com/v0.2/api_reference/langchain/chains/langchain.chains.history_aware_retriever.create_history_aware_retriever.html) 헬퍼 함수를 사용해서 체인을 만든다. 이 체인은 `input`과 `chat_history`를 입력으로 받고 `retriever`와 동일한 포맷의 값을 출력한다.

## RAG chain

이제 재구성된 질문을 받는 RAG 체인을 구현한다.

{% highlight python %}
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

qa_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        MessagesPlaceholder("chat_history"),
        ("human", "{input}"),
    ]
)

question_answer_chain = create_stuff_documents_chain(llm, qa_prompt)
rag_chain = create_retrieval_chain(history_aware_retriever, question_answer_chain)
{% endhighlight %}

프롬프트 자체는 Contextualizing the question에서 사용한 것과 동일하다. 그리고 체인을 구성하는 아래 두 줄 또한 [지난 글](http://127.0.0.1:4000/blog/study/llm/005_langchain_rag/#5-retrieval-and-generation-generate)에서 `create_stuff_documents_chain()` 함수와 `create_retrieval_chain()` 함수를 사용한 것과 동일한데, `retriever`만 앞에서 만든 `history_aware_retriever`로 변경하였다.

## Test RAG chain

여기까지 구현한 것을 다음 코드로 테스트 해 보자.

{% highlight python %}
from langchain_core.messages import AIMessage, HumanMessage

chat_history = []

question = "What is Task Decomposition?"
ai_msg_1 = rag_chain.invoke({"input": question, "chat_history": chat_history})
print(ai_msg_1["answer"])
print("----")

chat_history.extend(
    [
        HumanMessage(content=question),
        AIMessage(content=ai_msg_1["answer"]),
    ]
)

second_question = "What are common ways of doing it?"
ai_msg_2 = rag_chain.invoke({"input": second_question, "chat_history": chat_history})

print(ai_msg_2["answer"])
{% endhighlight %}

{% highlight txt %}
Task decomposition is the process of breaking down a complex task into smaller and simpler steps to facilitate problem-solving. It enables agents to manage and execute tasks more effectively by dividing them into manageable subgoals. Techniques like Chain of Thought and Tree of Thoughts help transform big tasks into multiple manageable tasks by guiding the model to think step by step or explore multiple reasoning possibilities at each step.
----
Task decomposition can be achieved through various methods such as using Language Model (LLM) with simple prompting, providing task-specific instructions, or incorporating human inputs. LLM can guide the decomposition process by asking questions like "Steps for XYZ" or "What are the subgoals for achieving XYZ?" Task-specific instructions, such as "Write a story outline," can also help break down tasks into more manageable components. Additionally, human inputs can play a role in decomposing tasks effectively.
{% endhighlight %}

결과가 잘 출력되는 것을 확인할 수 있다. 또한 LangSmith를 통해 `What are common ways of doing it?`이라는 질문이 어떻게 재구성되었는지 확인할 수 있다.

![Contextualizing the question]({{site.baseurl}}/assets/study/llm/006_langchain_conversational_rag/2024-08-28-140805.png)

## Stateful management of chat history

위의 테스트에서는 채팅 내역에 새로운 채팅을 코드에서 직접 추가했지만 [Chatbot](http://127.0.0.1:4000/blog/study/llm/003_langchain_chatbot/#message-history)에서 구현했던 것처럼 채팅 내역을 자동으로 업데이트하는 기능을 구현할 것이다.

{% highlight python %}
from langchain_core.chat_history import BaseChatMessageHistory
from langchain_community.chat_message_histories import ChatMessageHistory
from langchain_core.runnables.history import RunnableWithMessageHistory

store = {}

def get_session_history(session_id: str) -> BaseChatMessageHistory:
    if session_id not in store:
        store[session_id] = ChatMessageHistory()
    return store[session_id]

conversational_rag_chain = RunnableWithMessageHistory(
    rag_chain,
    get_session_history,
    input_messages_key="input",
    history_messages_key="chat_history",
    output_messages_key="answer",
)
{% endhighlight %}

`history_messages_key`와 `output_messages_key`가 추가되었는데, 각각 채팅 내역과 답변에 해당하는 키값을 지정하는 역할을 한다.

## Test full chain

{% highlight python %}
response = conversational_rag_chain.invoke(
    {"input": "What is Task Decomposition?"},
    config={"configurable": {"session_id": "abc123"}}, # constructs a key "abc123" in `store`.
)
print(response["answer"])
print("----")

response = conversational_rag_chain.invoke(
    {"input": "What are common ways of doing it?"},
    config={"configurable": {"session_id": "abc123"}},
)
print(response["answer"])
{% endhighlight %}

{% highlight txt %}
Task decomposition involves breaking down complex tasks into smaller and simpler steps to make them more manageable. This process helps in enhancing model performance on hard tasks by guiding the model to "think step by step" and decompose the task into more understandable components. Techniques like Chain of Thought (CoT) and Tree of Thoughts extend task decomposition by exploring multiple reasoning possibilities at each step and creating a structured approach to problem-solving.
----
Task decomposition can be achieved through various methods, including:
1. Using Language Model (LLM) with simple prompting techniques like asking for steps or subgoals.
2. Providing task-specific instructions tailored to the nature of the task, such as asking to write a story outline for novel writing.
3. Incorporating human inputs to guide the decomposition process and ensure the tasks are broken down effectively into manageable components.
{% endhighlight %}

## Agents

앞에서 구현한 내용을 Agent를 사용해서 동일하게 구현할 수 있다. Agent는 LLM의 추론 기능을 사용해서 실행 중에 채팅 내역을 확인할지, 검색할지, 또는 다른 과정 없이 바로 답변할지 등등을 결정한다. Agent를 사용하면 다음과 같은 장점이 있다.

* Agent는 Contextualizing을 명시적으로 구현할 필요 없이 채팅 내역 등을 확인해서 retriever에 전달할 입력을 직접 생성함
* Agent는 query에 따라 retrieval step을 여러 번 실행할수도 한 번도 실행하지 않을 수도 있음 (인사말과 같은 query에는 retrieval step을 수행할 필요가 없으므로)

## Retrieval tool

Agent는 `tools`을 사용해서 자신이 어떻게 동작할지 결정한다. 여기서는 retriever tool을 사용할 것이다.

{% highlight python %}
from langchain.tools.retriever import create_retriever_tool

tool = create_retriever_tool(
    retriever,
    "blog_post_retriever",
    "Searches and returns excerpts from the Autonomous Agents blog post.",
)
tools = [tool]
{% endhighlight %}

## Agent constructor

이제 agent를 만들 것이다. 먼저 `langgraph` 패키지 설치가 필요하다.

{% highlight bash %}
$ pip install -U langgraph
{% endhighlight %}
<!-- $ -->

이제 다음과 같이 agent를 생성할 수 있다.

{% highlight python %}
from langgraph.prebuilt import create_react_agent

agent_executor = create_react_agent(llm, tools)
{% endhighlight %}

이 agent를 다음과 같이 테스트할 수 있다.

{% highlight python %}
query = "What is Task Decomposition?"

for s in agent_executor.stream(
    {"messages": [HumanMessage(content=query)]},
):
    print(s)
    print("----")
{% endhighlight %}

{% highlight txt %}
{'agent': {'messages': [AIMessage(content='Task decomposition is a problem-solving strategy used in fields such as project management, software development, and artificial intelligence. It involves breaking down a complex task or project into smaller, more manageable subtasks or components. By decomposing a task into smaller parts, it becomes easier to understand, plan, and execute.\n\nThe process of task decomposition typically involves the following steps:\n\n1. Identify the main task or goal: Clearly define the overall objective or task that needs to be accomplished.\n\n2. Break down the task: Divide the main task into smaller, more specific subtasks or components. These subtasks should be more manageable and easier to tackle.\n\n3. Organize the subtasks: Arrange the subtasks in a logical sequence or hierarchy to ensure that they contribute to the overall completion of the main task.\n\n4. Assign responsibilities: Assign each subtask to individuals or teams based on their expertise and skills.\n\n5. Monitor progress: Keep track of the progress of each subtask to ensure that the overall task is on track and deadlines are being met.\n\nTask decomposition helps in simplifying complex tasks, improving efficiency, and facilitating collaboration among team members. It also allows for better resource allocation and risk management.', response_metadata={'token_usage': {'completion_tokens': 239, 'prompt_tokens': 68, 'total_tokens': 307}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-8e032a46-93d2-4685-bc21-b3e8538cfa71-0', usage_metadata={'input_tokens': 68, 'output_tokens': 239, 'total_tokens': 307})]}}
{% endhighlight %}

## MemorySaver

LangGraph에는 '지속성'이 내장되어 있기 때문에 `ChatMessageHistory`가 필요 없다. 대신에 `checkpointer`를 설정해 주면 된다.

{% highlight python %}
# create a memory saver
from langgraph.checkpoint.memory import MemorySaver # need to install langgraph: pip install -U langgraph
memory = MemorySaver()

# create a agent
from langgraph.prebuilt import create_react_agent
agent_executor = create_react_agent(llm, tools, checkpointer=memory)
{% endhighlight %}

## Test the agent

{% highlight python %}
from langchain_core.messages import HumanMessage

config = {"configurable": {"thread_id": "abc123"}}
queries = [
    "Hi! I'm bob",
    "What is Task Decomposition?",
    "What according to the blog post are common ways of doing it? redo the search",
    "What's my name?",
]

for query in queries :
    print("query: " + query)
    print("----")
    for s in agent_executor.stream(
        {"messages": [HumanMessage(content=query)]}, config=config
    ):
        print(s)
        print("----")
    print()
{% endhighlight %}

{% highlight txt %}
query: Hi! I'm bob
----
{'agent': {'messages': [AIMessage(content='Hello Bob! How can I assist you today?', response_metadata={'token_usage': {'completion_tokens': 11, 'prompt_tokens': 67, 'total_tokens': 78}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-da6ac086-ab7a-4566-982f-bf4e16cd9db4-0', usage_metadata={'input_tokens': 67, 'output_tokens': 11, 'total_tokens': 78})]}}
----

query: What is Task Decomposition?
----
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_62oCQsjQKRxonPmIZ0FrUqLj', 'function': {'arguments': '{"query":"Task Decomposition"}', 'name': 'blog_post_retriever'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 19, 'prompt_tokens': 91, 'total_tokens': 110}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-6cf4ae3c-accc-4839-a678-cd8397216776-0', tool_calls=[{'name': 'blog_post_retriever', 'args': {'query': 'Task Decomposition'}, 'id': 'call_62oCQsjQKRxonPmIZ0FrUqLj', 'type': 'tool_call'}], usage_metadata={'input_tokens': 91, 'output_tokens': 19, 'total_tokens': 110})]}}
----
{'tools': {'messages': [ToolMessage(content='Fig. 1. Overview of a LLM-powered autonomous agent system. ... (생략)', name='blog_post_retriever', tool_call_id='call_62oCQsjQKRxonPmIZ0FrUqLj')]}}
----
{'agent': {'messages': [AIMessage(content='Task decomposition is a technique used in complex tasks where the task is broken down into smaller and simpler steps. This approach helps in managing and tackling the overall task more effectively. One method of task decomposition is using prompts like "Steps for XYZ" to guide models in breaking down tasks into manageable steps. Another extension of this technique is the Tree of Thoughts, which explores multiple reasoning possibilities at each step by creating a tree structure of thoughts.\n\nOverall, task decomposition can be carried out by utilizing prompts, task-specific instructions, or human inputs to break down a complex task into smaller components for better understanding and execution.', response_metadata={'token_usage': {'completion_tokens': 121, 'prompt_tokens': 611, 'total_tokens': 732}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-3447d068-6f53-42d7-b6ba-9160dd0d4bf9-0', usage_metadata={'input_tokens': 611, 'output_tokens': 121, 'total_tokens': 732})]}}
----

query: What according to the blog post are common ways of doing it? redo the search
----
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_ECRRzBI7jWycf3jfSoPKvqol', 'function': {'arguments': '{"query":"Common ways of task decomposition"}', 'name': 'blog_post_retriever'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 21, 'prompt_tokens': 755, 'total_tokens': 776}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-5f38b8ec-2e03-40ff-9761-c054c5adb02f-0', tool_calls=[{'name': 'blog_post_retriever', 'args': {'query': 'Common ways of task decomposition'}, 'id': 'call_ECRRzBI7jWycf3jfSoPKvqol', 'type': 'tool_call'}], usage_metadata={'input_tokens': 755, 'output_tokens': 21, 'total_tokens': 776})]}}
----
{'tools': {'messages': [ToolMessage(content='Fig. 1. Overview of a LLM-powered autonomous agent system. ... (생략)', name='blog_post_retriever', tool_call_id='call_ECRRzBI7jWycf3jfSoPKvqol')]}}   
----
{'agent': {'messages': [AIMessage(content='According to the blog post, common ways of task decomposition include:\n\n1. Using prompts with LLM (Large Language Models) such as "Steps for XYZ" or "What are the subgoals for achieving XYZ?" to guide models in breaking down tasks into smaller steps.\n2. Utilizing task-specific instructions, for example, providing instructions like "Write a story outline" for tasks like writing a novel.\n3. Involving human inputs in the task decomposition process to break down complex tasks into more manageable components.\n\nThese methods help in effectively decomposing tasks into smaller and simpler steps for better understanding and execution.', response_metadata={'token_usage': {'completion_tokens': 123, 'prompt_tokens': 1300, 'total_tokens': 1423}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-fe571e72-b565-48fa-8885-3d977e6e78c9-0', usage_metadata={'input_tokens': 1300, 'output_tokens': 123, 'total_tokens': 1423})]}}
----

query: What's my name?
----
{'agent': {'messages': [AIMessage(content='Your name is Bob! How can I help you further, Bob?', response_metadata={'token_usage': {'completion_tokens': 15, 'prompt_tokens': 1435, 'total_tokens': 1450}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-fce55698-c0b2-428f-872a-88f7f4f4548f-0', usage_metadata={'input_tokens': 1435, 'output_tokens': 15, 'total_tokens': 1450})]}}
----
{% endhighlight %}

출력 결과를 보면, 검색이 필요한 질문인 경우 검색을 수행하고 그 결과인 `ToolMessage`가 포함되어 있는 반면, 간단한 인사와 같이 검색이 필요하지 않은 질문인 경우 `ToolMessage`가 없는 것을 확인할 수 있다.
