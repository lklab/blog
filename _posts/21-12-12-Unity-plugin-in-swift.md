---
title: Unity 2019.3 이상에서 Swift로 플러그인 개발하기
image: /assets/post/21-12-12-Unity-plugin-in-swift/title.jpeg
author: khlee
categories:
    - Unity
layout: post
---

## 개요

Unity에서는 iOS 네이티브와의 인터페이스를 Objective-C로만 제공한다. 따라서 Swift로 플러그인을 제작하려면 Objective-C가 Unity와 Swift를 연결해 주어야 한다. Unity 2019.2 버전까지는 Bridge Header를 활용해서 Objective-C와 Swift를 연동할 수 있었다.<br>
그러나 Unity 2019.3 버전에서 Unity as a Library가 도입되면서 플러그인이 Xcode 상에서 기존의 Unity-iPhone 타겟이 아닌 UnityFramework 타겟에 포함되는 것으로 바뀌었다.<br>
문제는 Bridge Header를 Framework 타겟에서 사용할 수 없다는 것이다. 따라서 Swift로 플러그인을 제작하려면 Bridge Header 외의 방법을 활용해야 한다.

## 참고 자료

* [https://stackoverflow.com/questions/24875745/xcode-6-beta-4-using-bridging-headers-with-framework-targets-is-unsupported](https://stackoverflow.com/questions/24875745/xcode-6-beta-4-using-bridging-headers-with-framework-targets-is-unsupported)
* [https://github.com/jwtan/SwiftToUnityExample](https://github.com/jwtan/SwiftToUnityExample)

## 개발환경

* OS: macOS Monterey 12.0.1
* Unity: 2020.3.19
* 이 글에서 활용한 프로젝트: [https://github.com/lklab/Swift-plugin-for-Unity-iOS](https://github.com/lklab/Swift-plugin-for-Unity-iOS)

## 예제 프로그램

* UI 버튼이 눌리면 유니티는 네이티브 함수를 호출하여 Swift 함수를 실행한다.
* Swift 함수는 호출될 때마다 숫자를 1씩 더한 후 해당 숫자를 포함한 문자열을 유니티에 전달한다.
* 유니티에서는 해당 문자열을 받아서 UI 텍스트를 업데이트한다.

## Unity에서 네이티브 인터페이스 스크립트 작성

NativeInterface.cs

{% highlight csharp %}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;

public class NativeInterface : MonoBehaviour
{
    public static event System.Action<string> OnNativeCall;

#if !UNITY_EDITOR && UNITY_IOS
    [DllImport("__Internal")]
    private static extern string CallPluginIOS();
#endif

    public static string CallPlugin()
    {
#if UNITY_EDITOR
        return "";
#elif UNITY_IOS
        return CallPluginIOS();
#else
        return "";
#endif
    }

    public void CallUnity(string message)
    {
        OnNativeCall?.Invoke(message);
    }
}
{% endhighlight %}

유니티 -> 네이티브 호출

* `[DllImport("__Internal")]`를 사용해서 호출할 네이티브 함수를 선언한다. 이 때 함수명은 나중에 Objective-C에 선언할 함수명과 동일해야 한다.
* 플랫폼에 독립적인 함수 `CallPlugin()`를 구현한다. Define symbol로 플랫폼을 구분한다. 여기서는 iOS 플랫폼에서 네이티브 함수인 `CallPluginIOS()`를 호출한다.
* 여러 플랫폼을 지원하는 소프트웨어를 개발할 때 이 함수와 같이 플랫폼 의존적인 부분을 추상화하는 함수를 만들어 사용하는 것이 좋다.

네이티브 -> 유니티 호출

* 마지막으로 네이티브에서 호출될 함수로 `CallUnity()`를 구현한다. 네이티브에서 호출되는 함수이므로, `OnNativeCall`이라는 이벤트를 통해 다른 스크립트에 제공하도록 한다.
* 네이티브에서 유니티의 함수를 호출하려면 `UnitySendMessage()`를 사용하는데, 여기에 게임오브젝트 이름과 함수명이 필요하다. 따라서 이  스크립트를 포함하는 게임오브젝트와 함수명을 기억해 두었다가 Objective-C에 작성해야 한다.

## 네이티브 플러그인 작성 - Objective-C

objc_bridge.h

{% highlight objc %}
@interface ObjcBridge : NSObject

+ (void) sendMessage: (NSString*)message;

@end
{% endhighlight %}

objc_bridge.mm

{% highlight objc %}
#import "objc_bridge.h"
#import "UnityFramework/UnityFramework-Swift.h"

extern "C"
{
    const char* CallPluginIOS()
    {
        NSString *ret = [SwiftPlugin callPlugin];
        const char *nsStringUtf8 = [ret UTF8String];
        char* cString = (char*)malloc(strlen(nsStringUtf8) + 1);
        strcpy(cString, nsStringUtf8);
        return cString;
    }

    void unitySendMessage(const char* message)
    {
        UnitySendMessage("NativeInterface", "CallUnity", message);
    }
}

@implementation ObjcBridge
    
+ (void) sendMessage: (NSString*)message
{
    unitySendMessage([message UTF8String]);
}

@end
{% endhighlight %}

유니티 -> Objective-C -> Swift

* 유니티와의 인터페이스 역할을 할 함수들은 `extern "C"` 안에 선언한다.
* 유니티에서 호출될 함수는 함수명, 리턴타입, 파라미터를 맞춰서 선언한다. 여기서는 유니티에서 `string CallPluginIOS();`로 선언하였으므로 리턴 타입을 `string`에 대응하는 `const char*`로 한다.
* 다음으로 Swift 함수를 호출한다. Swift에 선언된 심볼들을 참조하기 위해서는 UnityFramework/UnityFramework-Swift.h를 import해야 한다.
* Swift 함수에서 리턴된 `NSString`을 `const char*` 로 바꾸기 위해 `UTF8String` 함수를 사용한다.
* 이 문자열을 그대로 리턴하면 제대로 동작하지 않으므로 새로운 메모리를 할당한 후 거기에 문자열을 복사하여 리턴한다.<br>
참고: [https://stackoverflow.com/questions/37047781/how-to-return-string-from-native-ios-plugin-to-unity](https://stackoverflow.com/questions/37047781/how-to-return-string-from-native-ios-plugin-to-unity)

Swift -> Objective-C -> 유니티

* Swift에서 호출할 `sendMessage()` 함수를 헤더파일과 mm 파일에 선언한다.
* 이 함수는 `extern "C"` 안에 선언된 `unitySendMessage()`를 호출한다.
* `unitySendMessage()`는 `UnitySendMessage()`를 사용하여 유니티의 함수를 호출한다.
    * 이 때 첫 번째 인자로 호출할 함수가 선언된 스크립트가 컴포넌트로 들어있는 게임오브젝트 이름을 전달한다.
    * 두 번째 인자는 호출할 함수 이름을 전달한다.
    * 마지막으로 유니티에 전달하고 싶은 문자열을 전달한다. 이 문자열을 전달하기 위해 `sendMessage()`, `unitySendMessage()` 함수는 각각 `NSString*`과 `const char*`를 파라미터로 받는다.

## 네이티브 플러그인 작성 - Swift

SwiftPlugin.swift

{% highlight swift %}
@objc
public class SwiftPlugin: NSObject
{
    static var count: Int = 0;
    
    @objc
    public static func callPlugin() -> String
    {
        count += 1;
        ObjcBridge.sendMessage("count is " + String(count));
        return "Hello, I'm swift.";
    }
}
{% endhighlight %}

Objective-C -> Swift

* Objective-C에서 참조할 심볼들은 모두 `@objc` 및 `public`으로 해야 한다.

Swift -> Objective-C

* Swift에서 Objective-C를 참조하려면 Bridge Header를 쓰지 못하기 때문에 약간 복잡하다. 여기서는 Bridge Header 대신 [Umbrella header](https://stackoverflow.com/questions/31238761/what-is-an-umbrella-header/31238936)를  사용할 것이다.
* Xcode에서 /UnityFramework/UnityFramework.h 파일을 열고 가장 아랫줄에 앞서 작성했던 objc_bridge.h 헤더파일을 import한다.

![import header]({{site.baseurl}}/assets/post/21-12-12-Unity-plugin-in-swift/import_header.png)

* 다음으로 UnityFramework 타겟의 Build Phases 섹션에서 Headers 카테고리의 Public에 objc_bridge.h 헤더파일을 추가한다.

![build phases]({{site.baseurl}}/assets/post/21-12-12-Unity-plugin-in-swift/build_phases.png)

* 그 다음에는 ObjcBridge 클래스의 sendMessage() 함수를 호출하여 최종적으로 유니티의 함수를 호출한다.

## 테스트용 스크립트 작성 및 테스트

SampleScript.cs

{% highlight csharp %}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SampleScript : MonoBehaviour
{
    [SerializeField] private Button _button;
    [SerializeField] private Text _test;

    private void Awake()
    {
        _button.onClick.AddListener(delegate
        {
            string ret = NativeInterface.CallPlugin();
            Debug.Log("Call plugin returns: " + ret);
        });

        NativeInterface.OnNativeCall += message =>
        {
            _test.text = message;
        };
    }
}

{% endhighlight %}

* UI 버튼의 `onClick` 이벤트가 발생하면 네이티브 함수 `CallPlugin()` 함수를 호출한 후, 그 함수의 리턴값을 로깅한다.
* 네이티브에서 `UnitySendMessage()`를 사용하여 `NativeInterface.CallUnity()` 함수가 호출될 때의 이벤트(`NativeInterface.OnNativeCall`)로 메시지를 받으면 UI 텍스트에서 해당 메시지를 출력한다.

테스트 영상

<iframe class="video" src="https://www.youtube.com/embed/fGLlCfHZARA" allowfullscreen frameborder="0"></iframe>

로그를 통해 Swift에서 리턴한 메시지도 잘 출력되는 것을 확인할 수 있다.

![result]({{site.baseurl}}/assets/post/21-12-12-Unity-plugin-in-swift/result.png)

## 빌드 스크립트

앞서 진행했던 Umbrella header 관련 작업을 아래와 같은 빌드 스크립트를 통해 자동화할 수 있다.

BuildScript.cs

{% highlight csharp %}
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
#if UNITY_IOS
using UnityEditor.iOS.Xcode;
#endif

public static class BuildScript
{
#if UNITY_IOS
    private static string[] publicHeaderPaths = new string[]
    {
        "Libraries/Plugins/iOS/objc_bridge.h",
    };

    [PostProcessBuild]
    public static void OnPostProcessBuild(BuildTarget buildTarget, string buildPath)
    {
        string projPath = buildPath + "/Unity-iPhone.xcodeproj/project.pbxproj";
        PBXProject proj = new PBXProject();
        proj.ReadFromFile(projPath);

        string frameworkTarget = proj.GetUnityFrameworkTargetGuid();

        string unityFrameworkHeaderText = File.ReadAllText(buildPath + "/UnityFramework/UnityFramework.h");
        foreach (string headerPath in publicHeaderPaths)
        {
            string headerGuid = proj.FindFileGuidByProjectPath(headerPath);
            proj.AddPublicHeaderToBuild(frameworkTarget, headerGuid);

            string importStatement = "#import \"" + Path.GetFileName(headerPath) + "\"";
            if (!unityFrameworkHeaderText.Contains(importStatement))
                unityFrameworkHeaderText += "\n" + importStatement + "\n";
        }
        File.WriteAllText(buildPath + "/UnityFramework/UnityFramework.h", unityFrameworkHeaderText);

        proj.WriteToFile(projPath);
    }
#endif
}
{% endhighlight %}

* `proj.ReadFromFile(projPath);`: Xcode 프로젝트 파일을 읽어온다.
* `File.ReadAllText(buildPath + "/UnityFramework/UnityFramework.h");`: /UnityFramework/UnityFramework.h 파일을 열어서 텍스트를 읽어온다.
* `proj.AddPublicHeaderToBuild(frameworkTarget, headerGuid);`: 헤더파일을 Build Phases에 public으로 등록한다.
* `unityFrameworkHeaderText += "\n" + importStatement + "\n";`: /UnityFramework/UnityFramework.h 파일에 헤더파일을 import한다.
* `proj.WriteToFile(projPath);`: 프로젝트 파일에 데이터를 쓴다.

활용법

* 이제 빌드 시마다 추가로 해야 하는 작업은 없다.
* Swift에서 참조할 헤더파일이 추가될 경우 `publicHeaderPaths` 배열에 헤더파일의 경로를 추가하기만 하면 된다.
