---
title: 유니티에 안드로이드 네이티브 뷰 출력하기
image: /assets/post/23-03-15-native-view-on-unity/title.jpg
image-source: https://pixabay.com/ko/photos/%ea%b8%b0%ea%b3%84%ec%a0%81-%ec%9d%b8%ec%a1%b0-%ec%9d%b8%ea%b0%84-%eb%a6%ac%eb%88%85%ec%8a%a4-994910/
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

## XML 레이아웃으로 네이티브 뷰 생성하기 - 안드로이드

이번에는 좀 더 일반적인 방법인 XML로 정의된 레이아웃을 화면에 출력해볼 것이다. 우선 다음과 같이 간단하게 기능을 정의하였다.

* 유니티에서 "Show" 버튼을 클릭하면 네이티브 뷰가 출력된다.
* 유니티에서 "Hide" 버튼을 클릭하면 네이티브 뷰가 닫힌다.
* 유니티에서 "Add" 버튼을 클릭하면 네이티브 뷰에 있는 텍스트에 1을 더한다.
* 안드로이드에서 "Add" 버튼을 클릭하면 유니티 화면에 있는 텍스트에 1을 더한다.

이제 아래와 같이 레이아웃 XML을 정의하였다. 파일 이름은 `my_view.xml`이다.

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:paddingTop="50sp"
    android:background="#774AA8D8">

    <TextView
        android:id="@+id/count_text"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="android count: 0" />

    <Button
        android:id="@+id/add_unity_count"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:textAllCaps="false"
        android:text="Add unity count" />

</LinearLayout>
{% endhighlight %}

두 개의 뷰를 포함하는 `LinearLayout`으로 되어 있다. `TextView`에서는 유니티에서 "Add" 버튼을 누를 때마다 `android count: 0`의 숫자를 1씩 더할 것이고, `Button`을 누르면 유니티쪽의 텍스트에 1을 더할 것이다. 코드에서 참조할 것이므로 두 뷰에 모두 `android:id`를 정의하였다.

이제 위의 레이아웃을 제어하고, 유니티와 통신할 코드를 작성할 것이다. 먼저 생성자에서는 다음과 같이 유니티 액티비티를 전달받아 `RelativeLayout`을 생성하고 유니티 액티비티에 추가한다. 이 `RelativeLayout`에 앞서 정의한 레이아웃을 추가하고 삭제하는 동작을 구현할 것이다.

{% highlight java %}
private final Activity mContext;
private RelativeLayout mRootLayout;

public ViewController(Activity context)
{
    mContext = context;

    mContext.runOnUiThread(() -> {
        mRootLayout = new RelativeLayout(mContext);
        RelativeLayout.LayoutParams rootLayoutParams = new RelativeLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
        );
        mContext.addContentView(mRootLayout, rootLayoutParams);
    });
}
{% endhighlight %}

이제 유니티에서 호출할 두 함수 `show()`와 `hide()`를 정의한다. 각각 네이티브 뷰를 화면에 표시하거나 지우는 함수이다.

`show()` 함수에서는 유니티의 `LayoutInflater`를 통해 가져온 레이아웃을 `mRootLayout`에 추가한 후 텍스트를 초기화하고 버튼 콜백을 등록한다. `hide()` 함수에서는 `mRootLayout`에서 `show()`를 통해 만든 레이아웃을 제거한다. 이를 위해 `mMainView` 필드를 만들었고 `show()`나 `hide()`가 중복 실행되지 않도록 이 필드를 검사하도록 하였다.

버튼 콜백에서는 `UnitySendMessage()` 함수를 호출하여 유니티에 선언된 함수를 호출하도록 했다. 유니티에서는 이 함수가 호출되면 유니티쪽 텍스트 UI에 1을 더할 것이다.

{% highlight java %}
private View mMainView = null;

private TextView mCountText;
private int mCount;

public void show()
{
    mContext.runOnUiThread(() -> {
        if (mMainView != null)
            return;

        mMainView = mContext.getLayoutInflater().inflate(R.layout.my_view, mRootLayout, false);
        mRootLayout.addView(mMainView);

        mCountText = mMainView.findViewById(R.id.count_text);
        mCount = 0;
        setCountText(mCountText, mCount);

        Button addCountButton = mMainView.findViewById(R.id.add_unity_count);
        addCountButton.setOnClickListener(v -> UnityPlayer.UnitySendMessage(
                "NativeMessageReceiver",
                "AddCount",
                ""));
    });
}

public void hide()
{
    mContext.runOnUiThread(() -> {
        if (mMainView == null)
            return;

        mRootLayout.removeView(mMainView);
        mMainView = null;
    });
}
{% endhighlight %}

`setCountText()` 함수는 다음과 같다. 간단하게 텍스트 뷰의 `count` 값을 수정하는 역할을 한다.

{% highlight java %}
private void setCountText(TextView text, int count)
{
    text.setText("android count: " + count);
}
{% endhighlight %}

마지막으로 유니티에서 호출할 나머지 한 함수 `addCount()`를 선언한다. 현재 UI가 표시되고 있는 상황이어야 하므로 `mMainView` 필드를 먼저 확인한 후, `mCount` 값에 1을 더하고 이를 텍스트 뷰에 출력한다.

{% highlight java %}
public void addCount()
{
    mContext.runOnUiThread(() -> {
        if (mMainView == null)
            return;

        mCount++;
        setCountText(mCountText, mCount);
    });
}
{% endhighlight %}

[전체 코드 확인하기](https://github.com/lklab/Android-plugin-for-Unity/blob/04296477975c83bdcbe95f836b22e2f018969861/AndroidView/src/main/java/com/khlee/androidview/ViewController.java)

## XML 레이아웃으로 네이티브 뷰 생성하기 - 유니티

우선은 안드로이드에서 `UnitySendMessage()` 함수를 통해 호출될 함수부터 선언할 것이다. 아래와 같은 스크립트를 작성하고, 이름이 `NativeMessageReceiver`인 게임오브젝트의 컴포넌트로 추가해야 한다. 안드로이드에서 `AddCount` 함수가 호출되면 `OnAddCount` 이벤트가 발생하는 간단한 동작을 한다.

{% highlight csharp %}
public class NativeMessageReceiver : MonoBehaviour
{
    public static event System.Action OnAddCount;

    public void AddCount(string message)
    {
        OnAddCount?.Invoke();
    }
}
{% endhighlight %}

이제 UI를 제어하는 스크립트로 돌아와서, `Awake()`에서 이전처럼 `ViewController`의 생성자를 호출해서 객체를 생성한다. 이 부분은 앞서 작성한 코드와 동일하다.

{% highlight csharp %}
private AndroidJavaObject mViewController;

private void Awake()
{
    AndroidJavaClass unityPlayerClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
    AndroidJavaObject unityActivity = unityPlayerClass.GetStatic<AndroidJavaObject>("currentActivity");
    mViewController = new AndroidJavaObject("com.khlee.androidview.ViewController", unityActivity);
}
{% endhighlight %}

다음으로 버튼 콜백들을 등록한다. `show`, `hide`, `addCount` 각 버튼을 클릭할 때 `ViewController`의 해당 함수를 각각 호출하도록 하였다.

{% highlight csharp %}
[SerializeField] private Button _showButton;
[SerializeField] private Button _hideButton;
[SerializeField] private Button _addCountButton;

private void Awake()
{
    /* ... */

    _showButton.onClick.AddListener(delegate
    {
        mViewController.Call("show");
    });
    _hideButton.onClick.AddListener(delegate
    {
        mViewController.Call("hide");
    });
    _addCountButton.onClick.AddListener(delegate
    {
        mViewController.Call("addCount");
    });
}

{% endhighlight %}

마지막으로 유니티의 텍스트에 1을 더하는 부분을 구현할 것이다. `mCount`를 0으로 초기화한 후, 앞서 구현한 `NativeMessageReceiver`의 `OnAddCount` 이벤트에 리스너를 등록하여 `mCount`에 1을 더하고 이를 텍스트로 출력하도록 하였다.

{% highlight csharp %}
[SerializeField] private TMPro.TMP_Text _countText;

private int mCount = 0;

private void Awake()
{
    /* ... */

    mCount = 0;
    SetCountText(mCount);
    NativeMessageReceiver.OnAddCount += delegate
    {
        mCount++;
        SetCountText(mCount);
    };
}

private void SetCountText(int count)
{
    _countText.text = "unity count: " + count.ToString();
}

{% endhighlight %}

[전체 코드 확인하기](https://github.com/lklab/Native-view-on-Unity/blob/e79a3513fcdf8de0c7484841570462180d402c1d/Assets/Scripts/SampleScript.cs)

실행 영상

<iframe class="video" src="https://www.youtube.com/embed/MrYNGZZ8MDI" allowfullscreen frameborder="0"></iframe>
