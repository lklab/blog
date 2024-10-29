---
title: Sentis
image: /assets/study/unity_csharp/004_sentis/title.jpg
author: khlee
layout: post
last_modified_at: 2024-07-25
---

## 개요

[U Day Seoul 2024 Unity Sentis 상세 기술 설명과 게임 콘텐츠 적용 튜토리얼](https://youtu.be/4cWTprKV3WE) 영상을 보고 Unity Sentis에 대해 정리한 내용이다.

## Unity Sentis란?

* 딥러닝 모델의 추론을 플랫폼 독립적인 코드로 구현할 수 있게 함
* 서버와 통신하지 않아도 되는 온디바이스 인퍼런스(추론) 엔진을 제공
* 호환성이 높은 Open Neural Network Exchange (ONNX) 포맷을 사용
* 다양한 Pre-trained 모델과 C# 샘플 코드 제공

![Sentis의 역할]({{site.baseurl}}/assets/study/unity_csharp/004_sentis/2024-06-18-082359.png)
*Sentis는 런타임에 온디바이스 추론 기능을 제공한다.*{: .custom-caption}

![Hugging face에서 제공하는 모델들]({{site.baseurl}}/assets/study/unity_csharp/004_sentis/2024-06-18-082730.png)
![Hugging face에서 제공하는 모델들]({{site.baseurl}}/assets/study/unity_csharp/004_sentis/2024-06-18-082808.png)
*Hugging face에서 다양한 pre-trained 모델을 제공한다.*{: .custom-caption}

## Sentis 사용 방법

![Sentis 사용 방법]({{site.baseurl}}/assets/study/unity_csharp/004_sentis/2024-06-18-082853.png)

1. AI 모델 선택
2. Unity로 임포트 및 최적화
3. 추론 코드 작성
4. 런타임 플랫폼에 배포

## 1. AI 모델 선택

![AI 모델 선택]({{site.baseurl}}/assets/study/unity_csharp/004_sentis/2024-06-18-083024.png)

ONNX 파일이란?
> ONNX는 Open Neural Network Exchange의 약자로 서로 다른 ML 프레임워크에서 개발된 모델을 서로 호환할 수 있도록 하는 표준 모델 포맷입니다. ONNX는 Meta와 MicroSoft가 주도하여 개발한 오픈 소스 표준으로, 현재는 여러 회사와 연구 기관이 참여하여 공동으로 개발하고 있습니다. PyTorch나 TensorFlow와 같은 다양한 ML 프레임워크와 NVIDIA의 Jetson 플랫폼에서 적극적으로 지원되는 등 다양한 곳에서 활용도가 높아져 사실상 AI 모델 표준으로 인정받고 있습니다.

## 2. Unity로 임포트 및 최적화

Drag & Drop!하면 됨. 단, Sentis에서 모델에 있는 모든 ONNX operators를 지원해야 함. [참고](https://docs.unity3d.com/Packages/com.unity.sentis@1.5/manual/supported-operators.html)

모델 직렬화

* .onnx 모델을 .sentis 모델로 변환
* Unity에서 잘 작동하는지 검증
* 용량이 큰 파일일 경우 용량이 절약됨
* 로딩 시간이 단축됨
* Model 선택 -> Inspector -> Serialize To StreamingAssets -> StreamingAssets 폴더에 .sentis 파일이 저장됨

모델 양자화

* FP32 (4 bytes) -> FP16 (2 bytes) -> INT8 (1 byte)

![모델 양자화]({{site.baseurl}}/assets/study/unity_csharp/004_sentis/2024-06-18-084107.png)

위 그림을 보면 FP32와 FP16은 큰 차이가 없는데 INT8과는 차이가 많이 나는 것을 알 수 있다. 따라서 FP16을 사용해서 모델이 차지하는 용량을 반으로 줄일 수 있고, 상황에 따라서 정확도보다 용량 최적화가 더 중요한 경우에는 INT8을 사용하기로 결정할 수도 있다.

## 3. 추론 코드 작성

![추론 코드 작성]({{site.baseurl}}/assets/study/unity_csharp/004_sentis/2024-06-18-084301.png)

* `Unity.Sentis` 네임스페이스를 사용
* `ModelLoader.Load()` 함수를 통해 모델을 로드할 수 있음
* `WorkerFactory.CreateWorker()` 함수를 통해 추론 엔진을 생성할 수 있음
  * 이 때 GPU에서 실행할지 CPU에서 실행할지 또는 compute shader를 사용할지 결정할 수 있음
* 모델의 입력을 `Tensor`로 생성
  * 입력이 여러개라면 위 코드와 같이 `Dictionary`를 사용할 수 있음
* `IWorker.Execute()` 함수를 통해 추론 엔진 실행
* `IWorker.PeekOutput()` 함수를 통해 추론 결과를 가져올 수 있음
  * 이 때 비동기로 수행할지 아니면 추론이 완전히 끝날 때까지 기다릴지 선택 가능
* 더 이상 모델이 필요하지 않은 경우 `IWorker.Dispose()` 함수 호출

## 4. 런타임 플랫폼에 배포

그냥 빌드하면 됨!

## Hand landmark 모델로 Sentis 사용해 보기

[Hand landmark](https://huggingface.co/unity/sentis-hand-landmark) 모델을 선택했으며, 다음과 같이 사용 방법이 잘 나와 있다.

![Hand landmark 모델 사용 방법]({{site.baseurl}}/assets/study/unity_csharp/004_sentis/2024-06-18-084632.png)

다음과 같이 모델을 임포트하고 적용한다.

![모델 임포트 및 적용]({{site.baseurl}}/assets/study/unity_csharp/004_sentis/2024-06-18-084759.png)

* Run Hand Landmark 스크립트를 메인 카메라에 추가
* Asset 필드에 모델 에셋 (.onnx 파일 또는 .sentis 파일) 지정
* 디바이스 카메라를 사용하기 위해 Input Type을 Webcam으로 설정

스크립트에서 다음과 같이 초기화를 진행한다.

{% highlight csharp %}
void SetupInput()
{
    switch (inputType)
    {
        case InputType.Webcam:
            {
                webcam = new WebCamTexture(deviceName, resolution.x, resolution.y);
                webcam.requestedFPS = 30;
                webcam.Play();
                break;
            }
        case InputType.Video:
            // ...
        default:
            // ...
    }
}

void SetupModel()
{
    model = ModelLoader.Load(asset);
}

public void SetupEngine()
{
    worker = WorkerFactory.CreateWorker(backend, model);
}
{% endhighlight %}

이제 추론을 위한 입력을 준비한다. 먼저 `WebCamTexture`를 비율에 맞춰서 정사각형 `targetTexture`로 복사한다.

{% highlight csharp %}
var aspect1 = (float)video.width / video.height;
var aspect2 = (float)resolution.x / resolution.y;
var gap = aspect2 / aspect1;

var vflip = false;
var scale = new Vector2(gap, vflip ? -1 : 1);
var offset = new Vector2((1 - gap) / 2, vflip ? 1 : 0);
Graphics.Blit(video.texture, targetTexture, scale, offset);
{% endhighlight %}

추론 엔진은 `Tensor`를 받아야 하므로 `TextureTransform`을 이용하여 `targetTexture`를 `Tensor`로 변환한다.

{% highlight csharp %}
var transform = new TextureTransform();
transform.SetDimensions(size, size, 3);
transform.SetTensorLayout(0, 1, 2, 3);
using var image = TextureConverter.ToTensor(source, transform);
{% endhighlight %}

이 때 `size` 값이 모델의 입력과 맞아야 하는데 [Netron](https://github.com/lutzroeder/netron)을 사용하면 다음 그림과 같이 모델의 입출력 형태를 확인할 수 있다.

![모델 출력 부분]({{site.baseurl}}/assets/study/unity_csharp/004_sentis/2024-06-18-085808.png)
![모델 입력 부분]({{site.baseurl}}/assets/study/unity_csharp/004_sentis/2024-06-18-085831.png)
{: .custom-disable-p-align}

이제 `IWorker.Execute()` 함수를 통해 추론 엔진을 실행한다.

{% highlight csharp %}
worker.Execute(image);
{% endhighlight %}

그 후 추론 출력값을 가져온다.

{% highlight csharp %}
using var landmarks = worker.PeekOutput("Identity") as TensorFloat;

ClearAnnotations();

Vector2 markerScale = previewUI.rectTransform.rect.size/ size;
landmarks.CompleteOperationsAndDownload();
DrawLandmarks(landmarks, markerScale);

using var A = worker.PeekOutput("Identity_1") as TensorFloat;
using var B = worker.PeekOutput("Identity_2") as TensorFloat;
A.CompleteOperationsAndDownload();
B.CompleteOperationsAndDownload();
debugText.text = $"Identity_1: {A[0, 0]}\nIdentity_2: {B[0, 0]}";
{% endhighlight %}

출력값 `Identity`는 hand landmarks의 위치를 의미하고 그 외에 `Identity_1` 등은 출력해 보니 정확도를 의미하는 것으로 추정된다. `Identity_2`는 왼손/오른손 구분이라고 한다.
