---
title: ML Kit를 사용해서 실시간으로 얼굴 인식(Face detection)
image: /assets/post/22-12-29-mlkit-face-detection/title.png
image-source: https://pixabay.com/ko/vectors/%ed%8f%89%ed%8f%89%ed%95%9c-%ec%9d%b8%ec%8b%9d-%ec%96%bc%ea%b5%b4-%eb%a7%88%ec%82%ac%ec%a7%80-3252983/
author: khlee
categories:
    - Machine Learning
layout: post
---

## 개요

안드로이드 플랫폼에서 Google ML Kit을 사용해서 카메라로 들어오는 이미지의 얼굴을 실시간으로 인식할 것이다.

다음과 같은 순서로 진행한다.

* [CameraX Codelab](https://developer.android.com/codelabs/camerax-getting-started)을 순서대로 따라해서 카메라를 통해 촬영되는 이미지를 화면에 띄우는 앱을 만든다.
* 앞서 만든 앱에 [ML Kit 얼굴인식 문서](https://developers.google.com/ml-kit/vision/face-detection/android)를 보고 ML Kit를 적용한다.
* [ML Kit 얼굴인식 Codelab](https://codelabs.developers.google.com/codelabs/mlkit-android#1)에서 제공하는 샘플 프로젝트의 `GraphicOverlay` 클래스를 가져와서 카메라 화면의 얼굴에 사각형을 오버레이한다.

## 카메라 프리뷰 앱 만들기

[CameraX Codelab](https://developer.android.com/codelabs/camerax-getting-started)의 1, 2, 3, 4, 6번을 순서대로 진행한다. 원한다면 이미지 캡쳐와 비디오 캡쳐도 진행해도 된다. 그러나 여기서는 해당 기능들을 다루지 않을 것이다.

## ML Kit를 적용하기

[ML Kit 얼굴인식 문서](https://developers.google.com/ml-kit/vision/face-detection/android)에 따라 진행한다.

모듈의 `build.gradle` 파일에 다음과 같이 ML Kit Android 라이브러리의 종속 항목을 추가한다.

{% highlight gradle %}
dependencies {
    // ...

    implementation 'com.google.mlkit:face-detection:16.1.5'
}
{% endhighlight %}

`FaceDetectAnalyzer` 클래스를 `MainActivity.kt`에 내부 클래스로 선언한다.

{% highlight kotlin %}
private class FaceDetectAnalyzer() : ImageAnalysis.Analyzer
{
    @OptIn(ExperimentalGetImage::class)
    override fun analyze(imageProxy: ImageProxy)
    {
        val mediaImage = imageProxy.image
        if (mediaImage != null)
        {
            val image = InputImage.fromMediaImage(mediaImage, imageProxy.imageInfo.rotationDegrees)

            val detector = FaceDetection.getClient()
            val result = detector.process(image)
                .addOnSuccessListener { faces ->
                    imageProxy.close()
                    Log.d("@@@", "OnSuccess")
                }
                .addOnFailureListener {
                    imageProxy.close()
                    Log.d("@@@", "OnFailure")
                }
        }
    }
}
{% endhighlight %}

`startCamera()` 함수의 Analyzer를 등록하는 부분에서 기존 예제에서 작성했던 `LuminosityAnalyzer` 클래스를 `FaceDetectAnalyzer`로 교체한다.

{% highlight kotlin %}
private fun startCamera() {
    val cameraProviderFuture = ProcessCameraProvider.getInstance(this)

    cameraProviderFuture.addListener({
        // ...

        val imageAnalyzer = ImageAnalysis.Builder()
            .build()
            .also {
                it.setAnalyzer(cameraExecutor, FaceDetectAnalyzer())
            }

        // ...

    }, ContextCompat.getMainExecutor(this))
}
{% endhighlight %}

## 카메라 화면의 얼굴에 사각형을 오버레이하기

[ML Kit 얼굴인식 Codelab](https://codelabs.developers.google.com/codelabs/mlkit-android#1)에서 제공하는 샘플 프로젝트의 `GraphicOverlay` 클래스를 프로젝트로 가져온다. 나는 가져온 후 kotlin으로 변환했지만 그대로 사용해도 괜찮을 것이다.

{% highlight kotlin %}
package com.your.package

import android.content.Context
import android.graphics.Canvas
import android.hardware.camera2.CameraCharacteristics
import android.util.AttributeSet
import android.view.View

import kotlin.collections.MutableSet
import kotlin.collections.HashSet

class GraphicOverlay(context: Context, attrs: AttributeSet) : View(context, attrs)
{
    private val lock: Any = Object()
    private var previewWidth: Int = 0
    private var offsetX: Int = 0
    private var previewHeight: Int = 0
    private var scaleFactor: Float = 1.0f
    private var offsetY: Int = 0
    private var facing: Int = CameraCharacteristics.LENS_FACING_BACK
    private var graphics: MutableSet<Graphic> = HashSet()

    abstract class Graphic(private var overlay: GraphicOverlay)
    {
        abstract fun draw(canvas: Canvas)

        fun scaleX(horizontal: Float) = horizontal * overlay.scaleFactor
        fun scaleY(vertical: Float) = vertical * overlay.scaleFactor

        val applicationContext: Context = overlay.context.applicationContext

        fun translateX(x: Float): Float
        {
            return if (overlay.facing == CameraCharacteristics.LENS_FACING_FRONT)
                overlay.width - (scaleX(x) + overlay.offsetX)
            else
                scaleX(x) + overlay.offsetX
        }

        fun translateY(y: Float) = scaleY(y) + overlay.offsetY

        fun postInvalidate()
        {
            overlay.postInvalidate()
        }
    }

    fun clear()
    {
        synchronized(lock)
        {
            graphics.clear()
        }
        postInvalidate()
    }

    fun add(graphic: Graphic)
    {
        synchronized(lock)
        {
            graphics.add(graphic)
        }
        postInvalidate()
    }

    fun remove(graphic: Graphic)
    {
        synchronized(lock)
        {
            graphics.remove(graphic)
        }
        postInvalidate()
    }

    fun setCameraInfo(previewWidth: Int, previewHeight: Int, facing: Int)
    {
        synchronized(lock)
        {
            this.previewWidth = previewWidth
            this.previewHeight = previewHeight
            this.facing = facing
        }
        postInvalidate()
    }

    override fun onDraw(canvas: Canvas)
    {
        super.onDraw(canvas)

        synchronized(lock)
        {
            if ((previewWidth != 0) && (previewHeight != 0))
            {
                val canvasRatio = width.toFloat() / height.toFloat()
                val previewRatio = previewWidth.toFloat() / previewHeight.toFloat()

                if (canvasRatio > previewRatio)
                {
                    scaleFactor = width.toFloat() / previewWidth.toFloat()
                    offsetX = 0
                    offsetY = -((previewHeight.toFloat() * scaleFactor - height.toFloat()) * 0.5f).toInt()
                }
                else
                {
                    scaleFactor = height.toFloat() / previewHeight.toFloat()
                    offsetX = -((previewWidth.toFloat() * scaleFactor - width.toFloat()) * 0.5f).toInt()
                    offsetY = 0
                }
            }

            for (graphic: Graphic in graphics)
                graphic.draw(canvas)
        }
    }
}
{% endhighlight %}

이번에는 같은 프로젝트의 `FaceContourGraphic.java`를 참고해서 `FaceBoxGraphic.kt` 파일의 내용을 아래와 같이 작성한다.

{% highlight kotlin %}
package com.your.package

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.Log

import com.google.mlkit.vision.face.Face

class FaceBoxGraphic(overlay: GraphicOverlay): GraphicOverlay.Graphic(overlay)
{
    companion object
    {
//        const val FACE_POSITION_RADIUS = 10.0f
        const val ID_TEXT_SIZE = 70.0f
//        const val ID_Y_OFFSET = 80.0f
//        const val ID_X_OFFSET = -70.0f
        const val BOX_STROKE_WIDTH = 5.0f

        val COLOR_CHOICES = arrayOf(Color.BLUE, Color.CYAN, Color.GREEN, Color.MAGENTA, Color.RED, Color.WHITE, Color.YELLOW)

        var currentColorIndex: Int = 0
    }

    private val facePositionPaint: Paint
    private val idPaint: Paint
    private val boxPaint: Paint

    private var face: Face? = null

    init
    {
        currentColorIndex = (currentColorIndex + 1) % COLOR_CHOICES.size
        val selectedColor = COLOR_CHOICES[currentColorIndex]

        facePositionPaint = Paint()
        facePositionPaint.color = selectedColor

        idPaint = Paint()
        idPaint.color = selectedColor
        idPaint.textSize = ID_TEXT_SIZE

        boxPaint = Paint()
        boxPaint.color = selectedColor
        boxPaint.style = Paint.Style.STROKE
        boxPaint.strokeWidth = BOX_STROKE_WIDTH
    }

    fun updateFace(face: Face)
    {
        this.face = face
        postInvalidate()
    }

    override fun draw(canvas: Canvas)
    {
        val face = this.face ?: return

        val x = translateX(face.boundingBox.centerX().toFloat())
        val y = translateY(face.boundingBox.centerY().toFloat())
//        canvas.drawCircle(x, y, FACE_POSITION_RADIUS, facePositionPaint)
//        canvas.drawText("id: ${face.trackingId}", x + ID_X_OFFSET, y + ID_Y_OFFSET, idPaint)

        val xOffset = scaleX(face.boundingBox.width().toFloat() / 2.0f)
        val yOffset = scaleY(face.boundingBox.height().toFloat() / 2.0f)
        val left = x - xOffset
        val top  = y - yOffset
        val right = x + xOffset
        val bottom = y + yOffset
        canvas.drawRect(left, top, right, bottom, boxPaint)
    }
}
{% endhighlight %}

이제 `activity_main.xml`에 `GraphicOverlay` 뷰를 추가한다.

{% highlight xml %}
<androidx.camera.view.PreviewView
    android:id="@+id/viewFinder"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />

<com.your.package.GraphicOverlay
    android:id="@+id/graphic_overlay"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />
{% endhighlight %}

지금부터는 `MainActivity.kt`을 수정할 것이다. 먼저 `FaceDetectAnalyzer`클래스를 다음과 같이 수정한다.

`GraphicOverlay` 인스턴스를 받아서 필드에 저장한다.

{% highlight kotlin %}
private class FaceDetectAnalyzer(graphicOverlay: GraphicOverlay?) : ImageAnalysis.Analyzer
{
    var overlay = graphicOverlay
{% endhighlight %}

`InputImage.fromMediaImage()`를 통해 이미지를 받아오면 이미지 정보를 `GraphicOverlay`에 전달한다.

{% highlight kotlin %}
val image = InputImage.fromMediaImage(mediaImage, imageProxy.imageInfo.rotationDegrees)

if (image.rotationDegrees == 90 || image.rotationDegrees == 270)
    overlay?.setCameraInfo(image.height, image.width, CameraCharacteristics.LENS_FACING_FRONT)
else
    overlay?.setCameraInfo(image.width, image.height, CameraCharacteristics.LENS_FACING_FRONT)
{% endhighlight %}

마지막으로 ML Kit에서 얼굴을 인식하면 화면에 얼굴 영역에 대한 사각형을 오버레이한다.

{% highlight kotlin %}
val result = detector.process(image)
    .addOnSuccessListener { faces ->

        if (this.overlay != null)
        {
            val overlay: GraphicOverlay = this.overlay!!
            overlay.clear()
            for (face in faces)
            {
                val graphic = FaceBoxGraphic(overlay)
                overlay.add(graphic)
                graphic.updateFace(face)
            }
        }

        imageProxy.close()
        Log.d("@@@", "OnSuccess")
    }
    .addOnFailureListener {
        imageProxy.close()
        Log.d("@@@", "OnFailure")
    }
{% endhighlight %}

아래는 `FaceDetectAnalyzer` 클래스의 전체 코드다.

{% highlight kotlin %}
private class FaceDetectAnalyzer(graphicOverlay: GraphicOverlay?) : ImageAnalysis.Analyzer
{
    var overlay = graphicOverlay

    @OptIn(ExperimentalGetImage::class)
    override fun analyze(imageProxy: ImageProxy)
    {
        val mediaImage = imageProxy.image
        if (mediaImage != null)
        {
            val image = InputImage.fromMediaImage(mediaImage, imageProxy.imageInfo.rotationDegrees)

            if (image.rotationDegrees == 90 || image.rotationDegrees == 270)
                overlay?.setCameraInfo(image.height, image.width, CameraCharacteristics.LENS_FACING_FRONT)
            else
                overlay?.setCameraInfo(image.width, image.height, CameraCharacteristics.LENS_FACING_FRONT)

            val detector = FaceDetection.getClient()
            val result = detector.process(image)
                .addOnSuccessListener { faces ->

                    if (this.overlay != null)
                    {
                        val overlay: GraphicOverlay = this.overlay!!
                        overlay.clear()
                        for (face in faces)
                        {
                            val graphic = FaceBoxGraphic(overlay)
                            overlay.add(graphic)
                            graphic.updateFace(face)
                        }
                    }

                    imageProxy.close()
                    Log.d("@@@", "OnSuccess")
                }
                .addOnFailureListener {
                    imageProxy.close()
                    Log.d("@@@", "OnFailure")
                }
        }
    }
}
{% endhighlight %}

이제 레이아웃에 선언된 `GraphicOverlay` 뷰를 `FaceDetectAnalyzer`에 전달하면 된다. 먼저 `onCreate()`에서 `GraphicOverlay` 뷰를 가져온다.

{% highlight kotlin %}
private var graphicOverlay: GraphicOverlay? = null

override fun onCreate(savedInstanceState: Bundle?) {
    // ...

    graphicOverlay = viewBinding.graphicOverlay

    // ...
}
{% endhighlight %}

이제 `startCamera()`에서 `GraphicOverlay` 뷰를 `FaceDetectAnalyzer`에 전달한다. 추가적으로, 카메라 정보도 `GraphicOverlay`에 전달한다.

{% highlight kotlin %}
private fun startCamera() {
    val cameraProviderFuture = ProcessCameraProvider.getInstance(this)

    cameraProviderFuture.addListener({
        // ...

        val imageAnalyzer = ImageAnalysis.Builder()
            .build()
            .also {
                it.setAnalyzer(cameraExecutor, FaceDetectAnalyzer(graphicOverlay))
            }

        // ...

        graphicOverlay?.setCameraInfo(viewBinding.viewFinder.width, viewBinding.viewFinder.height, CameraCharacteristics.LENS_FACING_FRONT)

        // ...

    }, ContextCompat.getMainExecutor(this))
}
{% endhighlight %}

이제 완성되었다. 전체 프로젝트는 [여기](https://github.com/lklab/FaceDetection)서 확인할 수 있다.
