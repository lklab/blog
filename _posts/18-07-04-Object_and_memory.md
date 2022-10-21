---
title: JNI 객체 사용과 메모리 관리
image: /assets/post/18-07-04-Object_and_memory/title.jpeg
author: khlee
categories:
    - JNI
layout: post
---

## 개요

JNI를 통해 C에서 Java의 객체에 접근할 수 있고 자유롭게 생성할 수 있다. 그러나 C에서 접근했거나 생성한 객체가 여전히 C에서 참조를 갖고 있는지 알 수 없으므로, garbage collector가 이러한 객체를 어떻게 처리할지 알 수 없게 된다. 이를 위해 JNI는 C에서 해당 객체에 대한 참조를 명시적으로 제거할 수 있는 함수를 제공하여 garbage collector가 잘 동작할 수 있도록 메커니즘이 마련되어 있다.

이번 글에서는 C에서 Java 객체를 사용하는 방법과, 메모리 관리 방법을 소개한다.

## 참고 자료

[The Java Native Interface: Programmer's Guide and Specification](https://www.uni-ulm.de/fileadmin/website_uni_ulm/iui.inst.200/files/staff/domaschka/misc/jni_programmers_guide_spec.pdf)

## String

C에서 String을 처리할 수 있는 함수는 다음과 같다.

![string functions]({{site.suburl}}/assets/post/18-07-04-Object_and_memory/string.png)

다음과 같이 사용할 수 있다.

Hello.java

{% highlight java %}
public class Hello
{
    public native String getText(String message);
}
{% endhighlight %}

hello.c

{% highlight c %}
JNIEXPORT jstring JNICALL
Java_Hello_getText(JNIEnv *env, jobject obj, jstring message)
{
    char buff[255];
    const char *msg;

    /* get string from java String object */
    msg = (*env)->GetStringUTFChars(env, message, NULL);
    if(msg == NULL)
        return NULL; /* OutOfMemoryError already thrown */

    printf("received from java : %s\n", msg);

    /* free the memory allocated for msg */
    (*env)->ReleaseStringUTFChars(env, message, msg);

    scanf("%s", buff);

    /* create java String object */
    return (*env)->NewStringUTF(env, buff);
}
{% endhighlight %}

Java String은 `GetStringUTFChars()` 함수를 통해 C 문자열(캐릭터의 배열)로 가져올 수 있다.<br>
가져온 문자열은 사용이 모두 끝난 후에 `ReleaseStringUTFChars()` 함수를 통해 할당된 메모리 영역을 반환해야 한다.

C 문자열로부터 `NewStringUTF()` 함수를 통해 java String 객체를 생성할 수 있다.<br>
이를 통해 생성된 객체는 전적으로 java에서만 사용되는 것으로 간주되며, C에서 참조를 갖고 있더라도 garbage collector가 이를 확인하지 않으므로, java에서의 참조만 없다면 해당 객체는 제거될 수 있다.

## Object construction

객체를 생성하는 순서는 다음과 같다.
1. 생성할 객체의 class를 얻는다.
2. 생성자(constructor)를 얻는다.
3. 생성자 매개변수와 함께 객체를 생성한다.

다음은 사용 예이다.

{% highlight c %}
JNIEXPORT jobject JNICALL
Java_Hello_getObject(JNIEnv *env, jobject obj)
{
    jClass class;
    jmethodID constructor;
    int parameter = 1;
    jobject result;

    /* get class */
    class = (*env)->FindClass(env, "java/lang/Integer");
    if(class == NULL)
        return NULL;

    /* get constructor */
    constructor = (*env)->GetMethodID(env, class, "<init>", "(I)V");
    if(constructor == NULL)
        return NULL;

    /* construct object */
    result = (*env)->NewObject(env, class, constructor, parameter);

    return result;
}
{% endhighlight %}

`FindClass()` 함수를 통해 특정 클래스를 얻어올 수 있다. 두 번째 매개변수로 얻어올 클래스의 패키지 경로를 포함한 전체 이름을 적는다.

`GetMethodID()` 함수는 특정 클래스의 메소드를 얻어오는 함수이다. 원래 세 번째 매개변수에는 메소드의 이름, 네 번째 매개변수에는 메소드의 시그니처를 넣어야 하지만, 생성자를 얻어올 경우 메소드의 이름을 `<init>`으로, 시그니처의 반환 타입은 `void`를 의미하는 `V`로 고정해야 한다.

메소드 시그니처는 메소드의 반환 타입과 매개변수들의 타입을 문자열로 정의한 것으로 "({매개변수}){반환타입}" 형식이다.

각각 java 타입에 해당하는 시그니처는 다음과 같다.

| Type | Signature |
|:-----:|:-----:|
| void | V |
| boolean | Z |
| byte | B |
| char | C |
| int | I |
| long | J |
| float | F |
| double | D |
| object | L{패키지 경로를 포함한 클래스 전체 이름}; |
| type\[\] | [{해당 타입의 시그니처} |

예를 들어서

{% highlight text %}
void aaa() -> ()V
int bbb(boolean a, char, b) -> (ZC)I
String[] ccc(int[] c, MyClass d) -> ([ILmyPackage/MyClass;)[Ljava/lang/String;
{% endhighlight %}

이 된다.

마지막으로 `NewObject()` 함수를 통해 해당 객체를 생성한다. 4번째 파라미터부터는 지정된 생성자의 파라미터로 사용될 변수를 순서대로 넣으면 된다. 만약 생성자의 파라미터가 두 개라면 4번째 파라미터에 생성자의 1번째 파라미터, 5번째 파라미터에 생성자의 2번째 파라미터를 넣으면 된다.

## Array

다음은 배열을 처리하는 함수들이다.

![array functions]({{site.suburl}}/assets/post/18-07-04-Object_and_memory/array.png)

`<Type>`에 원하는 배열 타입을 입력하면 된다. 예를 들어 int 배열을 생성하고 싶은 경우 `NewIntArray()` 함수를 사용한다.

`Get<Type>ArrayRegion()` 함수와 `Get<Type>ArrayElements()` 함수는 모두 배열의 값을 얻어올 수 있다는 공통점이 있지만 사용 방법이 다르다.

`Get<Type>ArrayRegion()` 함수는 다음과 같이 얻어올 메모리 영역이 미리 확보되어 있을 때 사용한다.

{% highlight c %}
JNIEXPORT jint JNICALL
Java_Hello_sumArray(JNIEnv *env, jobject obj, jintArray arr)
{
    int buf[10];
    int i, sum = 0;

    /* get int array data */
    (*env)->GetIntArrayRegion(env, arr, 0, 10, buf);

    for(i = 0; i < 10; i++)
        sum += buf[i];

    return sum;
}
{% endhighlight %}

반면 `Get<Type>ArrayElements()` 함수는 메모리 영역이 확보된 배열 포인터를 반환한다. 따라서 해당 포인터를 모두 사용하고 난 다음에는 `Release<Type>ArrayElements()` 함수를 통해 해당 메모리 영역을 반환해야 한다.

{% highlight c %}
JNIEXPORT jint JNICALL
Java_Hello_sumArray(JNIEnv *env, jobject obj, jintArray arr)
{
    int *buf;
    int i, sum = 0;

    /* get int array data */
    buf = (*env)->GetIntArrayElements(env, arr, NULL);
    if(buf == NULL)
        return 0;

    for(i = 0; i < 10; i++)
        sum += buf[i];

    /* release int array memory */
    (*env)->ReleaseIntArrayElements(env, arr, buf, 0);

    return sum;
}
{% endhighlight %}

## DeleteLocalRef()

만약 C에서 객체를 생성하였는데, Java로 반환되지도 않고 더 이상 사용되지 않는다면 `DeleteLocalRef()` 함수를 통해 반드시 해당 객체에 대한 참조를 지워야 한다.

예를 들어 다음과 같이 object array를 만드는 경우에 배열의 각 요소는 배열에 넣은 후 반환되지 않고 더 이상 사용되지 않는다. 이 때 `DeleteLocalRef()` 함수를 호출해야 한다.

{% highlight c %}
JNIEXPORT jobjectArray JNICALL
Java_Hello_getNameList(JNIEnv *env, jobject obj)
{
    int i;
    char buf[255];
    jstring name;

    jclass stringClass;
    jobjectArray nameList;

    /* construct String array */
    stringClass = (*env)->FindClass(env, "java/lang/String");
    if(stringClass == NULL)
        return NULL;

    nameList = (*env)->NewObjectArray(env, 10, stringClass, NULL);
    if(nameList == NULL)
        return NULL;

    printf("enter 10 names\n");
    for(i = 0; i < 10; i++)
    {
        scanf("%s", buf);

        /* construct new String */
        name = (*env)->NewStringUTF(env, buf);
        if(name == NULL)
            return NULL;

        /* insert String to array */
        (*env)->SetObjectArrayElement(env, nameList, i, (jobject)name);

        /* delete local reference */
        (*env)->DeleteLocalRef(env, name);
    }

    return nameList;
}
{% endhighlight %}
