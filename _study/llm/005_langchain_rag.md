---
title: LangChain - Retrieval Augmented Generation (RAG)
image: /assets/study/llm/default/langchain_logo.jpg
author: khlee
layout: post
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
