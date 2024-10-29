---
title: Lazy&lt;T&gt;, AsyncLazy&lt;T&gt;
image: /assets/study/unity_csharp/001_lazy_asynclazy/lazy_asynclazy.png
author: khlee
layout: post
last_modified_at: 2024-01-22
---

## 개요

`Lazy<T>`와 `AsyncLazy<T>`는 모두 지연된 초기화를 구현할 때 사용된다. 특정 객체가 필요해지는 시점에 초기화하도록 해서 리소스를 절약할 수 있다. 또 다른 강력한 특징으로, thread-safe하기 때문에 여러 스레드에서 동일한 객체에 접근해도 객체가 초기화됨을 보장한다.

## Lazy&lt;T&gt;

다음과 같이 `Lazy<T>` 객체를 생성할 수 있다.

{% highlight csharp %}
Lazy<Student> student = new Lazy<Student>(() => new Student(1));
{% endhighlight %}

`Lazy<T>`의 생성자의 파라미터로 `Student` 객체의 팩토리 함수가 전달된다.

다음과 같이 `Student` 객체를 가져올 수 있다.

{% highlight csharp %}
Student s = student.Value;
{% endhighlight %}

앞서 전달한 팩토리 함수는 이 시점에 실행된다.

## AsyncLazy&lt;T&gt;

객체를 생성할 때(초기화할 때) 네트워크를 사용해야 한다는 등의 이유로 시간이 걸릴 수 있다. 이럴 때에는 `Lazy<T>`보다 `AsyncLazy<T>`가 더 유용하다. `AsyncLazy<T>` 객체는 다음과 같이 생성할 수 있다.

{% highlight csharp %}
AsyncLazy<Student> student = new AsyncLazy<Student>(() => UniTask.Create(async () =>
{
    await UniTask.Delay(1000);
    return new Student(2);
}));
{% endhighlight %}

`Lazy<T>`와 다르게 `AsyncLazy<T>`의 팩토리 함수는 `UniTask<T>`를 반환해야 한다는 것을 알 수 있다. (참고: `AsyncLazy<T>`는 [UniTask](https://github.com/Cysharp/UniTask) 패키지에 포함되어 있다.) 여기서는 시간이 걸리는 것을 표현하기 위해 1초 기다리도록 했다.

이번에는 다음과 같이 `Student` 객체를 가져올 수 있다.

{% highlight csharp %}
Student s = await student;
{% endhighlight %}

다음과 같이 await가 여러 번 호출되거나, 이미 초기화 된 객체를 가져오는 것도 정상적으로 동작한다. 단, 이미 초기화 된 객체를 가져올 때에는 팩토리 함수가 실행되지 않고 이미 생성된 객체를 바로 받아올 수 있다.

{% highlight csharp %}
private async void Start()
{
    AsyncLazy<Student> student = new AsyncLazy<Student>(() => UniTask.Create(async () =>
    {
        await UniTask.Delay(1000);
        return new Student(2);
    }));

    GetStudent(student);
    Student s1 = await student; // await 중복 실행!
    Student s2 = await student; // 이미 초기화된 시점
}

private async void GetStudent(AsyncLazy<Student> student)
{
    Student s = await student;
}
{% endhighlight %}
