---
title: 유니티에 안드로이드 네이티브 뷰 출력하기
image: /assets/post/22-12-29-mlkit-face-detection/title.png
image-source: https://pixabay.com/ko/vectors/%ed%8f%89%ed%8f%89%ed%95%9c-%ec%9d%b8%ec%8b%9d-%ec%96%bc%ea%b5%b4-%eb%a7%88%ec%82%ac%ec%a7%80-3252983/
author: khlee
categories:
    - Unity
layout: post
---

## 안드로이드 플러그인 프로젝트 만들기

먼저 다음 문서들을 참고해서 유니티에 적용할 수 있는 안드로이드 플러그인 프로젝트를 생성한다.

* [Android 라이브러리 만들기](https://developer.android.com/studio/projects/android-library?hl=ko)
* [[Unity] 안드로이드 플러그인 (Android Plugin JAR, AAR)](https://mrw0119.tistory.com/147)
* [[Unity][AOS] Creating an Android Plugin for Unity (1/2)](https://velog.io/@koo00/5)
* [안드로이드 Unity 플러그인 만들기](https://jizard.tistory.com/365)
* [Unity)Android Native Plugin (ARR 만들기)](https://drehzr.tistory.com/1368)

한 문서만 봐도 좋고, 여러 문서들을 서로 교차검증하면 더 좋다. 어쨋든 목적은 유니티 프로젝트에 적용할 AAR을 만드는 것이다.

## 코드로 네이티브 뷰 생성하기 - 안드로이드

안드로이드 프로젝트에서 `ViewController` 클래스를 만들고 생성자를 다음과 같이 작성한다.

{% highlight java %}
private final Activity mContext;
private LinearLayout mLayout;
private LinearLayout.LayoutParams mLayoutParams;

public ViewController(Activity context)
{
    mContext = context;

    mContext.runOnUiThread(() -> {
        mLayout = new LinearLayout(mContext);
        mLayout.setOrientation(LinearLayout.VERTICAL);

        mLayoutParams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
        );

        mContext.addContentView(mLayout, mLayoutParams);
    });
}
{% endhighlight %}

유니티에서 생성자를 직접 호출해서 `context`를 네이티브에 전달할 것이다. `context`는 유니티 액티비티로, 앞으로 뷰를 생성하고 제어할 때 활용할 것이므로 필드에 저장한다. 유니티에서 네이티브 함수를 호출하는 경우 UI 스레드에서 실행되지 않는 모양이다. 그래서 `runOnUiThread()` 내에서 뷰를 생성해야 한다. 먼저 root가 될 `LinearLayout`을 생성하고 `LayoutParams`을 통해 부모 레이아웃과의 관계를 설정한 후 `addContentView()`를 호출하여 유니티 액티비티에 레이아웃을 추가한다.

다음으로 버튼을 추가해볼 것이다.

{% highlight java %}
public void show()
{
    mContext.runOnUiThread(new Runnable() {
        @Override
        public void run() {
            Button button = new Button(mContext);
            button.setText("This is button");
            button.setLayoutParams(mLayoutParams);
            mLayout.addView(button);
        }
    });
}
{% endhighlight %}

`Button` 객체를 생성한 후 생성자에서 만든 레이아웃인 `mLayout`에 추가하면 된다. `show()` 함수가 호출될 때마다 레이아웃에 버튼이 차례대로 추가될 것이다.

[전체 코드 확인하기](https://github.com/lklab/Android-plugin-for-Unity/blob/4a1685e16b9caaa036e56f3904d09cf3d6c4c92b/AndroidView/src/main/java/com/khlee/androidview/ViewController.java)

## 코드로 네이티브 뷰 생성하기 - 유니티

유니티에서는 간단하게 (유니티쪽의) 버튼을 누르면 네이티브의 `show()` 함수를 호출하는 구조로 만들 것이다.

{% highlight csharp %}
[SerializeField] private Button _button;

private AndroidJavaObject mViewController;

private void Awake()
{
    AndroidJavaClass unityPlayerClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
    AndroidJavaObject unityActivity = unityPlayerClass.GetStatic<AndroidJavaObject>("currentActivity");
    mViewController = new AndroidJavaObject("com.khlee.androidview.ViewController", unityActivity);

    _button.onClick.AddListener(delegate
    {
        mViewController.Call("show");
    });
}
{% endhighlight %}

먼저 `ViewController`의 생성자로 전달할 유니티 액티비티를 받아온다. 

{% highlight csharp %}
AndroidJavaClass unityPlayerClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
AndroidJavaObject unityActivity = unityPlayerClass.GetStatic<AndroidJavaObject>("currentActivity");
{% endhighlight %}

`new AndroidJavaObject()`를 통해 `ViewController`의 생성자를 호출해서 객체를 생성한다. 첫 번째 파라미터로는 패키지 경로를 포함한 전체 클래스명을 적어주면 된다. 두 번째 파라미터로 앞서 가져온 유니티 액티비티를 전달한다.

{% highlight csharp %}
mViewController = new AndroidJavaObject("com.khlee.androidview.ViewController", unityActivity);
{% endhighlight %}

마지막으로 버튼 콜백에서 `ViewController`의 `show()`를 호출한다.

{% highlight csharp %}
_button.onClick.AddListener(delegate
{
    mViewController.Call("show");
});

{% endhighlight %}

[전체 코드 확인하기](https://github.com/lklab/Native-view-on-Unity/blob/3c5819dcd6be29f5618ea2f31b06cc0b16d6ce72/Assets/Scripts/SampleScript.cs)

실행 영상

<iframe class="video" src="https://www.youtube.com/embed/mHfiqGChUyY" allowfullscreen frameborder="0"></iframe>







































