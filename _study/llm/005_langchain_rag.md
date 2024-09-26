---
title: LangChain - Retrieval Augmented Generation (RAG)
image: /assets/study/llm/default/langchain_logo.jpg
author: khlee
layout: post
last_modified_at: 2024-08-20
---

[LangChain 튜토리얼](https://python.langchain.com/v0.2/docs/tutorials/rag/)을 읽고 정리한 내용이다.

RAG에 대한 설명은 [여기](https://brunch.co.kr/@ywkim36/146) 참고.

## 개념

RAG에는 Indexing과 Retrieval and generation 라는 두 가지 중요한 개념이 있다.

#### Indexing

Indexing은 데이터를 모으고 색인하는 작업이다. 주로 오프라인에서 동작한다.

1. Load: 먼저 데이터를 로드한다. 이 작업은 [Document Loaders](https://python.langchain.com/v0.2/docs/concepts/#document-loaders)를 통해 이루어진다.
2. Split: [Text splitters](https://python.langchain.com/v0.2/docs/concepts/#text-splitters)는 `Document`를 작은 청크로 나눈다. 이 작업은 색인(indexing)하거나 모델에 전달할 때 유용하다. 그 이유는 큰 데이터는 검색하기 어렵고, 모델의 유한한 context에 들어가지 않을 수 있기 때문이다.
3. Store: 다음에 검색할 수 있도록 앞에서 처리된 데이터를 저장한다. 이 작업은 [VectorStore](https://python.langchain.com/v0.2/docs/concepts/#vector-stores)나 [Embeddings](https://python.langchain.com/v0.2/docs/concepts/#embedding-models) 모델을 통해 이루어진다.

#### Retrieval and generation

Retrieval and generation은 런타임에 사용자의 질문을 가져와서 index에서 관련 내용을 검색한 다음 모델에 전달하는 RAG chain이다.

4. Retrieve: 사용자의 질문이 들어오면 [Retriever](https://python.langchain.com/v0.2/docs/concepts/#retrievers)를 사용해서 관련된 데이터 청크(앞의 split 단계에서 나눈)가 storage에서 검색된다.
5. Generate: [ChatModel](https://python.langchain.com/v0.2/docs/concepts/#chat-models)/[LLM](https://python.langchain.com/v0.2/docs/concepts/#llms)이 사용자의 질문과 검색된 데이터를 합쳐서 만든 prompt를 사용하여 답변을 생성한다.

## Preview

크롤링을 할 것이기 때문에 [Beautiful Soup](https://pypi.org/project/beautifulsoup4/) 설치가 필요하다.

{% highlight bat %}
> python -m pip install beautifulsoup4
{% endhighlight %}

또한 `langchainhub`도 설치한다.

{% highlight bat %}
> python -m pip install langchainhub
{% endhighlight %}

다음 예시는 Lilian Weng이 작성한 블로그 [LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/) 내용에 관한 질문에 답변하는 앱이다.

{% highlight python %}
import json
import os

# load API key
with open('apikeys.json') as f:
    keys = json.load(f)

os.environ["OPENAI_API_KEY"] = keys['OPENAI_API_KEY']
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = keys['LANGCHAIN_API_KEY']

# setup model
from langchain_openai import ChatOpenAI
model = ChatOpenAI(
    model="gpt-3.5-turbo",
)

import bs4
from langchain import hub
from langchain_chroma import Chroma
from langchain_community.document_loaders import WebBaseLoader
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Load, chunk and index the contents of the blog.
loader = WebBaseLoader(
    web_paths=("https://lilianweng.github.io/posts/2023-06-23-agent/",),
    bs_kwargs=dict(
        parse_only=bs4.SoupStrainer(
            class_=("post-content", "post-title", "post-header")
        )
    ),
)
docs = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = text_splitter.split_documents(docs)
vectorstore = Chroma.from_documents(documents=splits, embedding=OpenAIEmbeddings())

# Retrieve and generate using the relevant snippets of the blog.
retriever = vectorstore.as_retriever()
prompt = hub.pull("rlm/rag-prompt")


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | model
    | StrOutputParser()
)

response = rag_chain.invoke("What is Task Decomposition?")
print(response)

# cleanup
vectorstore.delete_collection()
{% endhighlight %}

몇 가지 경고가 나오긴 하지만 다음과 같은 응답을 얻을 수 있다.

{% highlight txt %}
Task Decomposition is a technique used to break down complex tasks into smaller and simpler steps. This method helps agents plan ahead and tackle tasks more efficiently. It can be implemented through prompts, task-specific instructions, or with human inputs.
{% endhighlight %}

이제 응답을 받끼까지 어떤 과정이 이루어졌는지 확인해 보자.

## 1. Indexing: Load

먼저 블로그의 내용을 가져와야 한다. 이를 위해 소스로부터 [Documents](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 리스트를 반환하는 [DocumentLoaders](https://python.langchain.com/v0.2/docs/concepts/#document-loaders)를 활용할 수 있다. 각각의 `Document` 객체는 `page_content`와 `metadata`를 포함하고 있다.

[WebBaseLoader](https://python.langchain.com/v0.2/docs/integrations/document_loaders/web_base/)를 사용하여 URL로부터 HTML 문서를 가져온 후 `BeautifulSoup`를 사용하여 텍스트로 파싱한다. 파싱할 때 `bs_kwargs` 파라미터를 사용하여 파싱 과정을 커스터마이징할 수 있다. ([참고](https://beautiful-soup-4.readthedocs.io/en/latest/#beautifulsoup)) 여기서는 `post-content`, `post-title`, `post-header` 클래스를 가진 HTML 태그 내의 데이터만 가져오고 그 외에는 모두 버리도록 하였다.

{% highlight txt %}
import bs4
from langchain_community.document_loaders import WebBaseLoader

# Only keep post title, headers, and content from the full HTML.
bs4_strainer = bs4.SoupStrainer(class_=("post-title", "post-header", "post-content"))
loader = WebBaseLoader(
    web_paths=("https://lilianweng.github.io/posts/2023-06-23-agent/",),
    bs_kwargs={"parse_only": bs4_strainer},
)
docs = loader.load()

print(len(docs[0].page_content))
print(docs[0].page_content[:500])
{% endhighlight %}

{% highlight txt %}
43131


      LLM Powered Autonomous Agents

Date: June 23, 2023  |  Estimated Reading Time: 31 min  |  Author: Lilian Weng


Building agents with LLM (large language model) as its core controller is a cool concept. Several proof-of-concepts demos, such as AutoGPT, GPT-Engineer and BabyAGI, serve as inspiring examples. The potentiality of LLM extends beyond generating well-written copies, stories, essays and programs; it can be framed as a powerful general problem solver.
Agent System Overview#
In
{% endhighlight %}

`DocumentLoader`는 소스 데이터를 `Documents` 객체로 로드하는 객체다. 다음은 이에 관련된 추가 정보다.

* [Docs](https://python.langchain.com/v0.2/docs/how_to/#document-loaders): Detailed documentation on how to use `DocumentLoaders`.
* [Integrations](https://python.langchain.com/v0.2/docs/integrations/document_loaders/): 160+ integrations to choose from.
* [Interface](https://api.python.langchain.com/en/latest/document_loaders/langchain_core.document_loaders.base.BaseLoader.html): API reference  for the base interface.

## 2. Indexing: Split

앞서 언급했듯이, 큰 문서는 검색하기도 어렵고 모델의 context에 전부 들어갈 수도 없기 때문에 작은 청크로 분할해야 한다. 이 예에서는 각 청크의 크기가 1,000자가 되도록 하고 인접한 청크 사이가 200자씩 겹치도록 한다. 이 겹치는 부분은 청크 경계에 있는 텍스트를 사용하는 답변의 내용이 분리되는 것을 완화해주는 역할을 한다.

텍스트 분할은 [RecursiveCharacterTextSplitter](https://python.langchain.com/v0.2/docs/how_to/recursive_text_splitter/)를 사용할 것이다. 이것은 청크가 적절한 크기가 될 때까지 new line과 같은 구분 문자를 기준으로 분할하며, 일반적으로 권장되는 text splitter다.

`add_start_index=True`를 사용하여 메타데이터에 `start_index` 필드가 포함되도록 한다.

{% highlight python %}
from langchain_text_splitters import RecursiveCharacterTextSplitter

text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000, chunk_overlap=200, add_start_index=True
)
all_splits = text_splitter.split_documents(docs)

print(len(all_splits))
print(len(all_splits[0].page_content))
print(all_splits[10].metadata)
{% endhighlight %}

{% highlight txt %}
66
969
{'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'start_index': 7056}
{% endhighlight %}

`TextSplitter`는 `DocumentTransformer`의 서브클래스로 `Document` 리스트를 더 작은 청크로 분할하는 객체다. 다음은 `TextSplitter`에 관한 추가 정보다.

* Learn more about splitting text using different methods by reading the [how-to docs](https://python.langchain.com/v0.2/docs/how_to/#text-splitters)
* [Code (py or js)](https://python.langchain.com/v0.2/docs/integrations/document_loaders/source_code/)
* [Scientific papers](https://python.langchain.com/v0.2/docs/integrations/document_loaders/grobid/)
* [Interface](https://api.python.langchain.com/en/latest/base/langchain_text_splitters.base.TextSplitter.html): API reference for the base interface.

`DocumentTransformer`는 `Document` 리스트에 대한 변형(transformation)을 수행하는 객체다. 다음은 `DocumentTransformer`에 관한 추가 정보다.

* [Docs](https://python.langchain.com/v0.2/docs/how_to/#text-splitters): Detailed documentation on how to use `DocumentTransformers`
* [Integrations](https://python.langchain.com/v0.2/docs/integrations/document_transformers/)
* [Interface](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.transformers.BaseDocumentTransformer.html): API reference for the base interface.

## 3. Indexing: Store

이제 [지난 글]({{ site.baseurl }}/study/llm/004_langchain_vector_stores_and_retrievers/#vector-stores)에서 했던 것 처럼 [Chroma](https://python.langchain.com/v0.2/docs/integrations/vectorstores/chroma/) vector store와 [OpenAIEmbeddings](https://python.langchain.com/v0.2/docs/integrations/text_embedding/openai/) 모델을 사용해서 분할된 청크를 vector store에 embedding 한다.

{% highlight python %}
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings

vectorstore = Chroma.from_documents(documents=all_splits, embedding=OpenAIEmbeddings())
{% endhighlight %}

`Embeddings`는 텍스트 임베딩(text embedding) 모델의 Wrapper다. 다음은 `Embeddings`에 관한 추가 정보다.

* [Docs](https://python.langchain.com/v0.2/docs/how_to/embed_text/): Detailed documentation on how to use embeddings.
* [Integrations](https://python.langchain.com/v0.2/docs/integrations/text_embedding/): 30+ integrations to choose from.
* [Interface](https://api.python.langchain.com/en/latest/embeddings/langchain_core.embeddings.Embeddings.html): API reference for the base interface.

`VectorStore`는 임베딩된 데이터들에 대해 검색하거나 쿼리할 수 있는 vector database의 Wrapper다. 다음은 `VectorStore`에 관한 추가 정보다.

* [Docs](https://python.langchain.com/v0.2/docs/how_to/vectorstores/): Detailed documentation on how to use vector stores.
* [Integrations](https://python.langchain.com/v0.2/docs/integrations/vectorstores/): 40+ integrations to choose from.
* [Interface](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html): API reference for the base interface.

## 4. Retrieval and Generation: Retrieve

이제부터는 application에서 동작하는 로직이다. 먼저 사용자 질문으로부터 관련된 내용을 검색해서 가져와야 한다. 이 작업을 수행하도록 LangChain에서 제공하는 것이 [Retriever](https://python.langchain.com/v0.2/docs/concepts/#retrievers/)다. 가장 일반적인 Retriever는 [VectorStoreRetriever](https://python.langchain.com/v0.2/docs/how_to/vectorstore_retriever/)인데, 이것은 vector store의 유사성 검색(similarity search)을 사용해서 관련된 내용을 검색하는 기능을 제공한다. `VectorStoreRetriever`는 `VectorStore`로부터 `VectorStore.as_retriever()`를 사용해서 얻어올 수 있다.

{% highlight python %}
retriever = vectorstore.as_retriever(search_type="similarity", search_kwargs={"k": 6})
retrieved_docs = retriever.invoke("What are the approaches to Task Decomposition?")

print(len(retrieved_docs))
print(retrieved_docs[0].page_content)
{% endhighlight %}

{% highlight txt %}
6
Tree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.
Task decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.
{% endhighlight %}

`Retriever`는 텍스트 쿼리가 주어지면 `Document`를 반환하는 객체다. 다음은 `Retriever`에 관한 추가 정보다.

* [Docs](https://python.langchain.com/v0.2/docs/how_to/#retrievers): Further documentation on the interface and built-in retrieval techniques. Some of which include:
  * `MultiQueryRetriever` [generates variants of the input question](https://python.langchain.com/v0.2/docs/how_to/MultiQueryRetriever/) to improve retrieval hit rate.
  * `MultiVectorRetriever` instead generates [variants of the embeddings](https://python.langchain.com/v0.2/docs/how_to/multi_vector/), also in order to improve retrieval hit rate.
  * `Max marginal relevance` selects for [relevance and diversity](https://www.cs.cmu.edu/~jgc/publication/The_Use_MMR_Diversity_Based_LTMIR_1998.pdf) among the retrieved documents to avoid passing in duplicate context.
  * Documents can be filtered during vector store retrieval using metadata filters, such as with a [Self Query Retriever](https://python.langchain.com/v0.2/docs/how_to/self_query/).
* [Integrations](https://python.langchain.com/v0.2/docs/integrations/retrievers/): Integrations with retrieval services.
* [Interface](https://api.python.langchain.com/en/latest/retrievers/langchain_core.retrievers.BaseRetriever.html): API reference for the base interface.

## 5. Retrieval and Generation: Generate

다음으로 사용자의 질문으로부터 검색, 프롬프트 구성, 모델 전달, 결과 파싱의 작업을 체인으로 연결할 것이다.

먼저 프롬프트를 구성할 것인데, 이번에는 [hub](https://smith.langchain.com/hub/rlm/rag-prompt)에서 프롬프트 템플릿을 가져 올 것이다.

{% highlight python %}
from langchain import hub

prompt = hub.pull("rlm/rag-prompt")

example_messages = prompt.invoke(
    {"context": "filler context", "question": "filler question"}
).to_messages()

print(example_messages)
print()
print(example_messages[0].content)
{% endhighlight %}

{% highlight txt %}
[HumanMessage(content="You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.\nQuestion: filler question \nContext: filler context \nAnswer:")]

You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.
Question: filler question 
Context: filler context 
Answer:
{% endhighlight %}

이 프롬프트 템플릿을 포함해서 LCEL 체인을 구성한다.

{% highlight python %}
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | model
    | StrOutputParser()
)

for chunk in rag_chain.stream("What is Task Decomposition?"):
    print(chunk, end="", flush=True)
{% endhighlight %}

{% highlight txt %}
Task decomposition is a technique that breaks down complex tasks into smaller and simpler steps to enhance model performance. It involves transforming big tasks into manageable tasks by thinking step by step or exploring multiple reasoning possibilities. This process can be done through simple prompting, task-specific instructions, or human inputs.
{% endhighlight %}

체인을 구성하는 각각의 요소(위의 `prompt`, `model` 등)는 모두 [Runnable](https://python.langchain.com/v0.2/docs/concepts/#langchain-expression-language-lcel)이다. 또한 LangChain은 `|` 연산자를 만난 일부 오브젝트들도 runnable로 자동으로 변환한다. 이에 의해서 위의 코드에서 `format_docs`는 [RunnableLambda](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html)로, `context`와 `question`이 있는 dictionary는 [RunnableParallel](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html)로 변환된다.

우리가 가져온 프롬프트에 따르면, 프롬프트는 `context`와 `question` 값을 필요로 한다. 따라서 체인의 첫 번째 줄에서 이 값들을 구성한다. `context` 파라미터에는 `retriever`를 통해 가져 온 문서들을 `format_docs` 함수를 통해 하나의 문자열로 합친 값을 대입한다. `question` 파라미터에는 `RunnablePassthrough()`를 사용해서 외부 입력 값을 그대로 대입한다.

한편으로 LangChain은 위의 체인을 구현하는 편리한 함수들을 제공한다.

* [create_stuff_documents_chain()](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html) 함수는 받은 `context`를 프롬프트와 LLM에 전달하는 방법을 결정한다. 이 체인은 입력(`input`)과 `context`를 사용하여 답변을 생성한다.
* [create_retrieval_chain()](https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html) 함수는 체인에 retrieval step을 추가한다. 입력으로 `input` 키가 있고, 출력으로 `input`, `context`, `answer` 키가 있다.

{% highlight python %}
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate

system_prompt = (
    "You are an assistant for question-answering tasks. "
    "Use the following pieces of retrieved context to answer "
    "the question. If you don't know the answer, say that you "
    "don't know. Use three sentences maximum and keep the "
    "answer concise."
    "\n\n"
    "{context}"
)

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        ("human", "{input}"),
    ]
)

question_answer_chain = create_stuff_documents_chain(model, prompt)
rag_chain = create_retrieval_chain(retriever, question_answer_chain)

response = rag_chain.invoke({"input": "What is Task Decomposition?"})
print(response["answer"])
{% endhighlight %}

{% highlight txt %}
Task decomposition involves breaking down a complex task into smaller and simpler steps. This process helps agents or models handle difficult tasks by transforming them into more manageable subtasks. Task decomposition can be achieved through techniques like Chain of Thought (CoT) or Tree of Thoughts to guide the model in thinking step by step and exploring multiple reasoning possibilities.
{% endhighlight %}

여기서 만약 답변을 생성할 때 활용한 정보를 가져오려면 다음과 같이 `context` 키를 확인하면 된다.

{% highlight python %}
for document in response["context"]:
    print(document)
    print()
{% endhighlight %}

{% highlight txt %}
page_content='Fig. 1. Overview of a LLM-powered autonomous agent system.
Component One: Planning#
A complicated task usually involves many steps. An agent needs to know what they are and plan ahead.
Task Decomposition#
Chain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.' metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'start_index': 1585}

page_content='Tree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.       
Task decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.' metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'start_index': 2192}

page_content='Resources:
1. Internet access for searches and information gathering.
2. Long Term memory management.
3. GPT-3.5 powered Agents for delegation of simple tasks.
4. File output.

Performance Evaluation:
1. Continuously review and analyze your actions to ensure you are performing to the best of your abilities.
2. Constructively self-criticize your big-picture behavior constantly.
3. Reflect on past decisions and strategies to refine your approach.
4. Every command has a cost, so be smart and efficient. Aim to complete tasks in the least number of steps.' metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'start_index': 29630}

생략
{% endhighlight %}

`ChatModel`은 LLM 기반의 채팅 모델로, 일련의 메시지를 받아 메시지를 반환한다. 다음은 `ChatModel`에 관한 추가 정보다.

* [Docs](https://python.langchain.com/v0.2/docs/how_to/#chat-models)
* [Integrations](https://python.langchain.com/v0.2/docs/integrations/chat/): 25+ integrations to choose from.
* [Interface](https://api.python.langchain.com/en/latest/language_models/langchain_core.language_models.chat_models.BaseChatModel.html): API reference for the base interface.

`LLM`은 문자열을 받아 문자열을 반환하는 모델이다. 다음은 `LLM`에 관한 추가 정보다.

* [Docs](https://python.langchain.com/v0.2/docs/how_to/#llms)
* [Integrations](https://python.langchain.com/v0.2/docs/integrations/llms/): 75+ integrations to choose from.
* [Interface](https://api.python.langchain.com/en/latest/language_models/langchain_core.language_models.llms.BaseLLM.html): API reference for the base interface.

로컬에서 동작하는 RAG를 만들려면 [여기](https://python.langchain.com/v0.2/docs/tutorials/local_rag/) 참고.
