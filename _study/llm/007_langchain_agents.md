---
title: LangChain - Agents
image: /assets/study/llm/default/langchain_logo.jpg
author: khlee
layout: post
last_modified_at: 2024-08-30
---

[LangChain 튜토리얼](https://python.langchain.com/v0.2/docs/tutorials/agents/)을 읽고 정리한 내용이다.

## 개요

LangChain의 Agent는 LLM을 추론 엔진으로 사용해서 어떤 작업을 하고 어떤 입력을 전달할지 결정하는 시스템이다. 이 튜토리얼에서는 검색엔진을 활용하는 Agent에 대해 알아 볼 것이다.

## Tavily

Tavily라는 검색 엔진을 사용할 것이다. [https://tavily.com/](https://tavily.com/)에 접속해서 계정을 생성하고 API 키를 만들어서 다음과 같이 환경변수에 설정하면 된다.

{% highlight python %}
import os

os.environ["TAVILY_API_KEY"] = 'Your Tavily API Key`
{% endhighlight %}

## Define tools

먼저 Tavily 검색 엔진을 tool로 만든다.

{% highlight python %}
from langchain_community.tools.tavily_search import TavilySearchResults

search = TavilySearchResults(max_results=2)
search_results = search.invoke("what is the weather in SF")
print(search_results)
{% endhighlight %}

{% highlight txt %}
[{'url': 'https://www.weatherapi.com/', 'content': "{'location': {'name': 'San Francisco', 'region': 'California', 'country': 'United States of America', 'lat': 37.78, 'lon': -122.42, 'tz_id': 'America/Los_Angeles', 'localtime_epoch': 1724992202, 'localtime': '2024-08-29 21:30'}, 'current': {'last_updated_epoch': 1724991300, 'last_updated': '2024-08-29 21:15', 'temp_c': 17.2, 'temp_f': 63.0, 'is_day': 0, 'condition': {'text': 'Partly cloudy', 'icon': '//cdn.weatherapi.com/weather/64x64/night/116.png', 'code': 1003}, 'wind_mph': 15.0, 'wind_kph': 24.1, 'wind_degree': 300, 'wind_dir': 'WNW', 'pressure_mb': 1017.0, 'pressure_in': 30.02, 'precip_mm': 0.0, 'precip_in': 0.0, 'humidity': 84, 'cloud': 25, 'feelslike_c': 17.2, 'feelslike_f': 63.0, 'windchill_c': 15.5, 'windchill_f': 59.8, 'heatindex_c': 15.5, 'heatindex_f': 59.8, 'dewpoint_c': 12.8, 'dewpoint_f': 55.0, 'vis_km': 16.0, 'vis_miles': 9.0, 'uv': 1.0, 'gust_mph': 19.5, 'gust_kph': 31.3}}"}, {'url': 'https://world-weather.info/forecast/usa/san_francisco/august-2024/', 'content': 'Hourly Week 10 days 14 days 30 days Year. Detailed ⚡ San Francisco Weather Forecast for August 2024 - day/night 🌡️ temperatures, precipitations - World-Weather.info.'}]
{% endhighlight %}

## Using Language Models

이 tool은 LLM과 함께 사용할 수 있다. 다음 예시를 보자.

{% highlight python %}
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage

model = ChatOpenAI(
    model="gpt-3.5-turbo",
)

model_with_tools = model.bind_tools(tools)

response = model_with_tools.invoke([HumanMessage(content="Hi!")])

print(f"ContentString: {response.content}")
print(f"ToolCalls: {response.tool_calls}")
print('-----')

response = model_with_tools.invoke([HumanMessage(content="What's the weather in SF?")])

print(f"ContentString: {response.content}")
print(f"ToolCalls: {response.tool_calls}")
{% endhighlight %}

{% highlight txt %}
ContentString: Hello! How can I assist you today?
ToolCalls: []
-----
ContentString: 
ToolCalls: [{'name': 'tavily_search_results_json', 'args': {'query': 'weather in San Francisco'}, 'id': 'call_JfA6yWYFQBsjXdAFENJ4zQvM', 'type': 'tool_call'}]
{% endhighlight %}

LLM에 검색이 필요하지 않은 인사말을 전달하면 `response.content`에 값이 들어있고, 검색이 필요한 query를 전달하면 `response.tool_calls`에 값이 들어있는 것을 확인할 수 있다. `response.tool_calls`에는 어떤 tool을 호출해야 할지에 관한 정보가 들어 있다. Agent를 활용하면 실제로 tool을 호출해서 그 결과를 가져올 수 있다.

## Create the agent

Agent는 다음과 같이 LLM 모델과 tool 리스트를 활용해서 생성할 수 있다.

{% highlight python %}
from langgraph.prebuilt import create_react_agent

agent_executor = create_react_agent(model, tools)
{% endhighlight %}

이제 앞서 보내 본 query를 Agent에게도 동일하게 보내 보자.

{% highlight python %}
response = agent_executor.invoke({"messages": [HumanMessage(content="hi!")]})
for message in response["messages"] :
    print(repr(message))
    print('-----')
{% endhighlight %}

{% highlight txt %}
HumanMessage(content='hi!', id='45ae39bb-5a68-4333-a787-6ffb977288f2')
-----
AIMessage(content='Hello! How can I assist you today?', response_metadata={'token_usage': {'completion_tokens': 10, 'prompt_tokens': 83, 'total_tokens': 93}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-acac04ea-c81e-42fa-a657-411213b9eb5a-0', usage_metadata={'input_tokens': 83, 'output_tokens': 10, 'total_tokens': 93})
-----
{% endhighlight %}

{% highlight python %}
response = agent_executor.invoke(
    {"messages": [HumanMessage(content="whats the weather in sf?")]}
)
for message in response["messages"] :
    print(repr(message))
    print('-----')
{% endhighlight %}

{% highlight txt %}
HumanMessage(content='whats the weather in sf?', id='8299d3c8-47eb-40d0-8419-c975f56cca96')
-----
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_BiCv3h0xseV2IpoQ8hPOvxfz', 'function': {'arguments': '{"query":"weather in San Francisco"}', 'name': 'tavily_search_results_json'}, 'type': 'functio': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 21, 'prompt_tokens': 88, 'total_tokens': 109}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-537a7077-8d06-464c-89ab-43b54f227ff5-0', tool_calls=[{'name': 'tavily_search_results_json', 'args': {'query': 'weather in San Francisco'}, 'id': 'call_BiCv3h0xseV2IpoQ8hPOvxfz', 'type': 'tool_call'}], usage_metadata={'input_tokens': 88, 'output_tokens': 21, 'total_tokens': 109})
-----
ToolMessage(content='[{"url": "https://www.weatherapi.com/", "content": "{\'location\': {\'name\': \'San Francisco\', \'region\': \'California\', \'country\': \'United States of America\', \'lat\': 37.78, \'lon\': -122.42, \'tz_id\': \'America/Los_Angeles\', \'localtime_epoch\': 1724993043, \'localtime\': \'2024-08-29 21:44\'}, \'current\': {\'last_updated_epoch\': 1724992200, \'last_updated\': \'2024-08-29 21:30\', \'temp_c\': 17.2, \'temp_f\': 63.0, \'is_day\': 0, \'condition\': {\'text\': \'Partly cloudy\', \'icon\': \'//cdn.weatherapi.com/weather/64x64/night/116.png\', \'code\': 1003}, \'wind_mph\': 15.0, \'wind_kph\': 24.1, \'wind_degree\': 300, \'wind_dir\': \'WNW\', \'pressure_mb\': 1017.0, \'pressure_in\': 30.02, \'precip_mm\': 0.0, \'precip_in\': 0.0, \'humidity\': 84, \'cloud\': 25, \'feelslike_c\': 17.2, \'feelslike_f\': 63.0, \'windchill_c\': 15.5, \'windchill_f\': 59.8, \'heatindex_c\': 15.5, \'heatindex_f\': 59.8, \'dewpoint_c\': 12.8, \'dewpoint_f\': 55.0, \'vis_km\': 16.0, \'vis_miles\': 9.0, \'uv\': 1.0, \'gust_mph\': 19.5, \'gust_kph\': 31.3}}"}, {"url": "https://forecast.weather.gov/zipcity.php?inputstring=KSFO", "content": "Current conditions at San Francisco, San Francisco International Airport (KSFO) Lat: 37.61961\\u00b0NLon: ... 2024-6pm PDT Aug 30, 2024 . Forecast Discussion . Additional Resources. Radar & Satellite Image. ... National Weather Service; San Francisco Bay Area, CA; 21 Grace Hopper Ave, Stop 5; Monterey, CA 93943-5505; Comments? Questions?"}]', name='tavily_search_results_json', id='e7cb4fe0-f624-40c2-8ae4-86a88649c937', tool_call_id='call_BiCv3h0xseV2IpoQ8hPOvxfz')
-----
AIMessage(content='The current weather in San Francisco is partly cloudy with a temperature of 63.0°F (17.2°C). The wind is blowing at 24.1 km/h from the west-northwest direction. The humidity is at 84%, and the visibility is 9.0 miles.', response_metadata={'token_usage': {'completion_tokens': 61, 'prompt_tokens': 648, 'total_tokens': 709}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-69d7e553-f3da-4d38-8240-a69689ba8a0f-0', usage_metadata={'input_tokens': 648, 'output_tokens': 61, 'total_tokens': 709})
-----
{% endhighlight %}

두 번째 query를 보면 Agent가 tool을 호출하고 최종 결과까지 가져온 것을 확인할 수 있다.

## Streaming Messages

Agent의 응답을 스트리밍할 수도 있다.

{% highlight python %}
for chunk in agent_executor.stream(
    {"messages": [HumanMessage(content="whats the weather in sf?")]}
):
    print(chunk)
    print("----")
{% endhighlight %}

{% highlight txt %}
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_xzkHjHx5q2FIrFxgOsRwkoRv', 'function': {'arguments': '{"query":"weather in San Francisco"}', 'name': 'tavily_search_results_json'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 21, 'prompt_tokens': 88, 'total_tokens': 109}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-61a263f7-1f32-409e-8334-f8c7ea66dd9c-0', tool_calls=[{'name': 'tavily_search_results_json', 'args': {'query': 'weather in San Francisco'}, 'id': 'call_xzkHjHx5q2FIrFxgOsRwkoRv', 'type': 'tool_call'}], usage_metadata={'input_tokens': 88, 'output_tokens': 21, 'total_tokens': 109})]}}
----
{'tools': {'messages': [ToolMessage(content='[{"url": "https://www.weatherapi.com/", "content": "{\'location\': {\'name\': \'San Francisco\', \'region\': \'California\', \'country\': \'United States of America\', \'lat\': 37.78, \'lon\': -122.42, \'tz_id\': \'America/Los_Angeles\', \'localtime_epoch\': 1724993301, \'localtime\': \'2024-08-29 21:48\'}, \'current\': {\'last_updated_epoch\': 1724993100, \'last_updated\': \'2024-08-29 21:45\', \'temp_c\': 17.2, \'temp_f\': 63.0, \'is_day\': 0, \'condition\': {\'text\': \'Partly cloudy\', \'icon\': \'//cdn.weatherapi.com/weather/64x64/night/116.png\', \'code\': 1003}, \'wind_mph\': 15.0, \'wind_kph\': 24.1, \'wind_degree\': 300, \'wind_dir\': \'WNW\', \'pressure_mb\': 1017.0, \'pressure_in\': 30.02, \'precip_mm\': 0.0, \'precip_in\': 0.0, \'humidity\': 84, \'cloud\': 25, \'feelslike_c\': 17.2, \'feelslike_f\': 63.0, \'windchill_c\': 15.5, \'windchill_f\': 59.8, \'heatindex_c\': 15.5, \'heatindex_f\': 59.8, \'dewpoint_c\': 12.8, \'dewpoint_f\': 55.0, \'vis_km\': 16.0, \'vis_miles\': 9.0, \'uv\': 1.0, \'gust_mph\': 19.5, \'gust_kph\': 31.3}}"}, {"url": "https://www.wunderground.com/hourly/us/ca/san-francisco/94188/date/2024-8-30", "content": "Current Weather for Popular Cities . San Francisco, CA 66 \\u00b0 F Fair; Manhattan, NY 76 \\u00b0 F Partly Cloudy; Schiller Park, IL (60176) warning 83 \\u00b0 F Fair; Boston, MA 72 \\u00b0 F Fair; Houston, TX 78 ..."}]', name='tavily_search_results_json', tool_call_id='call_xzkHjHx5q2FIrFxgOsRwkoRv')]}}
----
{'agent': {'messages': [AIMessage(content='The current weather in San Francisco is 63°F with partly cloudy skies. The wind is coming from the west-northwest at 15 mph, and the humidity is at 84%.', response_metadata={'token_usage': {'completion_tokens': 39, 'prompt_tokens': 645, 'total_tokens': 684}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-8c6805cd-ef78-42cf-a24b-23d5d120805e-0', usage_metadata={'input_tokens': 645, 'output_tokens': 39, 'total_tokens': 684})]}}
----
{% endhighlight %}

## Streaming tokens

또는 토큰 단위로 스트리밍할 수도 있다.

{% highlight python %}
async def astream_agent(agent, query) :
    async for event in agent.astream_events({"messages": [HumanMessage(content=query)]}, version="v1") :
        kind = event["event"]
        if kind == "on_chain_start":
            if (
                event["name"] == "Agent"
            ):  # Was assigned when creating the agent with `.with_config({"run_name": "Agent"})`
                print(
                    f"Starting agent: {event['name']} with input: {event['data'].get('input')}"
                )
        elif kind == "on_chain_end":
            if (
                event["name"] == "Agent"
            ):  # Was assigned when creating the agent with `.with_config({"run_name": "Agent"})`
                print()
                print("--")
                print(
                    f"Done agent: {event['name']} with output: {event['data'].get('output')['output']}"
                )
        if kind == "on_chat_model_stream":
            content = event["data"]["chunk"].content
            if content:
                # Empty content in the context of OpenAI means
                # that the model is asking for a tool to be invoked.
                # So we only print non-empty content
                print(content, end="|")
        elif kind == "on_tool_start":
            print("--")
            print(
                f"Starting tool: {event['name']} with inputs: {event['data'].get('input')}"
            )
        elif kind == "on_tool_end":
            print(f"Done tool: {event['name']}")
            print(f"Tool output was: {event['data'].get('output')}")
            print("--")

import asyncio
asyncio.run(astream_agent(agent_executor, "whats the weather in sf?"))
{% endhighlight %}

{% highlight txt %}
--
Starting tool: tavily_search_results_json with inputs: {'query': 'weather in San Francisco'}
Done tool: tavily_search_results_json
Tool output was: content='[{"url": "https://www.weatherapi.com/", "content": "{\'location\': {\'name\': \'San Francisco\', \'region\': \'California\', \'country\': \'United States of America\', \'lat\': 37.78, \'lon\': -122.42, \'tz_id\': \'America/Los_Angeles\', \'localtime_epoch\': 1724993301, \'localtime\': \'2024-08-29 21:48\'}, \'current\': {\'last_updated_epoch\': 1724993100, \'last_updated\': \'2024-08-29 21:45\', \'temp_c\': 17.2, \'temp_f\': 63.0, \'is_day\': 0, \'condition\': {\'text\': \'Partly cloudy\', \'icon\': \'//cdn.weatherapi.com/weather/64x64/night/116.png\', \'code\': 1003}, \'wind_mph\': 15.0, \'wind_kph\': 24.1, \'wind_degree\': 300, \'wind_dir\': \'WNW\', \'pressure_mb\': 1017.0, \'pressure_in\': 30.02, \'precip_mm\': 0.0, \'precip_in\': 0.0, \'humidity\': 84, \'cloud\': 25, \'feelslike_c\': 17.2, \'feelslike_f\': 63.0, \'windchill_c\': 15.5, \'windchill_f\': 59.8, \'heatindex_c\': 15.5, \'heatindex_f\': 59.8, \'dewpoint_c\': 12.8, \'dewpoint_f\': 55.0, \'vis_km\': 16.0, \'vis_miles\': 9.0, \'uv\': 1.0, \'gust_mph\': 19.5, \'gust_kph\': 31.3}}"}, {"url": "https://www.weathertab.com/en/c/e/08/united-states/california/san-francisco/", "content": "Avg Low Temps 50 to 60 \\u00b0F. Explore comprehensive August 2024 weather forecasts for San Francisco, including daily high and low temperatures, precipitation risks, and monthly temperature trends. Featuring detailed day-by-day forecasts, dynamic graphs of daily rain probabilities, and temperature trends to help you plan ahead."}]' name='tavily_search_results_json' tool_call_id='call_ixGeheiLjgaq9vUnIPDKSJOi'
--
The| current| weather| in| San| Francisco| is| partly| cloudy| with| a| temperature| of| |63|.|0|°F| (|17|.|2|°C|).| The| wind| speed| is| |15|.|0| mph| (|24|.|1| k|ph|)| coming| from| the| West|-N|orth|west| direction|.| The| humidity| is| at| |84|%,| and| the| visibility| is| |9|.|0| miles|.|
{% endhighlight %}

## Adding in memory

지금까지 만든 Agent는 이전 대화를 기억하지 못하기 때문에 stateless 하다. 이전 대화를 기억하고 활용할 수 있게 하려면 memory를 추가해야 한다.

{% highlight python %}
from langgraph.checkpoint.memory import MemorySaver

memory = MemorySaver()
agent_executor = create_react_agent(model, tools, checkpointer=memory)
{% endhighlight %}

이제 Agent는 이전 대화를 기억할 수 있는데 각 대화는 아래 예시와 같이 `thread_id`를 통해 구분된다.

{% highlight python %}
# thread: abc123
config = {"configurable": {"thread_id": "abc123"}}

query = "hi im bob!"
print(f"query: {query}")
for chunk in agent_executor.stream(
    {"messages": [HumanMessage(content=query)]}, config
):
    print(chunk)
    print("----")
print()

query = "whats my name?"
print(f"query: {query}")
for chunk in agent_executor.stream(
    {"messages": [HumanMessage(content=query)]}, config
):
    print(chunk)
    print("----")
print()

# thread: xyz123
config = {"configurable": {"thread_id": "xyz123"}}

query = "whats my name?"
print(f"query: {query}")
for chunk in agent_executor.stream(
    {"messages": [HumanMessage(content=query)]}, config
):
    print(chunk)
    print("----")
print()
{% endhighlight %}

{% highlight txt %}
query: hi im bob!
{'agent': {'messages': [AIMessage(content='Hello Bob! How can I assist you today?', response_metadata={'token_usage': {'completion_tokens': 11, 'prompt_tokens': 85, 'total_tokens': 96}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-c1e8a508-6399-4b10-b4db-d62ecca59409-0', usage_metadata={'input_tokens': 85, 'output_tokens': 11, 'total_tokens': 96})]}}
----

query: whats my name?
{'agent': {'messages': [AIMessage(content='Your name is Bob!', response_metadata={'token_usage': {'completion_tokens': 6, 'prompt_tokens': 108, 'total_tokens': 114}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-a13d897c-2c02-4edf-8752-d34702ff6d65-0', usage_metadata={'input_tokens': 108, 'output_tokens': 6, 'total_tokens': 114})]}}
----

query: whats my name?
{'agent': {'messages': [AIMessage(content="I can't access your personal information like your name. If there's anything else you'd like to know or discuss, feel free to ask!", response_metadata={'token_usage': {'completion_tokens': 30, 'prompt_tokens': 86, 'total_tokens': 116}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-037f9fed-3038-4092-8b55-74bc70e23005-0', usage_metadata={'input_tokens': 86, 'output_tokens': 30, 'total_tokens': 116})]}}
----
{% endhighlight %}
