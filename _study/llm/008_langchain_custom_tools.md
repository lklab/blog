---
title: LangChain - Custom tools
image: /assets/study/llm/default/langchain_logo.jpg
author: khlee
layout: post
last_modified_at: 2024-10-17
---

[LangChain 튜토리얼](https://python.langchain.com/docs/how_to/custom_tools/)을 읽고 정리한 내용이다.

## 개요

이번에는 agent에서 활용할 수 있는 custom tool을 만드는 방법에 대해 알아보았다.

Tool은 다음과 같은 요소로 구성된다.

* `name`(str): LLM 또는 agent에 제공되는 tool 중에서 유일한 이름이다.
* `description`(str): 해당 tool에 대해 설명한 것으로, LLM 또는 agent에게 context로 사용된다.
* `args_schema`(pydantic.BaseModel): 몇 가지 예시 같은 추가적인 정보를 제공하기 위해 사용되며, 필수는 아니지만 추천된다. 만약 callback handler를 사용하는 경우 필수다.
* `return_direct`(boolean): Agent에서만 사용되며, True인 경우 tool을 실행하고 나서 결과를 사용자에게 바로 반환한다.

LangChain에서는 tool을 만드는 몇 가지 방법을 제공한다.

* Functions
* LangChain [Runnables](https://python.langchain.com/docs/concepts/#runnable-interface)
* [BaseTool](https://python.langchain.com/api_reference/core/tools/langchain_core.tools.BaseTool.html)의 sub-classing: 이 방법은 가장 유연한 기능을 제공하지만 코드를 더 많이 작성해야 한다.

## Creating tools from functions

#### @tool decorator

`@tool` decorator를 사용하는 것은 custom tool을 만드는 가장 쉬운 방법이다.

{% highlight python %}
from langchain_core.tools import tool

@tool
def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b

@tool
async def amultiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b

# Let's inspect some of the attributes associated with the tool.
print(multiply.name)
print(multiply.description)
print(multiply.args)

print(amultiply.name)
print(amultiply.description)
print(amultiply.args)
{% endhighlight %}

{% highlight txt %}
multiply
Multiply two numbers.
{'a': {'title': 'A', 'type': 'integer'}, 'b': {'title': 'B', 'type': 'integer'}}
amultiply
Multiply two numbers.
{'a': {'title': 'A', 'type': 'integer'}, 'b': {'title': 'B', 'type': 'integer'}}
{% endhighlight %}

동기, 비동기 툴을 만들 수 있고, `name`, `description` 같은 속성들이 지정되는 것을 확인할 수 있다.

`@tool` decorator은 annotations, nested schemas 등을 지원한다.

{% highlight python %}
from typing import Annotated, List

@tool
def multiply_by_max(
    a: Annotated[str, "scale factor"],
    b: Annotated[List[int], "list of ints over which to take maximum"],
) -> int:
    """Multiply a by the maximum of b."""
    return a * max(b)

print(multiply_by_max.args_schema.schema())
{% endhighlight %}

{% highlight txt %}
{
  'description': 'Multiply a by the maximum of b.',
  'properties': {
    'a': {
      'description': 'scale factor',
      'title': 'A',
      'type': 'string'
    },
    'b': {
      'description': 'list of ints over which to take maximum',
      'items': {
        'type': 'integer'
      },
      'title': 'B',
      'type': 'array'
    }
  },
  'required': [
    'a',
    'b'
  ],
  'title': 'multiply_by_max',
  'type': 'object'
}
{% endhighlight %}

그리고 `@tool` decorator의 argument를 이용해서 tool name과 args를 커스텀할 수 있다.

{% highlight python %}
from pydantic import BaseModel, Field

class CalculatorInput(BaseModel):
    a: int = Field(description="first number")
    b: int = Field(description="second number")

@tool("multiplication-tool", args_schema=CalculatorInput, return_direct=True)
def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b

# Let's inspect some of the attributes associated with the tool.
print(multiply.name)
print(multiply.description)
print(multiply.args)
print(multiply.return_direct)
{% endhighlight %}

{% highlight txt %}
multiplication-tool
Multiply two numbers.
{'a': {'description': 'first number', 'title': 'A', 'type': 'integer'}, 'b': {'description': 'second number', 'title': 'B', 'type': 'integer'}}
True
{% endhighlight %}

[Google Style docstrings](https://google.github.io/styleguide/pyguide.html#383-functions-and-methods) 파싱도 지원한다.

{% highlight python %}
@tool(parse_docstring=True)
def foo(bar: str, baz: int) -> str:
    """The foo.

    Args:
        bar: The bar.
        baz: The baz.
    """
    return bar

print(foo.args_schema.schema())
{% endhighlight %}

{% highlight txt %}
{
  'description': 'The foo.',
  'properties': {
    'bar': {
      'description': 'The bar.',
      'title': 'Bar',
      'type': 'string'
    },
    'baz': {
      'description': 'The baz.',
      'title': 'Baz',
      'type': 'integer'
    }
  },
  'required': [
    'bar',
    'baz'
  ],
  'title': 'foo',
  'type': 'object'
}
{% endhighlight %}

#### StructuredTool

`StructuredTool.from_function()` 함수는 `@tool` decorator보다 더 많은 기능을 제공한다.

{% highlight python %}
from langchain_core.tools import StructuredTool

class CalculatorInput(BaseModel):
    a: int = Field(description="first number")
    b: int = Field(description="second number")

def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b

async def amultiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b

calculator = StructuredTool.from_function(
    func=multiply,
    coroutine=amultiply,
    name="Calculator",
    description="multiply numbers",
    args_schema=CalculatorInput,
    return_direct=True,
)

print(calculator.invoke({"a": 2, "b": 3}))
# print(await calculator.ainvoke({"a": 2, "b": 5}))
print(calculator.name)
print(calculator.description)
print(calculator.args)
{% endhighlight %}

{% highlight txt %}
6
Calculator
multiply numbers
{'a': {'description': 'first number', 'title': 'A', 'type': 'integer'}, 'b': {'description': 'second number', 'title': 'B', 'type': 'integer'}}
{% endhighlight %}

## Creating tools from Runnables

`str`이나 `dict`를 입력으로 받는 [Runnables](https://python.langchain.com/docs/concepts/#runnable-interface)는 `as_tool()` 함수를 사용해서 tool로 변경할 수 있다.

{% highlight python %}
from langchain_core.language_models import GenericFakeChatModel
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [("human", "Hello. Please respond in the style of {answer_style}.")]
)

# Placeholder LLM
llm = GenericFakeChatModel(messages=iter(["hello matey"]))

chain = prompt | llm | StrOutputParser()

as_tool = chain.as_tool(
    name="Style responder", description="Description of when to use tool."
)
print(as_tool.args)
{% endhighlight %}

{% highlight txt %}
c:\Users\user\Projects\Python\langchain-study\07_custom_tools.py:117: LangChainBetaWarning: This API is in beta and may change in the future.
  as_tool = chain.as_tool(
{'answer_style': {'title': 'Answer Style', 'type': 'string'}}
{% endhighlight %}

## Subclass BaseTool

`BaseTool`을 상속받아서 custom tool을 만들 수 있다.

{% highlight python %}
from typing import Optional, Type

from langchain_core.callbacks import (
    AsyncCallbackManagerForToolRun,
    CallbackManagerForToolRun,
)
from langchain_core.tools import BaseTool
from pydantic import BaseModel

class CalculatorInput(BaseModel):
    a: int = Field(description="first number")
    b: int = Field(description="second number")

# Note: It's important that every field has type hints. BaseTool is a
# Pydantic class and not having type hints can lead to unexpected behavior.
class CustomCalculatorTool(BaseTool):
    name: str = "Calculator"
    description: str = "useful for when you need to answer questions about math"
    args_schema: Type[BaseModel] = CalculatorInput
    return_direct: bool = True

    def _run(
        self, a: int, b: int, run_manager: Optional[CallbackManagerForToolRun] = None
    ) -> str:
        """Use the tool."""
        return a * b

    async def _arun(
        self,
        a: int,
        b: int,
        run_manager: Optional[AsyncCallbackManagerForToolRun] = None,
    ) -> str:
        """Use the tool asynchronously."""
        # If the calculation is cheap, you can just delegate to the sync implementation
        # as shown below.
        # If the sync calculation is expensive, you should delete the entire _arun method.
        # LangChain will automatically provide a better implementation that will
        # kick off the task in a thread to make sure it doesn't block other async code.
        return self._run(a, b, run_manager=run_manager.get_sync())

multiply = CustomCalculatorTool()
print(multiply.name)
print(multiply.description)
print(multiply.args)
print(multiply.return_direct)

print(multiply.invoke({"a": 2, "b": 3}))
# print(await multiply.ainvoke({"a": 2, "b": 3}))
{% endhighlight %}

{% highlight txt %}
Calculator
useful for when you need to answer questions about math
{'a': {'description': 'first number', 'title': 'A', 'type': 'integer'}, 'b': {'description': 'second number', 'title': 'B', 'type': 'integer'}}
True
6
{% endhighlight %}

## How to create async tools

LangChain의 tool은 [Runnable interface 🏃](https://python.langchain.com/api_reference/core/runnables/langchain_core.runnables.base.Runnable.html)를 구현한다. 모든 Runnable은 `invoke()`와 `ainvoke()` 함수를 가지고 있다. 따라서 만약 동기적(sync)인 tool만 구현했어도 `ainvoke` 함수를 통해 비동기적인 실행이 가능하다. 다만 다음과 같은 내용을 알고 있어야 한다.

* LangChain은 기본적으로 해당 함수를 다른 스레드에서 실행하는 비동기 구현을 제공한다.
* 비동기 코드베이스에서 작업하는 경우 해당 스레드로 인해 오버헤드가 발생하지 않도록 비동기 tool을 제공해야 한다.
* 동기 및 비동기 구현이 모두 필요한 경우 `StructuredTool.from_function()` 함수를 사용하거나 `BaseTool`을 상속받으면 된다.
* 동기 코드가 빠르게 실행되는 경우 LangChain의 기본 비동기 구현을 override하고 동기 코드를 호줄한다.
* 비동기 tool에 대해 동기 `invoke()`를 호출하면 안 된다.

## Handling Tool Errors

Tool 실행 중 오류가 발생한 경우 `ToolException`을 발생시키고 `handle_tool_error`를 사용해서 오류를 처리할 수 있다.

{% highlight python %}
from langchain_core.tools import ToolException

def get_weather(city: str) -> int:
    """Get weather for the given city."""
    raise ToolException(f"Error: There is no city by the name of {city}.")

get_weather_tool = StructuredTool.from_function(
    func=get_weather,
    handle_tool_error=True,
)

print(get_weather_tool.invoke({"city": "foobar"}))
{% endhighlight %}

{% highlight txt %}
Error: There is no city by the name of foobar.
{% endhighlight %}

`handle_tool_error`에 문자열을 지정하면 `ToolException`의 메시지 대신 해당 메시지가 반환된다.

{% highlight python %}
get_weather_tool = StructuredTool.from_function(
    func=get_weather,
    handle_tool_error="There is no such city, but it's probably above 0K there!",
)

print(get_weather_tool.invoke({"city": "foobar"}))
{% endhighlight %}

{% highlight txt %}
There is no such city, but it's probably above 0K there!
{% endhighlight %}

`handle_tool_error`에 함수를 지정할 수도 있다. 해당 함수는 `ToolException`을 매개변수로 받는다.

{% highlight python %}
def _handle_error(error: ToolException) -> str:
    return f"The following errors occurred during tool execution: `{error.args[0]}`"

get_weather_tool = StructuredTool.from_function(
    func=get_weather,
    handle_tool_error=_handle_error,
)

print(get_weather_tool.invoke({"city": "foobar"}))
{% endhighlight %}

{% highlight txt %}
The following errors occurred during tool execution: `Error: There is no city by the name of foobar.`
{% endhighlight %}

## Returning artifacts of Tool execution

Tool의 결과 중 모델에는 전달하고 싶지 않은 artifact가 있을 수 있다. Tool과 [ToolMessage](https://python.langchain.com/api_reference/core/messages/langchain_core.messages.tool.ToolMessage.html) interfaces는 이와 관련된 기능을 제공한다.

`@tool` decorator를 사용하는 경우 `response_format="content_and_artifact"` 매개변수를 지정하고 `(content, artifact)` 튜플을 반환하도록 하면 된다.

{% highlight python %}
import random
from typing import List, Tuple

from langchain_core.tools import tool

@tool(response_format="content_and_artifact")
def generate_random_ints(min: int, max: int, size: int) -> Tuple[str, List[int]]:
    """Generate size random ints in the range [min, max]."""
    array = [random.randint(min, max) for _ in range(size)]
    content = f"Successfully generated array of {size} random ints in [{min}, {max}]."
    return content, array

print(generate_random_ints.invoke({"min": 0, "max": 9, "size": 10}))

print(generate_random_ints.invoke(
    {
        "name": "generate_random_ints",
        "args": {"min": 0, "max": 9, "size": 10},
        "id": "123",  # required
        "type": "tool_call",  # required
    }
))
{% endhighlight %}

{% highlight txt %}
Successfully generated array of 10 random ints in [0, 9].
content='Successfully generated array of 10 random ints in [0, 9].' name='generate_random_ints' tool_call_id='123' artifact=[8, 4, 0, 0, 3, 2, 4, 5, 9, 0]
{% endhighlight %}

`BaseTool`을 상속받아서 구현하는 경우 다음과 같이 하면 된다.

{% highlight python %}
from langchain_core.tools import BaseTool

class GenerateRandomFloats(BaseTool):
    name: str = "generate_random_floats"
    description: str = "Generate size random floats in the range [min, max]."
    response_format: str = "content_and_artifact"

    ndigits: int = 2

    def _run(self, min: float, max: float, size: int) -> Tuple[str, List[float]]:
        range_ = max - min
        array = [
            round(min + (range_ * random.random()), ndigits=self.ndigits)
            for _ in range(size)
        ]
        content = f"Generated {size} floats in [{min}, {max}], rounded to {self.ndigits} decimals."
        return content, array

rand_gen = GenerateRandomFloats(ndigits=4)

print(rand_gen.invoke(
    {
        "name": "generate_random_floats",
        "args": {"min": 0.1, "max": 3.3333, "size": 3},
        "id": "123",
        "type": "tool_call",
    }
))
{% endhighlight %}

{% highlight txt %}
content='Generated 3 floats in [0.1, 3.3333], rounded to 4 decimals.' name='generate_random_floats' tool_call_id='123' artifact=[2.362, 2.2987, 0.9664]
{% endhighlight %}
