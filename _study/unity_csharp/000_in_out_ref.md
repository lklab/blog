---
title: in, out, ref
image: /assets/study/unity_csharp/000_in_out_ref/in_out_ref.png
author: khlee
layout: post
last_modified_at: 2024-01-20
---

## 개요

`in`, `out`, `ref` 키워드는 모두 함수 파라미터에 사용되며 해당 파라미터가 call by reference로 함수에 전달되도록 하는 방법이다.

refernce type 변수는 어차피 call by reference로 전달되니 큰 의미는 없지만(의미가 아예 없는 것은 아니다. 함수 내부에서 그 변수에 새로운 객체를 할당하면 함수 밖에서는 그 새로운 객체를 가리키게 된다.), 큰 struct를 전달해야 할 때에는 불필요한 값 복사를 줄이기 위해 call by reference로 전달하는 것이 유용하다.

## ref

함수 파라미터에 `ref`를 사용하면 value type의 변수라도 call by reference로 함수에 전달된다.

## out

`out`은 `ref`와 거의 동일하지만 다음과 같은 차이점이 있다.

* `out`으로 함수에 전달할 변수는 함수 호출 전에 초기화 할 필요가 없다.
* 함수는 `out`으로 받은 파라미터를 반드시 그 값을 지정해야 한다.

`return`처럼 함수의 결과를 함수를 호출한 쪽으로 전달하는 용도로 사용된다.

## in

`in`은 `out`과 반대로 함수를 호출한 쪽에서 함수로 값을 전달하는 용도로 사용된다. 가장 중요한 차이점은 함수는 `in`으로 받은 파라미터의 값을 변경할 수 없다는 것이다.

그러나 파라미터의 타입이 클래스인 경우 재할당은 불가능하지만 값을 변경할 수는 있다.

{% highlight csharp %}
public class Student
{
    public int id;

    public Student(int id)
    {
        this.id = id;
    }
}

private void MyFunction(in Student student)
{
    student = new Student(2); // compile error!
    student.id = 2; // OK..!
}
{% endhighlight %}

파라미터의 타입이 구조체라면 값에 직접 접근해서 변경하는 것도 불가능해진다.

{% highlight csharp %}
public struct Student
{
    public int id;

    public Student(int id)
    {
        this.id = id;
    }
}

private void MyFunction(in Student student)
{
    student = new Student(2); // compile error!
    student.id = 2; // compile error too!
}
{% endhighlight %}

그러나 값을 변경하는 함수는 여전히 호출 가능한데, 신기하게도 함수 외부에서는 그 변경사항이 반영되지 않는다.

{% highlight csharp %}
public struct Student
{
    public int id;

    public Student(int id)
    {
        this.id = id;
    }

    public void SetID(int id)
    {
        this.id = id;
    }
}

private void Awake()
{
    Student student = new Student(1);
    MyFunction(student);
    Debug.Log($"student id={student.id}"); // result: student id=1
}

private void MyFunction(in Student student)
{
    student.SetID(2); // OK!
}
{% endhighlight %}

위의 코드에서 구조체를 클래스로 변경하면 함수 외부에서 변경사항이 반영된다.

{% highlight csharp %}
public class Student
{
    public int id;

    public Student(int id)
    {
        this.id = id;
    }

    public void SetID(int id)
    {
        this.id = id;
    }
}

private void Awake()
{
    Student student = new Student(1);
    MyFunction(student);
    Debug.Log($"student id={student.id}"); // result: student id=2
}

private void MyFunction(in Student student)
{
    student.SetID(2); // OK!
}
{% endhighlight %}

`in` 파라미터는 C# 설계랑 뭔가 안 맞는 느낌이다. 그냥 구조체를 받는 함수에서 call by reference로 받고 싶은데 함수 내부에서 해당 구조체를 변경하지 않는다는 것을 함수를 사용하는 쪽에 알리고 싶을 때 사용하면 좋을 것 같다.
