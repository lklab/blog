---
title: "Python async 함수를 C++에서 co_await하기"
image: /assets/post/25-03-27-python-awaiter-for-cpp/iStock-2162125350.jpg
image-source: https://www.istockphoto.com/kr/%EC%82%AC%EC%A7%84/coordinated-teamwork-business-concept-gm2162125350-582535034
author: khlee
categories:
    - ETC
layout: post
---

## 개요

대부분의 인공지능 코드는 파이썬으로 작성되지만, 성능 향상을 위해 인공지능 외의 기능은 C++로 구현하고, 두 언어가 통신할 수 있도록 구성하는 것이 유리할 수 있다. 이런 구조에서는 파이썬의 비동기 함수를 사용할 가능성이 높아지며, 이를 C++의 코루틴에 통합하면 코루틴의 장점을 효과적으로 활용할 수 있다. 이번 글에서는 파이썬의 비동기 함수를 C++ 코루틴에서 호출하고, 그 결과를 비동기적으로 가져오는 기능을 구현할 것이다.

## 환경

WSL Ubuntu 24.04 환경에서 구현했으며, 다음 의존성을 설치한다면 아마 다른 OS에서도 잘 동작할 것이다.

{% highlight bash %}
sudo apt update && sudo apt upgrade
sudo apt install python3-dev
sudo apt install libboost-all-dev
{% endhighlight %}

## 비동기 루프 시작

파이썬과 C++ 모두에서 코루틴을 사용하려면 둘 모두 각자의 스레드에서 비동기 루프를 실행해야 한다. 먼저 파이썬에서는 다음과 같이 비동기 루프를 관리하는 `manager.py`를 구현한다.

{% highlight python %}
import asyncio
import threading

loop: asyncio.AbstractEventLoop = None
thread: threading.Thread = None
_cppmodule = None

def _event_loop(loop: asyncio.AbstractEventLoop) :
    try :
        loop.run_forever()
    except :
        pass
    finally :
        loop.close()

async def _stop_event_loop(loop: asyncio.AbstractEventLoop) :
    loop.stop()

def initialize() :
    global loop
    global _cppmodule
    if loop != None :
        return

    # start event loop
    global thread
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    thread = threading.Thread(target=_event_loop, args=(loop,))
    thread.start()

    # import c module
    import cppmodule as cppmodule # type: ignore
    _cppmodule = cppmodule

def terminate() :
    global loop
    if loop == None :
        return

    # stop event loop
    global thread
    asyncio.run_coroutine_threadsafe(_stop_event_loop(loop), loop)
    thread.join()
{% endhighlight %}

`initialize()`와 `terminate()`는 C++에서 호출할 함수로, 각각 비동기 루프를 다른 스레드에서 시작하거나 종료하는 기능을 한다. 이제 이 함수를 호출하는 `manager.cpp` 코드를 구현한다.

{% highlight cpp %}
void initialize(boost::asio::io_context& io_context)
{
    if (g_initialized)
    {
        return;
    }

    set_io_context(io_context);

    PyImport_AppendInittab("cppmodule", PyInit_cppmodule);
    Py_Initialize();

    PyRun_SimpleString("import sys");
    PyRun_SimpleString("import os");
    PyRun_SimpleString("sys.path.append(os.getcwd())");

    p_module = PyImport_ImportModule("python.manager");
    if (!p_module)
    {
        PyErr_Print();
        return;
    }

    PyObject* p_func_initialize = PyObject_GetAttrString(p_module, "initialize");
    call_python_function(p_func_initialize);

    Py_XDECREF(p_func_initialize);

    PyEval_SaveThread();

    g_initialized = true;
}

void terminate()
{
    if (!g_initialized)
    {
        return;
    }

    ensure_gil();

    PyErr_CheckSignals();
    PyErr_Clear();

    PyObject* p_func_terminate = PyObject_GetAttrString(p_module, "terminate");
    call_python_function(p_func_terminate);
    Py_XDECREF(p_func_terminate);

    Py_XDECREF(p_module);

    release_gil();

    ensure_gil();
    Py_Finalize();

    g_initialized = false;
}
{% endhighlight %}

파이썬에서 별도의 스레드를 실행했으므로 멀티스레드 환경에서 동작할 수 있도록 `PyEval_SaveThread()`를 호출하였다.

## Future 패턴 구현

C++에서 파이썬의 비동기 함수를 실행하면, 그 함수가 종료되었을 때 C++ 함수를 실행하는 방식으로 구현할 것이다. 그리고 이것을 코루틴에서 `co_await` 할 수 있으려면 Future 패턴으로 구현해야 한다. 이걸 구현하기 위해 ChatGPT를 구워삶아봤지만 컴파일이 되지도 않는 코드를 줄 뿐이었다.

![GPT 1]({{site.baseurl}}/assets/post/25-03-27-python-awaiter-for-cpp/2025-03-27-102735.png){: width="640" .custom-align-center-img}
![GPT 2]({{site.baseurl}}/assets/post/25-03-27-python-awaiter-for-cpp/2025-03-27-102725.png){: width="640" .custom-align-center-img}

그리고 포기도 안 한다.

![GPT 3]({{site.baseurl}}/assets/post/25-03-27-python-awaiter-for-cpp/2025-03-27-102745.png){: width="640" .custom-align-center-img}

그래서 재웠다.

대신에, 타이머를 생성해서 `co_await`를 하고, 파이썬에서 C++에 코루틴의 결과를 보내면 그 타이머를 `cancel()`해서 즉시 `co_await`를 빠져나오는 식으로 구현하였다. 이렇게 하면 자연스럽게 타임아웃 설정도 가능해서 좋은 것 같다.

{% highlight cpp %}
static std::unordered_map<int, std::weak_ptr<boost::asio::steady_timer>> g_timers;
static std::unordered_map<int, PyObject*> g_results;

int new_request(std::shared_ptr<boost::asio::steady_timer>& timer)
{
    int rqid = g_rqid_counter;
    ++g_rqid_counter;
    if (g_rqid_counter < 0) g_rqid_counter = 0;

    g_timers[rqid] = timer;

    return rqid;
}

void clear_request(int rqid)
{
    auto timer_it = g_timers.find(rqid);
    if (timer_it != g_timers.end())
    {
        if (auto timer = timer_it->second.lock())
        {
            timer->cancel();
            timer.reset();
        }
        g_timers.erase(rqid);
    }

    auto result_it = g_results.find(rqid);
    if (result_it != g_results.end())
    {
        ensure_gil();
        Py_XDECREF(result_it->second);
        release_gil();

        g_results.erase(rqid);
    }
}

void on_cpp_callback(PyObject* p_args)
{
    int rqid;
    PyObject* p_arg;

    if (!PyArg_ParseTuple(p_args, "iO", &rqid, &p_arg))
    {
        return;
    }

    Py_INCREF(p_args);

    boost::asio::post(get_io_context(), [rqid, p_args]()
    {
        auto timer_it = g_timers.find(rqid);
        if (timer_it != g_timers.end())
        {
            if (auto timer = timer_it->second.lock())
            {
                g_results[rqid] = p_args;
                timer->cancel();
                timer.reset();
                return; // success
            }
        }

        // fail
        ensure_gil();
        Py_XDECREF(p_args);
        release_gil();
    });
}

template<typename T>
std::shared_ptr<T> get_result(int rqid)
{
    PyObject* p_args = get_args(rqid);
    if (p_args == nullptr) return nullptr;

    return parse_py_object<T>(p_args);
}
{% endhighlight %}

`new_request()` 함수를 호출하면 새로운 타이머를 등록한다. 파이썬에서 C++ 함수를 호출할 때, 클래스 멤버 함수를 호출하게 할 수는 없어서 이런 타이머들을 전역 변수로 관리하고 `rqid`라는 `int`형 변수로 각각의 타이머를 구분할 수 있도록 하였다. 이 `rqid` 값은 C++에서 파이썬 함수를 호출할 때와, 파이썬에서 C++ 함수를 호출할 때 항상 전달해서 어떤 호출에 대한 응답인지 구분하는 역할을 한다.

`clear_request()` 함수는 해당 `rqid`와 관련된 타이머나 결과값 등을 정리하는 역할을 한다. 이 함수를 반드시 호출해야 메모리 누수가 생기지 않는다.

`on_cpp_callback()` 함수는 파이썬에서 C++ 함수를 호출했을 때 호출되는 함수이다. `manager.cpp`에서 다음과 같이 파이썬에 C++ 모듈을 등록하고 그로 인해 호출된 함수에서 `on_cpp_callback()` 함수를 호출하도록 구현하였다.

{% highlight cpp %}
static PyObject* cpp_callback(PyObject* self, PyObject* p_args)
{
    pyawaiter::on_cpp_callback(p_args);
    Py_RETURN_NONE;
}

static PyMethodDef cppmethod[] = {
    {"cpp_callback", cpp_callback, METH_VARARGS, "cpp_callback"},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef cppmodule = {
    PyModuleDef_HEAD_INIT,
    "cppmodule",
    NULL,
    -1,
    cppmethod
};

PyMODINIT_FUNC PyInit_cppmodule(void)
{
    return PyModule_Create(&cppmodule);
}
{% endhighlight %}

`manager.cpp`의 `initialize()`에서 `PyImport_AppendInittab("cppmodule", PyInit_cppmodule)`을 통해 `cppmodule`라는 모듈을 만들고 그 모듈에 `cpp_callback()` 함수를 포함시켜서 파이썬에서 호출할 수 있도록 구현하였다.

`on_cpp_callback()` 함수는 파이썬의 비동기 루프가 실행되는 스레드에서 실행되기 때문에 race condition이 발생하지 않도록 `boost::asio::post()`로 C++의 비동기 루프로 데이터를 전달해야 한다. 이 때, `cpp_callback()` 함수가 종료되면 그 파라미터로 받은 `PyObject* p_args`의 참조 카운트가 줄어서 소멸될 수 있기 때문에 `Py_INCREF()`로 참조 카운트를 늘려야 한다. 이렇게 증가한 참조 카운트는 `clear_request()`를 호출하여 다시 감소시킬 수 있다.

마지막으로 `get_result()` 함수는 타이머가 종료되었을 때 파이썬 비동기 함수의 반환값을 파싱해서 가져오는 역할을 한다.

## 파이썬 비동기 호출자 구현

{% highlight cpp %}
template<typename TResult, typename... Args>
class AsyncInvoker
{
public:
    AsyncInvoker(PyObject* p_method) : p_method(p_method) { }

    AsyncInvoker(const char* module, const char* func)
    {
        ensure_gil();
        PyObject* p_module = PyImport_ImportModule(module);
        p_method = PyObject_GetAttrString(p_module, func);
        Py_XDECREF(p_module);
        release_gil();
    }

    virtual ~AsyncInvoker()
    {
        ensure_gil();
        Py_XDECREF(p_method);
        release_gil();
    }

    boost::asio::awaitable<std::shared_ptr<TResult>> call(const Args&... args, int timeout = 10)
    {
        std::shared_ptr<boost::asio::steady_timer> timer = std::make_shared<boost::asio::steady_timer>(get_io_context(), std::chrono::seconds(timeout));
        int rqid = new_request(timer);

        ensure_gil();
        constexpr size_t N = sizeof...(Args);
        PyObject* py_objects[N + 1];
        py_objects[0] = PyLong_FromLong(rqid);
        size_t i = 1;
        ((py_objects[i++] = to_py_object(args)), ...);
        PyObject* p_args = PyTuple_New(static_cast<int>(N + 1));
        for (size_t j = 0; j < N + 1; ++j)
        {
            PyTuple_SET_ITEM(p_args, j, py_objects[j]);
        }

        call_python_function(p_method, p_args);

        Py_DECREF(p_args);
        release_gil();

        try
        {
            co_await timer->async_wait(boost::asio::use_awaitable);
        }
        catch (std::exception& e) { }
        timer.reset();

        std::shared_ptr<TResult> result = get_result<TResult>(rqid);
        clear_request(rqid);
        co_return result;
    }

private:
    PyObject* p_method;
};
{% endhighlight %}

생성자에서 파이썬 함수를 가리키는 포인터인 `p_method`를 초기화한다. 그리고 `call()`을 호출하면 파이썬의 비동기 함수를 실행하고 그 결과를 `co_await`할 수 있다.

함수의 파라미터와 반환값이 템플릿으로 되어 있는데, 이 값을 파이썬 오브젝트(`PyObject*`)와 상호 변환할 수 있도록 각각의 타입에 대해 `to_py_object()`와 `parse_py_object()` 함수를 특수화해야 한다. 다음은 몇몇 타입에 대한 예시이다.

{% highlight cpp %}
template<>
PyObject* to_py_object(const int& val)
{
    return PyLong_FromLong(val);
}

template<>
PyObject* to_py_object(const double& val)
{
    return PyFloat_FromDouble(val);
}

template<>
PyObject* to_py_object(const char* const& val)
{
    return PyUnicode_FromString(val);
}

template<>
PyObject* to_py_object(const std::string& val)
{
    return PyUnicode_FromString(val.c_str());
}

template<>
std::shared_ptr<int> parse_py_object(PyObject* p_args)
{
    int rqid;
    int result;

    if (!PyArg_ParseTuple(p_args, "ii", &rqid, &result))
    {
        return nullptr;
    }

    return std::make_shared<int>(result);
}

template<>
std::shared_ptr<std::string> parse_py_object(PyObject* p_args)
{
    int rqid;
    const char* c_str;

    if (!PyArg_ParseTuple(p_args, "is", &rqid, &c_str))
    {
        return nullptr;
    }

    return std::make_shared<std::string>(c_str);
}
{% endhighlight %}

만약 사용하고자 하는 타입의 특수화가 정의되어 있지 않다면 컴파일 오류가 발생한다. 해결하려면 해당 타입의 특수화를 별도로 정의해주면 된다.

## 테스트

다음은 테스트를 위한 파이썬의 비동기 함수 코드다.

{% highlight python %}
import asyncio
import random

from python.manager import loop, _cppmodule

async def _example_func(rqid: int, arg0: int, arg1: str, arg2: float) :
    await asyncio.sleep(random.uniform(5.0, 15.0))

    global _cppmodule
    _cppmodule.cpp_callback(rqid, f'python: rqid={rqid}, arg0={arg0}, arg1={arg1}, arg2={arg2}')

def example_func(rqid: int, arg0: int, arg1: str, arg2: float) :
    global loop
    asyncio.run_coroutine_threadsafe(_example_func(rqid, arg0, arg1, arg2), loop)
{% endhighlight %}

`example_func()` 함수는 C++에서 호출하는 함수인데, 파이썬의 비동기 함수는 파이썬의 비동기 루프에서 실행해야 하므로 `asyncio.run_coroutine_threadsafe()`를 통해 비동기 함수를 실행하도록 한다. 비동기 함수의 실행이 끝나면 `_cppmodule.cpp_callback()`을 호출하여 그 결과를 C++에 전달한다.

다음은 이 파이썬 함수를 호출하는 C++의 코드다.

{% highlight python %}
static boost::asio::io_context io_context;

boost::asio::awaitable<void> test(int id)
{
    pyawaiter::AsyncInvoker<std::string, int, const char*, double> invoker("example.example", "example_func");
    std::shared_ptr<std::string> result = co_await invoker.call(id, "example_string", 1.23);

    if (result)
    {
        std::cout << "[" << id << "] test result: " << *result.get() << std::endl;
    }
    else
    {
        std::cout << "[" << id << "] test result: nullptr" << std::endl;
    }
}

boost::asio::awaitable<void> waiter()
{
    boost::asio::steady_timer timer(io_context, std::chrono::seconds(20));
    co_await timer.async_wait(boost::asio::use_awaitable);
}

int main()
{
    pyawaiter::initialize(io_context);

    std::signal(SIGINT, [](int sig)
    {
        std::cout << "\nCaught SIGINT" << std::endl;
        io_context.stop();
    });

    for (int i = 0; i < 10; ++i)
    {
        boost::asio::co_spawn(
            io_context,
            test(i),
            boost::asio::detached
        );
    }

    boost::asio::co_spawn(
        io_context,
        waiter(),
        boost::asio::detached
    );

    io_context.run();

    pyawaiter::terminate();

    return 0;
}
{% endhighlight %}

10개의 `AsyncInvoker`를 생성해서 `call()`을 호출한다. 파이썬에서는 5~15초 랜덤으로 대기 후 결과를 반환하므로 순서는 뒤죽박죽이 될 것이다. 그리고 기본적으로 타임아웃이 10초로 설정되어 있기 때문에 타임아웃이 발생한 이후에는 `result`가 `nullptr`가 될 것이다. 다음은 실행한 결과다.

{% highlight txt %}
[9] test result: python: rqid=9, arg0=9, arg1=example_string, arg2=1.23
[7] test result: python: rqid=7, arg0=7, arg1=example_string, arg2=1.23
[2] test result: python: rqid=2, arg0=2, arg1=example_string, arg2=1.23
[4] test result: python: rqid=4, arg0=4, arg1=example_string, arg2=1.23
[0] test result: nullptr
[1] test result: nullptr
[3] test result: nullptr
[5] test result: nullptr
[6] test result: nullptr
[8] test result: nullptr
{% endhighlight %}

전체 코드는 [여기](https://github.com/lklab/python-awaiter-for-cpp)서 확인할 수 있다.
