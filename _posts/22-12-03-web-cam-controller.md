---
title: Unity에서 디바이스 카메라 사용하기
image: /assets/post/22-12-03-web-cam-controller/title.jpg
image-source: https://pixabay.com/ko/photos/%ec%b9%b4%eb%a9%94%eb%9d%bc-%ed%95%b8%eb%93%9c%ed%8f%b0-%ea%b7%b8%eb%a6%bc-%ed%8f%ac%ec%b0%a9-1842202/
author: khlee
categories:
    - Unity
layout: post
---

## 개요

유니티에서는 디바이스 카메라(WebCam)를 제어할 수 있는 [WebCamTexture](https://docs.unity3d.com/ScriptReference/WebCamTexture.html)를 제공하는데, 프로젝트에 적용하려면 다음의 몇 가지를 직접 만들어야 한다.

* 권한 요청
    * 사용자에게 카메라 권한을 요청하고, 그 응답에 따라 처리하는 작업이다.
* 프리뷰
    * WebCamTexture 화면을 그대로 UI에 출력하면 기종이나 orientation에 따라 화면이 돌아가 있거나 뒤집혀서 나오는데 화면에 똑바로 보이도록 [WebCamTexture.videoRotationAngle](https://docs.unity3d.com/ScriptReference/WebCamTexture-videoRotationAngle.html)과 [WebCamTexture.videoVerticallyMirrored](https://docs.unity3d.com/ScriptReference/WebCamTexture-videoVerticallyMirrored.html)를 이용하여 UI의 Transform을 보정해햐 한다.
    * 프리뷰를 전체화면으로 출력하거나 일부 영역에만 출력할 수 있어야 한다.
* 캡쳐
    * 프리뷰에 보이는 카메라 이미지를 캡쳐해서 Unity의 Texture2D 또는 Sprite로 내보내는 기능이다. 이 때에도 화면의 방향과 뒤집힘을 보정해야 한다.

## WebCamController

위의 요구사항들을 만족하는 WebCamTexture의 Wrapper인 [WebCamController](https://github.com/lklab/WebCamController)를 구현하였다. 다음은 WebCamController를 사용하는 방법에 대해 서술한다.

### UI에서 프리뷰 영역 설정 

[유니티 프로젝트](https://github.com/lklab/WebCamController)에서 `SampleScene` 씬을 열면, 아래 그림과 같이 `WebCamController` 프리팹을 확인할 수 있다.

![Prefab]({{site.baseurl}}/assets/post/22-12-03-web-cam-controller/prefab.png)

이 프리팹의 `RectTransform`이 정의하는 영역이 프리뷰가 출력될 영역이다. `SampleScene` 씬에서는 전체화면으로 되어 있지만 화면의 일부 영역에만 프리뷰를 출력하도록 설정할 수 있다.

UI 상의 프리뷰 영역과 디바이스 카메라를 통해 받아온 이미지의 종횡비(Aspect ratio)가 다르다면 프리뷰 영역을 꽉 채우고 카메라 이미지의 나머지 부분은 잘리도록 되어 있다. 만약 프리뷰 영역에 빈 공간이 생기더라도 잘리지 않기를 원하면 `WebCamController` > `Viewport` > `RawImage` 게임오브젝트에 있는 `Aspect Ratio Fitter` 컴포넌트의 `Aspect Mode` 를 `Fit In Parent`로 설정하면 된다.

### WebCamController 인스펙터 설정

* `Web Cam Resolution`: 카메라의 해상도를 설정한다. 기기의 카메라에서 지원하지 않는 해상도인 경우 가장 비슷한 해상도로 설정된다. `WebCamController.StartWebCam()`의 파라미터로 해상도를 명시한 경우 이 값 대신 파라미터로 전달한 해상도가 사용된다.
* `Web Cam FPS`: 카메라의 프레임률을 설정한다. 기기의 카메라에서 지원하지 않는 프레임률인 경우 가장 비슷한 프레임률로 설정된다. `WebCamController.StartWebCam()`의 파라미터로 프레임률을 명시한 경우 이 값 대신 파라미터로 전달한 프레임률이 사용된다.
* `Use Front Facing`: 전면 카메라를 사용할지 여부를 설정한다. 만약 사용할 전면/후면 카메라가 기기에 없는 경우 `WebCamController.StartWebCam()`은 `Error.NotSupported`를 반환한다. `WebCamController.StartWebCam()`의 파라미터로 전면카메라 여부를 명시한 경우 이 값 대신 파라미터로 전달한 전면카메라 여부 값이 사용된다.
* `Auto Resize Viewport`: 기기의 회전이나 카메라 초기화/변경 등으로 카메라의 속성이 변경될 경우 이를 감지해서 자동으로 뷰포트의 크기를 조절할지 여부를 설정한다. 최적화를 위해 이 값을 `false`로 설정하고 직접 `WebCamController.Resize()`를 호출하도록 구현할 수 있다.
* `Capture Thread Count`: 캡쳐하는 경우 이미지 회전/반전을 위해 이미지 복사가 일어나는데 이를 수행할 스레드의 개수를 설정한다.

### 초기화

가장 먼저 `using LKWebCam;`를 선언한다.

그 다음에 `WebCamController` 인스턴스를 인스펙터를 통해 받아온다.

{% highlight csharp %}
[SerializeField] private WebCamController _webCamController;

{% endhighlight %}

`WebCamController.Initialize()`를 호출한다.

{% highlight csharp %}
private void Start()
{
    _webCamController.Initialize();
}

{% endhighlight %}

`WebCamController.Initialize()`는 WebCamController.Awake()에서도 호출되기 때문에 반드시 호출하지 않아도 무방하나, 스크립트 실행순서 때문에 초기화하지 않고 사용하는 것을 방지하기 위해 호출하는 것을 권장한다.

### 권한 요청

`WebCamController.RequestPermission()`을 호출한다.

{% highlight csharp %}
private void Start()
{
    _webCamController.Initialize();
    _webCamController.RequestPermission((WebCamController.Error error) =>
    {
        if (error == WebCamController.Error.Success)
        { }
    });
}

{% endhighlight %}

권한을 성공적으로 획득하면 콜백 파라미터로 `WebCamController.Error.Success`를 받아온다. 앱이 이미 권한을 갖고 있는 경우에도 콜백 파라미터로 `WebCamController.Error.Success`를 받아온다.

권한을 거부당한 경우 안드로이드에서는 콜백이 호출되지 않는다. 이는 유니티에서 사용자가 권한 요청 다어얼로그에 응답했을 때의 이벤트를 제공하지 않기 때문이다. 권한을 거부당한 경우 iOS에서는 콜백 파라미터로 `WebCamController.Error.Permission`을 받아온다.

### 프리뷰 시작

권한을 성공적으로 받아온 경우 `WebCamController.StartWebCam()`을 호출해서 프리뷰를 시작한다.

{% highlight csharp %}
private void Start()
{
    _webCamController.Initialize();
    _webCamController.RequestPermission((WebCamController.Error error) =>
    {
        if (error == WebCamController.Error.Success)
            _webCamController.StartWebCam();
    });
}

{% endhighlight %}

파라미터가 없는 `WebCamController.StartWebCam()`을 호출한 경우 다음 항목들은 인스펙터의 `WebCamController` 컴포넌트에 설정된대로 프리뷰가 시작된다.

* 전면카메라 또는 후면카메라
    * 전면카메라인 경우 자동으로 좌우반전이 적용됨
* 해상도(Resolution)
* 프레임률(FPS)

또는 다음 함수를 호출해서 위의 설정값을 직접 지정해줄 수 있다.

* `WebCamController.StartWebCam(bool useFrontFacing, Vector2Int resolution, int fps, bool flipHorizontally)`
* `WebCamController.StartWebCam(int deviceIndex, Vector2Int resolution, int fps, bool flipHorizontally)`
* `WebCamController.StartWebCam(WebCamDevice device, Vector2Int resolution, int fps, bool flipHorizontally)`

프리뷰를 더 이상 사용하지 않을 경우 `WebCamController.StopWebCam()`을 호출하면 된다.

### 캡쳐

현재 프리뷰 화면을 캡쳐하고 싶은 경우 `WebCamController.Capture()`를 호출해서 `Texture2D` 객체를 받아오면 된다.

{% highlight csharp %}
_captureButton.onClick.AddListener(delegate
{
    Texture2D texture = _webCamController.Capture();
});

{% endhighlight %}

`Sprite` 객체로 만들고 싶은 경우 다음과 같이 하면 된다.

{% highlight csharp %}
_captureButton.onClick.AddListener(delegate
{
    Texture2D texture = _webCamController.Capture();
    Sprite sprite = Sprite.Create(
        texture,
        new Rect(0.0f, 0.0f, texture.width, texture.height),
        new Vector2(0.5f, 0.5f),
        100.0f);
});

{% endhighlight %}

캡쳐된 이미지 객체의 경우 적절한 때에 `Destroy()`하지 않으면 메모리 누수가 발생한다.

{% highlight csharp %}
_captureButton.onClick.AddListener(delegate
{
    if (mCapturedImage != null)
    {
        Destroy(mCapturedImage.texture);
        Destroy(mCapturedImage);
    }

    Texture2D texture = _webCamController.Capture();
    mCapturedImage = Sprite.Create(
        texture,
        new Rect(0.0f, 0.0f, texture.width, texture.height),
        new Vector2(0.5f, 0.5f),
        100.0f);
});

{% endhighlight %}

현재 게임오브젝트에서만 캡처 이미지 객체를 사용하는 경우 `OnDestry()`에서도 이미지 객체를 `Destroy()` 한다.

{% highlight csharp %}
private void OnDestroy()
{
    if (mCapturedImage != null)
    {
        Destroy(mCapturedImage.texture);
        Destroy(mCapturedImage);
        mCapturedImage = null;
    }
}
{% endhighlight %}

`WebCamController.Capture()`는 현재 기기의 orientation과 전면 카메라 여부에 따라 rotation 및 flip을 자동으로 계산한다. 만약 해당 값들을 직접 지정하고 싶은 경우 `WebCamController.Capture(float rotationAngle, bool flipHorizontally, bool clip)` 함수를 사용하면 된다. 이 때 이미지를 회전하고 반전하는 과정에서 이미지 복사가 일어나는데, 비동기적으로 복사가 완료된 후 콜백을 받고 싶다면 `WebCamController.Capture()` 대신 `WebCamController.CaptureAsync()`를 호출하면 된다.

카메라 원본 이미지와 UI 상의 프리뷰 영역의 종횡비가 달라 원본 이미지가 잘려서 출력되는 경우 캡쳐된 이미지도 화면에 보이는 부분만 캡쳐되도록 이미지를 자른다. 만약 이미지를 자르지 않기 원하면 `clip` 파라미터를 `false` 로 설정하면 된다.

## 구현 사항

### 권한 요청

권한 요청은 `WebCamController.AcquireWebCamPermission()` 함수에서 수행한다. 크게 안드로이드 부분과 iOS 부분으로 나뉘어 있다.

Android

{% highlight csharp %}
if (Permission.HasUserAuthorizedPermission(Permission.Camera))
{
    callback?.Invoke(Error.Success);
    yield break;
}

Permission.RequestUserPermission(Permission.Camera);

while (!Permission.HasUserAuthorizedPermission(Permission.Camera))
    yield return null;

callback?.Invoke(Error.Success);
{% endhighlight %}

`Permission.HasUserAuthorizedPermission()` 함수로 권한 보유 여부를 확인하고 `Permission.RequestUserPermission()` 함수로 권한을 사용자에게 요청한다. 안드로이드에서는 권한 요청 결과를 받아오는 이벤트가 없으므로 사용자가 권한 요청을 거부한 경우 `while (!Permission.HasUserAuthorizedPermission(Permission.Camera))`에서 영원히 기다리게 된다. 대신에 `WebCamController.StopRequestPermission()` 함수로 권한 요청 코루틴을 중단시킬 수 있다.

iOS

{% highlight csharp %}
if (Application.HasUserAuthorization(UserAuthorization.WebCam))
{
    callback?.Invoke(Error.Success);
    yield break;
}

yield return Application.RequestUserAuthorization(UserAuthorization.WebCam);

if (Application.HasUserAuthorization(UserAuthorization.WebCam))
    callback?.Invoke(Error.Success);
else
    callback?.Invoke(Error.Permission);
{% endhighlight %}

`Application.HasUserAuthorization(UserAuthorization.WebCam)` 함수로 권한 보유 여부를 확인하고 `Application.RequestUserAuthorization(UserAuthorization.WebCam)` 함수로 권한을 사용자에게 요청한다.

### 카메라 시작

카메라를 시작하려면 먼저 기기에 있는 여러 개의 카메라 중 어떤 카메라를 시작할지 결정해야 한다. 구체적으로, 기기에 있는 모든 카메라를 참조하는 `WebCamTexture.devices` 배열로부터 사용할 `WebCamDevice` 객체 하나를 결정해야 한다.

만약 전면 카메라 또는 후면 카메라를 사용하려는 경우 다음과 같이 하면 된다. `useFrontFacing` 변수가 `true`면 전면 카메라가, `false`면 후면 카메라가 선택된다.

{% highlight csharp %}
WebCamDevice device = default;
bool found = false;

for (int i = 0; i < devices.Length; i++)
{
    if (useFrontFacing == devices[i].isFrontFacing)
    {
        device = devices[i];
        found = true;
        break;
    }
}

if (!found)
    return Error.NotSupported;
{% endhighlight %}

카메라를 선택했다면 `WebCamTexture` 객체를 생성하고 카메라를 시작한다.

{% highlight csharp %}
Texture = new WebCamTexture(device.name, resolution.x, resolution.y, fps);
Texture.Play();
_viewport.SetWebCamTexture(Texture);

if (_autoResizeViewport)
    _viewport.SetAutoResizingEnabled(true);

if (flipHorizontally)
    _viewport.RectTr.localScale = new Vector3(-1.0f, 1.0f, 1.0f);
else
    _viewport.RectTr.localScale = Vector3.one;

{% endhighlight %}

뷰포트 영역을 제어하는 `WebCamViewport`에 `WebCamTexture` 객체를 전달한다. 이후 `WebCamViewport` 내부의 `RawImage` 컴포넌트에서 프리뷰가 UI에 출력된다. 전면 카메라를 사용하는 등의 이유로 좌우반전이 필요하면 뷰포트의 x 스케일 값을 `-1.0f`로 설정한다.

`_autoResizeViewport`가 `true`로 설정된 경우 `WebCamViewport`의 Auto resizing 기능을 활성화해서 기기의 회전이나 카메라의 회전/반전 속성이 변경된 경우 자동으로 뷰포트를 그에 맞게 업데이트한다.

### Rotation 및 Flip

프리뷰를 올바르게 출력하려면 기기의 Orientation에 따라 카메라로 들어오는 이미지를 회전하거나 반전해야 한다. 얼마나 회전해야 하는지와 반전해야 하는지 여부는 `WebCamTexture.videoRotationAngle`과 `WebCamTexture.videoVerticallyMirrored` 값을 통해 확인할 수 있다. `WebCamController`에서는 `WebCamViewport.ResizeInternal()` 함수에 해당 기능이 구현되어 있다.

{% highlight csharp %}
/* setup params */
float rotationAngle = Texture.videoRotationAngle;
int rotationStep = Mathf.RoundToInt(rotationAngle / 90.0f);
bool isOrthogonal = (rotationStep % 2) != 0;
float scale = 1.0f;
float aspectRatio = (float)Texture.width / Texture.height;

/* rotation */
float angle = rotationStep * 90.0f;
_rawImage.transform.localRotation = Quaternion.Euler(0.0f, 0.0f, -angle);

/* size */
_aspectRatioFitter.aspectRatio = aspectRatio;

/* scale */
if (isOrthogonal)
{
    float viewportRatio = _viewport.rect.width / _viewport.rect.height;
    scale = Mathf.Max(1.0f / aspectRatio, viewportRatio);
}

/* flip */
if (Texture.videoVerticallyMirrored)
    _rawImage.transform.localScale = new Vector3(scale, -scale, scale);
else
    _rawImage.transform.localScale = new Vector3(scale, scale, scale);

{% endhighlight %}

rotation과 상하반전은 `_rawImage` 오브젝트에 적용한다. 여기서 90도 또는 270도 회전되는 경우 Viewport 크기에 맞게 `_rawImage`를 확대하거나 축소해야 한다. 이를 위해 `scale` 변수를 계산하여 적용하였다.

`WebCamViewport.ResizeInternal()` 함수는 `WebCamController` 객체의 값이 바뀔 때에만 호출되므로, 만약 UI에서 프리뷰 화면을 변경한 경우 직접 `WebCamController.Resize()` 함수를 호출해서 화면에 프리뷰가 올바르게 출력되도록 할 수 있다.

### 캡쳐

현재 프레임의 카메라 화면은 `WebCamTexture` 객체를 통해 가져올 수 있는데, 이전에 언급한 것과 같이 이미지를 회전하고 반전해야 한다. `WebCamTexture.GetPixels32()`를 통해 픽셀별 컬러를 가져온 후 회전, 반전에 따라 새로운 텍스쳐에 알맞은 컬러를 대입한다. 따라서 이미지 복사를 수행해야 하므로 스레드를 사용해서 병렬 처리하도록 되어 있다. 이 때 사용할 스레드의 개수는 인스펙터의 `WebCamController` 컴포넌트에서 `Capture Thread Count` 값으로 설정할 수 있다.

캡쳐하는 코드는 [링크](https://github.com/lklab/WebCamController/blob/master/Assets/Scripts/WebCamCaptureWorker.cs)로 첨부한다.
