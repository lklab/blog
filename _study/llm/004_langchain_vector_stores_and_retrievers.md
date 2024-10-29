---
title: LangChain - Vector stores and retrievers
image: /assets/study/llm/default/langchain_logo.jpg
author: khlee
layout: post
last_modified_at: 2024-08-14
---

[LangChain 튜토리얼](https://python.langchain.com/docs/tutorials/retrievers/)을 읽고 정리한 내용이다.

## Documents

LangChain에서는 문서를 추상화하는 [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 클래스를 제공한다. `Document`는 다음과 같은 두 개의 속성을 포함한다.

* `page_content`: 문서의 내용
* `metadata`: 임의로 설정할 수 있는 메타데이터로, 문서의 출처나 다른 문서와의 관계 등에 관한 내용이 들어갈 수 있다.

샘플 `Document`를 다음과 같이 생성한다.

{% highlight python %}
from langchain_core.documents import Document

documents = [
    Document(
        page_content="Dogs are great companions, known for their loyalty and friendliness.",
        metadata={"source": "mammal-pets-doc"},
    ),
    Document(
        page_content="Cats are independent pets that often enjoy their own space.",
        metadata={"source": "mammal-pets-doc"},
    ),
    Document(
        page_content="Goldfish are popular pets for beginners, requiring relatively simple care.",
        metadata={"source": "fish-pets-doc"},
    ),
    Document(
        page_content="Parrots are intelligent birds capable of mimicking human speech.",
        metadata={"source": "bird-pets-doc"},
    ),
    Document(
        page_content="Rabbits are social animals that need plenty of space to hop around.",
        metadata={"source": "mammal-pets-doc"},
    ),
]
{% endhighlight %}

5개의 `Document`를 생성했으며, 각각의 메타데이터로 `source`를 포함하고 있다.

## Vector stores

`Vector stores`는 구조화되지 않은 데이터(예를 들어 위의 `page_content`와 같이 특별한 구조가 없는 텍스트)를 저장하고 검색하는 방법이다. `Vector stores`는 텍스트와 연관된 벡터를 저장하고, 쿼리가 주어지면 그것을 동일한 차원의 벡터로 변환한 후 가장 유사한 벡터에 해당하는 텍스트를 찾는 방식으로 동작한다.

LangChain의 `VectorStore` 객체는 텍스트나 `Document` 객체를 추가하거나 쿼리하는 메서드를 제공한다. 이 객체는 텍스트가 벡터로 변환되는 방식을 결정하는 임베딩 모델로 초기화 된다. 여기서는 `OpenAIEmbeddings`을 사용할 것이다.

LangChain에는 다양한 vector store 기술과의 통합이 포함되어 있다. 일부 vector store는 클라우드에서 실행되거나 별도의 인프라에서 실행되지면 여기서는 로컬에서 실행할 수 있는 `Chroma`를 사용할 것이다.

{% highlight bat %}
> pip install langchain-chroma
{% endhighlight %}

{% highlight python %}
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings

vectorstore = Chroma.from_documents(
    documents,
    embedding=OpenAIEmbeddings(),
)
{% endhighlight %}

`Chroma`의 `from_documents()` 함수를 호출하면 `Document`로부터 `VectorStore` 객체를 얻을 수 있다.

`VectorStore` 객체는 다음과 같이 다양한 쿼리 방법을 제공한다.

* 동기적 또는 비동기적 쿼리
* 문자열 또는 벡터로 쿼리
* `similarity scores`를 반환할 수 있음
* By similarity and maximum marginal relevance (to balance similarity with query to diversity in retrieved results).

예를 들어 'cat'과의 유사성을 확인하려면

{% highlight python %}
response = vectorstore.similarity_search("cat")
print(response)
{% endhighlight %}

{% highlight txt %}
[
    Document(metadata={'source': 'mammal-pets-doc'}, page_content='Cats are independent pets that often enjoy their own space.'),
    Document(metadata={'source': 'mammal-pets-doc'}, page_content='Dogs are great companions, known for their loyalty and friendliness.'),
    Document(metadata={'source': 'mammal-pets-doc'}, page_content='Rabbits are social animals that need plenty of space to hop around.'),
    Document(metadata={'source': 'bird-pets-doc'}, page_content='Parrots are intelligent birds capable of mimicking human speech.')
]
{% endhighlight %}

유사도 점수와 함께 확인하려면

{% highlight python %}
response = vectorstore.similarity_search_with_score("cat")
print(response)
{% endhighlight %}

{% highlight txt %}
[
    (Document(metadata={'source': 'mammal-pets-doc'}, page_content='Cats are independent pets that often enjoy their own space.'), 0.375326931476593),
    (Document(metadata={'source': 'mammal-pets-doc'}, page_content='Dogs are great companions, known for their loyalty and friendliness.'), 0.4833090305328369),
    (Document(metadata={'source': 'mammal-pets-doc'}, page_content='Rabbits are social animals that need plenty of space to hop around.'), 0.4958883225917816),
    (Document(metadata={'source': 'bird-pets-doc'}, page_content='Parrots are intelligent birds capable of mimicking human speech.'), 0.4974174499511719)
]
{% endhighlight %}

또는 문자열 대신 벡터와의 유사성도 확인할 수 있다.

{% highlight python %}
embedding = OpenAIEmbeddings().embed_query("cat")
response = vectorstore.similarity_search_by_vector(embedding)
print(response)
{% endhighlight %}

{% highlight txt %}
[
    Document(metadata={'source': 'mammal-pets-doc'}, page_content='Cats are independent pets that often enjoy their own space.'),
    Document(metadata={'source': 'mammal-pets-doc'}, page_content='Dogs are great companions, known for their loyalty and friendliness.'),
    Document(metadata={'source': 'mammal-pets-doc'}, page_content='Rabbits are social animals that need plenty of space to hop around.'),
    Document(metadata={'source': 'bird-pets-doc'}, page_content='Parrots are intelligent birds capable of mimicking human speech.')
]
{% endhighlight %}

## Retrievers

LangChain의 `VectorStore`는 `Runnable`이 아니기 때문에 LCEL chain을 구성하려면 `Runnable`인 `Retriever`로 변환할 필요가 있다.

{% highlight python %}
from langchain_core.documents import Document
from langchain_core.runnables import RunnableLambda

retriever = RunnableLambda(vectorstore.similarity_search).bind(k=1)  # select top result

response = retriever.batch(["cat", "shark"])
print(response)
{% endhighlight %}

{% highlight txt %}
[
    [Document(metadata={'source': 'mammal-pets-doc'}, page_content='Cats are independent pets that often enjoy their own space.')],
    [Document(metadata={'source': 'fish-pets-doc'}, page_content='Goldfish are popular pets for beginners, requiring relatively simple care.')]
]
{% endhighlight %}

또는 `VectorStore`의 `as_retriever()` 함수를 사용해서 `Retriever`로 변환할 수 있다.

{% highlight python %}
retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 1},
)

response = retriever.batch(["cat", "shark"])
print(response)
{% endhighlight %}

{% highlight txt %}
[
    [Document(metadata={'source': 'mammal-pets-doc'}, page_content='Cats are independent pets that often enjoy their own space.')],
    [Document(metadata={'source': 'fish-pets-doc'}, page_content='Goldfish are popular pets for beginners, requiring relatively simple care.')]
]
{% endhighlight %}

## Vector store를 사용해서 간단한 RAG 구현하기

RAG에 대한 설명은 [여기](https://brunch.co.kr/@ywkim36/146) 참고.

{% highlight python %}
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

message = """
Answer this question using the provided context only.

{question}

Context:
{context}
"""

prompt = ChatPromptTemplate.from_messages([("human", message)])
rag_chain = {"context": retriever, "question": RunnablePassthrough()} | prompt | model

response = rag_chain.invoke("tell me about cats")
print(response.content)
{% endhighlight %}

{% highlight txt %}
Cats are independent pets that often enjoy their own space.
{% endhighlight %}

이번에 만든 `retriever`를 `context` 변수에 넣었는데, 프롬프트를 보면 `Context:` 문자열 다음으로 들어가는 것을 알 수 있다.

LangSmith를 통해 최종 프롬프트를 확인해 보면 다음과 같다.

{% highlight txt %}
Answer this question using the provided context only.

tell me about cats

Context:
[Document(metadata={'source': 'mammal-pets-doc'}, page_content='Cats are independent pets that often enjoy their own space.')]
{% endhighlight %}

Context에 cat과 관련된 문서가 들어간 것을 확인할 수 있다.
