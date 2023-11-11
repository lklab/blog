---
title: "유니티 비동기 프로그래밍: Coroutines, Tasks and UniTasks"
image: /assets/post/23-11-06-unity-async-methods/multitasking.jpg
image-source: https://pixabay.com/ko/illustrations/%EB%A8%B8%EB%A6%AC-%EC%8B%A4%EB%A3%A8%EC%97%A3-%EB%A9%80%ED%8B%B0%ED%83%9C%EC%8A%A4%ED%82%B9-6332128/
author: khlee
categories:
    - Unity
layout: post
---

## 개요

유니티에서 비동기 프로그래밍을 하는 방법은 3가지가 있다. 기본적으로 제공되는 Coroutine과 Task가 있고, 패키지 형태로 추가할 수 있는 [UniTask](https://github.com/Cysharp/UniTask)가 있다. 이번 포스트에서는 각 비동기 프로그래밍 방법들의 특징에 대해 정리할 것이다.

## Coroutine은 멀티 스레딩?

Coroutine은 싱글 스레드로 유니티 메인 스레드에서 동작한다. 그 말은, Coroutine 내에서 `yield` 문을 통해 명시적으로 제어를 반납하지 않는 한 절대로 메인 스레드에서 다른 코드가 실행되지 않는다는 것을 의미한다. 그렇기 때문에 Coroutine 내에서 제어를 반납하지 않고 많은 작업을 하거나 무한루프에 빠지는 경우 프로그램 전체가 느려지거나 아예 멈추어버릴 수 있다. 한편으론 싱글 스레드이기 때문에 race condition, thread-safe 등에 대한 걱정에서 자유로우며 유니티 함수들을 안전하게 호출할 수 있다.

## Coroutine 동작 원리

Coroutine의 반환 타입은 `IEnumerator`다. `IEnumerator`를 반환하는 함수에서는 아래와 같이 `yield` 문을 사용할 수 있다.

{% highlight csharp %}
private IEnumerator MyCoroutine()
{
    Debug.Log("Coroutine 1");
    yield return null;
    Debug.Log("Coroutine 2");
    yield return null;
    Debug.Log("Coroutine 3");
}
{% endhighlight %}

그리고 이 `IEnumerator` 객체의 `MoveNext()`를 호출하면

{% highlight csharp %}
private void Start()
{
    IEnumerator enumerator = MyCoroutine();

    Debug.Log("Start 1");
    enumerator.MoveNext();
    Debug.Log("Start 2");
    enumerator.MoveNext();
    Debug.Log("Start 3");
    enumerator.MoveNext();
}
{% endhighlight %}

{% highlight log %}
Start 1
Coroutine 1
Start 2
Coroutine 2
Start 3
Coroutine 3
{% endhighlight %}

`Coroutine` 로그 사이에 `Start`가 들어가 있다는 것을 확인할 수 있다. 즉 `MyCoroutine()` 함수 내의 지정된 지점에서 제어를 반납할 수 있고 이후의 코드는 나중에 실행할 수 있다는 것이다. 이것이 비동기 동작의 핵심이다.

참고로 `IEnumerator`는 본래 foreach 등에서 컬렉션을 순회하기 위한 용도로 사용된다. 이에 관해 더 알고 싶다면 [이 블로그](https://code-loving.tistory.com/entry/C-Foreach%EC%99%80-IEnumerator)를 참고할 수 있다.

그렇다면 우리의 Coroutine을 실행하기 위한 `MoveNext()`를 유니티 엔진에서 호출해주고 있음을 쉽게 짐작할 수 있다. 간단히 다음과 같은 Coroutine을 실행해서 로그를 확인해 보면

{% highlight csharp %}
private void Start()
{
    StartCoroutine(MyCoroutine());
}

private IEnumerator MyCoroutine()
{
    yield return null;
    Debug.Log("MyCoroutine");
}
{% endhighlight %}

{% highlight csharp %}
MyCoroutine
UnityEngine.Debug:Log (object)
TestController/<MyCoroutine>d__1:MoveNext () (at Assets/Scripts/TestController.cs:39)
UnityEngine.SetupCoroutine:InvokeMoveNext (System.Collections.IEnumerator,intptr) (at /Users/bokken/build/output/unity/unity/Runtime/Export/Scripting/Coroutines.cs:17)
{% endhighlight %}

Stack trace에 `MoveNext`가 있음을 확인할 수 있다.

이제 `yield return`에서 반환하는 값이 실제로 무슨 일을 하는지 알아볼 것이다. 우리는 `yield return new WaitForSeconds(1.0f);`를 호출하면 그 이후의 코드가 1초 뒤에 실행된다는 사실을 알고 있다. 그 원리를 알아보기 위해 `IEnumerator`가 무엇으로 이루어져 있는지 파악할 필요가 있다. `IEnumerator` 인터페이스를 구현하려면 다음과 같은 멤버를 구현해야 한다.

{% highlight csharp %}
public class MyEnumerator : IEnumerator
{
    public object Current { get; }

    public bool MoveNext()
    {
        return false;
    }

    public void Reset() { }
}
{% endhighlight %}

* `public object Current { get; }`: 가장 최근에 `yield return`으로 반환한 값이다.
* `public bool MoveNext()`: Coroutine의 다음 작업(`yield` 문 다음의 코드들) 재개하는 함수이다.
* `public void Reset()`: Coroutine에서는 쓰이지 않는데, 작업을 다시 처음으로 돌리는 함수이다. 이 함수를 호출하고 `MoveNext()`를 호출하면 다시 처음 작업이 실행된다.

여기서 `Current`가 `yield return`으로 반환된 값이라는 것이 중요하다. 실제로 다음 코드를 실행하면

{% highlight csharp %}
private void Start()
{
    IEnumerator enumerator = MyCoroutine();
    enumerator.MoveNext();
    Debug.Log($"Current={enumerator.Current}");
}

private IEnumerator MyCoroutine()
{
    yield return new WaitForSeconds(1.0f);
}
{% endhighlight %}

다음과 같은 로그를 출력한다.

{% highlight log %}
Current=UnityEngine.WaitForSeconds
{% endhighlight %}

따라서 유니티 엔진에서 `MoveNext()`를 호출한 후 `Current` 값을 확인해서 다음 `MoveNext()`를 언제 호출할지 결정하는 로직이 구현되어 있음을 짐작할 수 있다.

유니티 문서의 [ExecutionOrder](https://docs.unity3d.com/Manual/ExecutionOrder.html)를 보면 `Current`에 따라 `MoveNext()`가 언제 호출될지 확인할 수 있다.

대부분의 `Current` 값에 대해서는 `MoveNext()`가 `Update()` 직후에 호출된다.

![General yield instructions]({{site.baseurl}}/assets/post/23-11-06-unity-async-methods/general_yield_instructions.png)

`WaitForEndOfFrame`의 경우 렌더링이 모두 끝나고 프레임이 종료되기 직전에 호출된다.

![WaitForEndOfFrame yield instruction]({{site.baseurl}}/assets/post/23-11-06-unity-async-methods/end_of_frame_yield_instruction.png)

`WaitForFixedUpdate`의 경우 물리 루프가 끝나기 직전에 호출된다. `FixedUpdate()`와는 반대로 물리 업데이트가 끝난 후에 호출되는 것을 확인할 수 있다.

![WaitForFixedUpdate yield instruction]({{site.baseurl}}/assets/post/23-11-06-unity-async-methods/fixed_update_yield_instruction.png)

## Task의 멀티 스레딩

Task는 기본적으로 스레드풀에서 동작할 수 있음을 감안해야 한다. 예를 들어 아래와 같은 코드는

{% highlight csharp %}
private void Start()
{
    Debug.Log($"MainThreadID = {Thread.CurrentThread.ManagedThreadId}");

    Task.Run(() =>
    {
        Debug.Log($"ThreadID Task = {Thread.CurrentThread.ManagedThreadId}");
    });
}
{% endhighlight %}

아래와 같은 로그를 출력한다.

{% highlight log %}
MainThreadID = 1
ThreadID Task = 48
{% endhighlight %}

메인 스레드에서 `await`를 만난 경우, `await` 이후의 코드도 메인 스레드에서 실행된다.

{% highlight csharp %}
private async void Start()
{
    Debug.Log($"MainThreadID = {Thread.CurrentThread.ManagedThreadId}");

    await Task.Run(() =>
    {
        Debug.Log($"ThreadID Task = {Thread.CurrentThread.ManagedThreadId}");
    });

    Debug.Log($"ThreadID Start = {Thread.CurrentThread.ManagedThreadId}");
}

private void Update()
{
    Debug.Log($"ThreadID Update = {Thread.CurrentThread.ManagedThreadId}");
}
{% endhighlight %}

{% highlight log %}
MainThreadID = 1
ThreadID Task = 92
ThreadID Update = 1
ThreadID Start = 1
{% endhighlight %}

로그에서 `ThreadID Task`와 `ThreadID Start` 사이에 `ThreadID Update`가 껴 있다. 이 말은 `await` 이후의 코드가 비동기적으로 실행되었다는 의미이다.

반면 메인 스레드가 아닌 스레드에서 `await`를 만난 경우 항상 같은 스레드에서 실행되는 것이 보장되지는 않는다.

{% highlight csharp %}
private void Start()
{
    Debug.Log($"MainThreadID = {Thread.CurrentThread.ManagedThreadId}");

    Task.Run(async () =>
    {
        Debug.Log($"ThreadID Task 1 = {Thread.CurrentThread.ManagedThreadId}");
        await Task.Yield();
        Debug.Log($"ThreadID Task 2 = {Thread.CurrentThread.ManagedThreadId}");
    });
}
{% endhighlight %}

{% highlight log %}
MainThreadID = 1
ThreadID Task 1 = 121
ThreadID Task 2 = 128
{% endhighlight %}

메인 스레드에서 `await` 이후의 코드가 스레드 풀에서 실행되기 원하는 경우 `ConfigureAwait(false)`를 사용할 수 있다.

{% highlight csharp %}
private async void Start()
{
    Debug.Log($"MainThreadID = {Thread.CurrentThread.ManagedThreadId}");

    await Task.Run(() =>
    {
        Debug.Log($"ThreadID Task = {Thread.CurrentThread.ManagedThreadId}");
    }).ConfigureAwait(false);

    Debug.Log($"ThreadID Start = {Thread.CurrentThread.ManagedThreadId}");
}
{% endhighlight %}

{% highlight log %}
MainThreadID = 1
ThreadID Task = 156
ThreadID Start = 156
{% endhighlight %}

Task 내부에서의 스레드와 `await` 이후의 스레드가 같다는 것을 확인할 수 있다!

## Task 동작 원리

앞 문단에서는 `Task`와 `async / await`를 구분하지 않고 사용했지만 사실은 차이가 있다. `async / await`는 언어 차원에서 제공되는 비동기 프로그래밍 기능에 관한 키워드이고, `Task`는 `async / await`를 이용해서 작업을 스레드풀에서 비동기적으로 실행할 수 있도록 해 주는 구현체이다. 따라서 꼭 `Task`가 아니더라도 `Task` 같은 무언가를 직접 만들어서 `async / await`를 통해 비동기 프로그래밍을 할 수 있다. 이 문단에서는 비동기 작업을 의미하는 `MyTask<T>`라는 클래스를 만들어보면서 `Task`의 동작 원리에 대해 살펴 볼 것이다.

어떤 작업을 비동기적으로 실행하려면 `awaitable` 해야 한다. `awaitable` 하다는 것은 `await` 키워드와 함께 사용할 수 있는 객체라는 뜻이다. 아래와 같이 `awaitable`하지 않은 객체를 `await` 키워드와 함께 사용하면 컴파일 오류가 발생한다.

{% highlight csharp %}
private async void Start()
{
    await MyFunc();
}

private int MyFunc()
{
    return 1;
}
{% endhighlight %}

{% highlight log %}
'int' does not contain a definition for 'GetAwaiter' and no accessible extension method 'GetAwaiter' accepting a first argument of type 'int' could be found (are you missing a using directive or an assembly reference?)
{% endhighlight %}

오류 메시지를 보면 `MyFunc()`의 반환 타입인 `int`에 `GetAwaiter`에 대한 정의가 없다고 하는 것을 알 수 있다. 따라서 `awaitable`이 되려면 `GetAwaiter`를 구현하면 된다.

{% highlight csharp %}
public class MyTask<T>
{
    public MyAwaiter<T> GetAwaiter()
    {
        return new MyAwaiter<T>(this);
    }
}
{% endhighlight %}

다음 문제가 생겼다. `GetAwaiter`는 뭔가 `Awaiter`를 반환해야 한다는 것이다. `Awaiter`가 되려면 다음과 같은 멤버를 구현해야 한다.

* `public bool IsCompleted { get; }`: 해당 작업이 이미 종료되었는지를 확인하는 함수다. `true`를 반환하면 `OnCompleted()` 호출 없이 바로 `GetResult()`를 호출하며 `await` 이후의 코드가 동기적으로 실행된다.
* `public T GetResult()`: 해당 작업의 결과를 가져오는 함수다. 결과를 가져 올 필요가 없는 작업이라면 반환타입을 `void`로 선언하면 된다.
* `public void OnCompleted(Action continuation)`: `INotifyCompletion` 인터페이스를 상속받아 구현되는 함수로, 해당 작업이 완료되었을 때 실행해야 할 함수를 지정하는 함수다. `continuation`에 `await` 이후의 코드가 들어있다.

`INotifyCompletion` 말고 `ICriticalNotifyCompletion` 인터페이스를 구현할 수도 있다. 이 경우 `OnCompleted()` 대신 `UnsafeOnCompleted()`가 호출된다.

여기서 `OnCompleted()`를 통해 전달받는 `continuation`에 `await` 이후의 코드가 들어있다는 것이 `async / await` 비동기 동작의 핵심이다. 우리는 이 `continuation`의 호출을 우리가 원하는 시점에 호출해서 `await` 이후의 코드의 실행을 우리가 원하는 지점까지 지연시킬 수 있다. 그렇게 지연된 동안 현재 스레드는 다른 작업을 할 수 있는 것이다.

위의 멤버를 구현한 `MyAwaiter<T>`는 다음과 같다.

{% highlight csharp %}
public struct MyAwaiter<T> : INotifyCompletion
{
    private MyTask<T> task;
    public bool IsCompleted => false;

    public T GetResult()
    {
        return default;
    }

    public MyAwaiter(MyTask<T> task)
    {
        this.task = task;
    }

    public void OnCompleted(Action continuation)
    {
        Debug.Log("called OnCompleted");
        continuation?.Invoke();
    }
}

public class MyTask<T>
{
    public MyAwaiter<T> GetAwaiter()
    {
        return new MyAwaiter<T>(this);
    }
}

public class TestController : MonoBehaviour
{
    private void Start()
    {
        Debug.Log("Start a");
        AsyncWork();
        Debug.Log("Start b");
    }

    private async void AsyncWork()
    {
        Debug.Log("AsyncWork a");
        await new MyTask<int>();
        Debug.Log("AsyncWork b");
    }
}
{% endhighlight %}

{% highlight log %}
Start a
AsyncWork a
called OnCompleted
AsyncWork b
Start b
{% endhighlight %}

`OnCompleted()` 함수의 매개변수로 들어오는 `continuation`을 호출하면 `await` 이후의 코드인 로그 `AsyncWork b`가 출력되는 것을 확인할 수 있다. 하지만 이렇게 구현된 `MyAwaiter<T>`를 사용하면, 로그 `Start b`가 항상 `called OnCompleted` 다음에 출력된다. 즉, `OnCompleted()` 함수는 동기적으로 실행되므로 비동기 작업을 여기서 실행하면 안된다. 비동기적인 작업을 수행할 수 있도록 `MyTask<T>`를 다음과 같이 수정한다.

{% highlight csharp %}
public struct MyAwaiter<T> : INotifyCompletion
{
    private MyTask<T> task;

    public bool IsCompleted => task.IsTaskCompleted;

    public T GetResult()
    {
        return task.Result;
    }

    public MyAwaiter(MyTask<T> task)
    {
        this.task = task;
    }

    public void OnCompleted(Action continuation)
    {
        task.OnTaskCompleted += continuation;
        task.Start();
    }
}

public class MyTask<T>
{
    private Thread thread;
    public T Result { get; private set; }
    public bool IsTaskCompleted { get; private set; } = false;
    public event Action OnTaskCompleted;

    public MyTask(Func<T> func)
    {
        thread = new Thread(() =>
        {
            Result = func();
            IsTaskCompleted = true;
            OnTaskCompleted?.Invoke();
        });
    }

    public MyAwaiter<T> GetAwaiter()
    {
        return new MyAwaiter<T>(this);
    }

    public void Start()
    {
        thread.Start();
    }
}

public class TestController : MonoBehaviour
{
    private void Start()
    {
        Debug.Log($"ThreadID Start a = {Thread.CurrentThread.ManagedThreadId}");
        AsyncWork();
        Debug.Log($"ThreadID Start b = {Thread.CurrentThread.ManagedThreadId}");
    }

    private async void AsyncWork()
    {
        Debug.Log($"ThreadID AsyncWork a = {Thread.CurrentThread.ManagedThreadId}");
        int value = await new MyTask<int>(() =>
        {
            Debug.Log($"ThreadID Task = {Thread.CurrentThread.ManagedThreadId}");
            return 5;
        });
        Debug.Log($"value={value}, ThreadID AsyncWork b = {Thread.CurrentThread.ManagedThreadId}");
    }
}
{% endhighlight %}

{% highlight log %}
ThreadID Start a = 1
ThreadID AsyncWork a = 1
ThreadID Start b = 1
ThreadID Task = 1100
value=5, ThreadID AsyncWork b = 1100
{% endhighlight %}

이제 `MyTask<T>`는 작업을 비동기적으로 실행하기 때문에 `Start b`가 `AsyncWork b`보다 먼저 출력되는 것을 확인할 수 있다. 하지만 여기에서는 `Task`와 한 가지 차이점이 있다. 바로 로그 `AsyncWork a`가 메인 스레드에서 실행되었음에도 로그 `AsyncWork b`는 메인 스레드에서 실행되지 않았다는 점이다. 그럼 작업이 종료되었을 때 `continuation`을 메인 스레드에서 실행하는 방법을 알아야 한다. 이것을 위해 `SynchronizationContext`가 있다.

## SynchronizationContext

`SynchronizationContext`는 스레드간 동기화 컨텍스트를 담는 역할을 한다. `SynchronizationContext` 클래스 자체는 개념적인 것이고 유니티의 경우 `UnityEngine.UnitySynchronizationContext`가 구현되어 있다.

메인 스레드에서는 기본적으로 `SynchronizationContext.Current`에 `UnitySynchronizationContext`가 있고, 그 외의 모든 백그라운드 스레드에서는 따로 정의하지 않는 한 `SynchronizationContext.Current`은 `null`이다.

{% highlight csharp %}
private void Start()
{
    Debug.Log($"Start: {SynchronizationContext.Current?.ToString() ?? "null"}");

    Task.Run(() =>
    {
        Debug.Log($"Task: {SynchronizationContext.Current?.ToString() ?? "null"}");
    });
}
{% endhighlight %}

{% highlight log %}
Start: UnityEngine.UnitySynchronizationContext
Task: null
{% endhighlight %}

마지막으로 `SynchronizationContext`에는 `Post()`와 `Send()` 함수가 있다. 이 함수를 통해 특정 함수를 `SynchronizationContext`가 정의된 스레드에서 실행되도록 디스패치할 수 있다. 따라서 `UnitySynchronizationContext`의 경우에는 유니티 메인 스레드에서 실행되도록 디스패치할 수 있다. `Post()`와 `Send()`의 차이점은, `Post()`는 비동기적으로 함수를 디스패치하고 현재 스레드에서 다음 작업을 실행할 수 있는 반면 `Send()`는 디스패치 후 그 결과를 받아야 하므로 전달한 함수가 끝나야만 현재 스레드를 재개할 수 있다는 것이다.

이제 `SynchronizationContext`를 고려해서 수정한 `MyTask<T>`는 다음과 같다. `MyAwaiter<T>.OnCompleted()` 함수의 구현만 변경하였다.

{% highlight csharp %}
public void OnCompleted(Action continuation)
{
    SynchronizationContext context = SynchronizationContext.Current;

    if (context == null)
    {
        task.OnTaskCompleted += continuation;
    }
    else
    {
        task.OnTaskCompleted += delegate
        {
            context.Post((object arg) => { continuation?.Invoke(); }, null);
        };
    }

    task.Start();
}
{% endhighlight %}

{% highlight log %}
ThreadID Start a = 1
ThreadID AsyncWork a = 1
ThreadID Start b = 1
ThreadID Task = 1391
value=5, ThreadID AsyncWork b = 1
{% endhighlight %}

이제 로그 `AsyncWork b`가 메인 스레드에서 실행되는 것을 확인할 수 있다.

## UniTask

마지막으로 UniTask 차례다. UniTask는 유니티를 위한 `async / await` 통합 기능을 제공한다. 사용법과 기능은 대부분 Task와 유사하나 다음과 같은 중요한 차이점이 있다.

* 기본적으로 메인 스레드에서 동작한다.
* 유니티의 Coroutine이나  Player loop와 연동하기 쉽다.

먼저 스레드 부분부터 확인해 본다. Task의 경우 `Task.Run()`를 사용해서 쉽게 작업을 스레드풀에서 실행할 수 있었지만, UniTask를 사용해서 백그라운드 스레드에서 작업을 실행하려면 다음과 같이 명시적인 함수를 사용해야 한다.

{% highlight csharp %}
private void Start()
{
    Debug.Log($"ThreadID Start = {Thread.CurrentThread.ManagedThreadId}");
    UniTask.RunOnThreadPool(() =>
    {
        Debug.Log($"ThreadID Task = {Thread.CurrentThread.ManagedThreadId}");
    }).Forget();
}
{% endhighlight %}

{% highlight log %}
ThreadID Start = 1
ThreadID Task = 17
{% endhighlight %}

백그라운드 스레드에서 실행되었다 하더라도 "일반적인" `await UniTask`를 만나면 다시 메인 스레드로 돌아온다.

{% highlight csharp %}
private void Start()
{
    Debug.Log($"ThreadID Start = {Thread.CurrentThread.ManagedThreadId}");
    UniTask.RunOnThreadPool(async () =>
    {
        Debug.Log($"ThreadID Task 1 = {Thread.CurrentThread.ManagedThreadId}");
        await UniTask.Yield();
        Debug.Log($"ThreadID Task 2 = {Thread.CurrentThread.ManagedThreadId}");
    }).Forget();
}
{% endhighlight %}

{% highlight log %}
ThreadID Start = 1
ThreadID Task 1 = 7
ThreadID Task 2 = 1
{% endhighlight %}

한편 `await` 전후로 스레드를 전환할 수 있는 기능을 제공한다.

`UniTask.SwitchToMainThread()`를 사용하면 `await` 이후의 코드를 메인 스레드에서 실행되도록 할 수 있다. 그러나 이것은 다른 "일반적인" `await UniTask`와 큰 차이는 없다.

{% highlight csharp %}
private void Start()
{
    Debug.Log($"ThreadID Start = {Thread.CurrentThread.ManagedThreadId}");
    UniTask.RunOnThreadPool(async () =>
    {
        Debug.Log($"ThreadID Task 1 = {Thread.CurrentThread.ManagedThreadId}");
        await UniTask.SwitchToMainThread();
        Debug.Log($"ThreadID Task 2 = {Thread.CurrentThread.ManagedThreadId}");
    }).Forget();
}
{% endhighlight %}

{% highlight log %}
ThreadID Start = 1
ThreadID Task 1 = 14
ThreadID Task 2 = 1
{% endhighlight %}

반대로 `UniTask.SwitchToThreadPool()`를 사용하면 `await`이후의 코드를 스레드 풀에서 실행되도록 할 수 있다.

{% highlight csharp %}
private async void Start()
{
    Debug.Log($"ThreadID Start 1 = {Thread.CurrentThread.ManagedThreadId}");
    await UniTask.SwitchToThreadPool();
    Debug.Log($"ThreadID Start 2 = {Thread.CurrentThread.ManagedThreadId}");
}
{% endhighlight %}

{% highlight log %}
ThreadID Start 1 = 1
ThreadID Start 2 = 16
{% endhighlight %}

두 번째 차이점으로 유니티와의 호환성을 확인 해 본다. 우선 다음과 같이 Coroutine이나 유니티 `Async operation`도 `await` 할 수 있게 된다. ([출처](https://github.com/Cysharp/UniTask/blob/master/README.md))

{% highlight csharp %}
var asset = await Resources.LoadAsync<TextAsset>("foo");
var txt = (await UnityWebRequest.Get("https://...").SendWebRequest()).downloadHandler.text;
await SceneManager.LoadSceneAsync("scene2");
{% endhighlight %}

유니티 Player loop 관련된 `Awaitable`도 제공한다. ([출처](https://github.com/Cysharp/UniTask/blob/master/README.md))

{% highlight csharp %}
// await frame-based operation like a coroutine
await UniTask.DelayFrame(100); 

// replacement of yield return new WaitForSeconds/WaitForSecondsRealtime
await UniTask.Delay(TimeSpan.FromSeconds(10), ignoreTimeScale: false);

// yield any playerloop timing(PreUpdate, Update, LateUpdate, etc...)
await UniTask.Yield(PlayerLoopTiming.PreLateUpdate);

// replacement of yield return null
await UniTask.Yield();
await UniTask.NextFrame();

// replacement of WaitForEndOfFrame
await UniTask.WaitForEndOfFrame();

// replacement of yield return new WaitForFixedUpdate(same as UniTask.Yield(PlayerLoopTiming.FixedUpdate))
await UniTask.WaitForFixedUpdate();
{% endhighlight %}

여기서 `UniTask.Yield()` 대신 `Task.Yield()`를 사용해도 되지 않을지 의문이 있는데, 실험해 본 결과 동작은 크게 다르지 않지만 `Task.Yield()`가 정확히 한 프레임을 기다린다는 보장은 없다. `await Task.Yield()`를 실행하면 `UnitySynchronizationContext.Post()`로 `await` 이후의 동작이 넘어가겠지만 유니티가 이것을 다음 프레임에 실행해줄지 아니면 그 다음 프레임에 실행해줄지 알 수 없다. 따라서 프레임 단위 로직을 구현하는 경우 Coroutine을 사용하거나 UniTask를 사용하는 것이 좋다.
