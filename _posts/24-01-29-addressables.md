---
title: "Unity Addressables"
image: /assets/post/24-01-29-addressables/cardboard-boxes-3126552_640.jpg
image-source: https://pixabay.com/ko/photos/%ED%8C%90%EC%A7%80-%EC%83%81%EC%9E%90-%ED%8C%90%EC%A7%80-%ED%8F%AC%EC%9E%A5-%ED%8F%AC%EC%9E%A5%EC%9E%AC-3126552/
author: khlee
categories:
    - Unity
layout: post
---

## 개요

유니티는 앱을 여러 파일로 나눠서 빌드할 수 있는 에셋 번들 시스템을 제공한다. 이를 통해 큰 용량의 앱을 여러 파일로 나눠서 런타임에 다운로드하거나, 각 언어별 패키지 등의 컨텐츠를 사용자에 따라 선택적으로 받을 수 있게 하거나, 꼭 앱을 빌드하여 배포하지 않고 컨텐츠를 업데이트할 수 있다. 그러나 이러한 에셋 번들을 활용하는 명확한 워크플로가 없기 때문에 개발자들은 저마다의 "에셋 번들 관리 시스템"을 구현하여 활용하였다. 유니티는 이러한 "에셋 번들 관리 시스템"을 일반화하여 꼭 해당 시스템을 직접 구축하지 않아도 에셋 번들을 효과적으로 활용할 수 있도록 "어드레서블 에셋 시스템"을 정식 패키지로 2019.3에 포함하였다. 이번 포스트에서는 어드레서블 에셋 시스템을 활용하는 방법에 대해 알아 볼 것이다.

자세한 개요는 [여기](https://blog.unity.com/kr/games/addressable-asset-system)서 확인할 수 있다.

## Addressables Groups 구성하기

가장 먼저 해야 할 일은 Unity Package Manager에서 Addressable을 추가하는 것이다.

![UPM addressables]({{site.baseurl}}/assets/post/24-01-29-addressables/upm_addressables.png)

그런 다음 메뉴의 Window -> Asset Management -> Addressables -> Groups를 통해 Addressables Groups 창을 연다. 앞으로 이 창을 가장 자주 활용하게 될 것이다.

![Open Addressables Groups]({{site.baseurl}}/assets/post/24-01-29-addressables/open_addressable_groups.png){: width="480" .custom-align-center-img}

Addressables Groups 창을 열면 Built In Data와 Default Local Group이 있다. Built In Data에는 아래 그림처럼 Resources 폴더 내의 에셋들과 씬들이 들어가는 것을 볼 수 있다. Default Local Group은 아직 비어있지만 여기에 에셋을 추가해서 런타임에 찾아 로드할 수 있다.

![Addressables Groups]({{site.baseurl}}/assets/post/24-01-29-addressables/addressables_groups.png){: width="480" .custom-align-center-img}

이제 새로운 그룹을 만들고 기본 3D 오브젝트인 Cube 프리팹을 추가해 볼 것이다. Addressables Groups 창의 좌측 상단에서 New -> Packed Assets를 선택해서 Group을 하나 추가하고 이름을 Remote로 바꾼다.

![Add a group]({{site.baseurl}}/assets/post/24-01-29-addressables/add_group.png){: width="240" .custom-align-center-img}

Cube.prefab 파일을 만들고 프리팹 파일을 선택한 후 우측 상단의 Addressalbe을 체크한다. 그러면 자동으로 해당 에셋의 파일 경로가 우측 칸에 입력된다. 이 문자열은 자유롭게 변경할 수 있다. 런타임에 이 에셋을 로드할 때 이 문자열을 사용할 것이다. 그리고 아래쪽의 Group에는 방금 만든 Remote Group으로 변경한다.

![Add a asset to a group]({{site.baseurl}}/assets/post/24-01-29-addressables/add_asset_to_group.png){: width="480" .custom-align-center-img}

그러면 Addressables Groups에서 아래와 같이 방금 추가한 에셋을 확인할 수 있다.

![Added to a group]({{site.baseurl}}/assets/post/24-01-29-addressables/added_to_group.png){: width="480" .custom-align-center-img}

## 에디터 실행 모드

Addressables Groups의 상단에 Play Mode Script를 클릭하면 다음과 같은 항목을 확인할 수 있다.

![Play mode script]({{site.baseurl}}/assets/post/24-01-29-addressables/play_mode_script.png){: width="720" .custom-align-center-img}

에디터에서 실행하여 테스트할 경우 에셋 번들을 어떤 방식으로 로드할지 설정하는 기능이다. 각 항목은 다음과 같다.

* Use Asset Database
  * 에디터에 있는 에셋 데이터베이스에서 에셋을 직접 로드해서 사용한다. 즉 직접 빌드된 에셋 번들을 사용하는 것이 아니기 때문에 실제 동작과는 차이가 있다.
* Simulate Groups
  * 실제 빌드된 에셋을 시뮬레이션하는 것 같은데 정확한 설명을 못 찾았다.
* Use Existing Build
  * 실제 빌드된 에셋을 로컬 또는 리모트 서버에서 다운로드 받고 로드한다. 가장 실제 동작과 가까운 방법이다. 단, 타겟 플랫폼이 모바일이더라도 에디터가 동작하는 환경은 Windows 또는 Mac이기 때문에 해당 빌드 타겟으로 빌드된 에셋 번들이 필요하다.

## 에셋을 로드하는 방법

어드레서블 에셋 시스템은 런타임에 에셋을 로드할 수 있는 다양한 방법을 제공한다. 먼저 `Addressables.InstantiateAsync()` 함수를 통해 로드하고 바로 인스턴스로 만들 수 있다.

{% highlight csharp %}
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public class TestScript : MonoBehaviour
{
    private void Start()
    {
        Addressables.InstantiateAsync("Assets/Prefabs/Cube.prefab").Completed += (op) =>
        {
            if (op.Status != AsyncOperationStatus.Succeeded)
            {
                Debug.LogError("Fail to load asset.");
                return;
            }
        };
    }
}
{% endhighlight %}

아니면 `Addressables.LoadAssetAsync()` 함수로 로드하고 직접 인스턴스로 만들 수 있다.

{% highlight csharp %}
using System.Collections;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public class TestScript : MonoBehaviour
{
    private IEnumerator Start()
    {
        AsyncOperationHandle<GameObject> handle = Addressables.LoadAssetAsync<GameObject>("Assets/Prefabs/Cube.prefab");

        yield return handle;

        if (handle.Status != AsyncOperationStatus.Succeeded)
        {
            Debug.LogError("Fail to load asset.");
            yield break;
        }

        Instantiate(handle.Result);
    }
}
{% endhighlight %}

로드한 에셋을 언로드해서 메모리를 확보하려면 `Addressables.Release<>()` 또는 `Addressables.ReleaseInstance()`(`Addressables.InstantiateAsync()`로 로드한 경우) 함수를 호출하면 된다.

{% highlight csharp %}
public void Unload()
{
    Addressables.ReleaseInstance(handle);
}
{% endhighlight %}

로드하지 않고 다운로드만 하려면 `Addressables.GetDownloadSizeAsync()` 함수로 다운로드할 크기가 있는지 확인하고 0이 아니면 `Addressables.DownloadDependenciesAsync()` 함수로 다운로드할 수 있다. 다운로드 중에 `AsyncOperationHandle.PercentComplete` 값을 읽어서 다운로드 진행도를 체크할 수 있다.

{% highlight csharp %}
using System.Collections;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public class TestScript : MonoBehaviour
{
    private IEnumerator Start()
    {
        AsyncOperationHandle<long> getSizeHandle = Addressables.GetDownloadSizeAsync("Assets/Prefabs/Cube.prefab");

        yield return getSizeHandle;

        long downloadSize = getSizeHandle.Result;
        Addressables.Release(getSizeHandle);

        if (downloadSize != 0)
        {
            AsyncOperationHandle downloadHandle = Addressables.DownloadDependenciesAsync("Assets/Prefabs/Cube.prefab");

            while (!downloadHandle.IsDone)
            {
                Debug.Log($"progress = {downloadHandle.PercentComplete}");
                yield return null;
            }

            if (downloadHandle.Status != AsyncOperationStatus.Succeeded)
            {
                Debug.LogError("Fail to load asset.");
                Addressables.Release(downloadHandle);
                yield break;
            }

            Addressables.Release(downloadHandle);
        }
    }
}
{% endhighlight %}

## 리모트 서버로 테스트 - 서버 구축하기

어드레서블 에셋 시스템을 실제로 활용하기 위해선 리모트 서버가 필수적일 것이다. 그래서 에셋 번들 서버를 직접 구축해서 테스트할 것이다. AWS를 사용해도 좋지만 여기서는 집에 놀고 있는 라즈베리파이 서버를 활용할 것이다.

![Server]({{site.baseurl}}/assets/post/24-01-29-addressables/server.jpeg){: width="720" .custom-align-center-img .custom-disable-img-margin}
*이 친구다.*{: .custom-caption}

서버는 간단하게 Django로 구성했다. Django 서버 구축 방법은 [이 글](https://wikidocs.net/91422)을 참고하자.

프로젝트 이름을 `bundle`로 하고, `storage` 앱을 생성한 후 여기에 에셋을 제공하는 기능을 구현할 것이다.

{% highlight bash %}
$ python manage.py startapp storage
{% endhighlight %}

bundle/settings.py

{% highlight python %}
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'storage',
]
{% endhighlight %}

bundle/urls.py 파일을 다음과 같이 수정한다.

{% highlight python %}
urlpatterns = [
    path('admin/', admin.site.urls),
    path('storage/', include('storage.urls')),
]
{% endhighlight %}

storage/urls.py 파일은 다음과 같다.

{% highlight python %}
from django.urls import path

from . import views

urlpatterns = [
    path('<platform>/<file_name>', views.get_bundle)
]
{% endhighlight %}

마지막으로 storage/views.py에는 에셋 번들 파일을 전송하는 로직이 구현된다.

{% highlight python %}
from django.shortcuts import render
import os

# Create your views here.

from django.http import HttpResponse

def get_bundle(request, platform, file_name):
    file_path = os.path.join('storage', 'bundles', platform, file_name)
    with open(file_path, 'rb') as file :
        file_data = file.read()

    response = HttpResponse(file_data, content_type='application/octet-stream')
    response['Content-Disposition'] = 'attachment; filename=' + file_name

    return response
{% endhighlight %}

에셋 번들 파일은 storage/bundles/{Platform}/ 폴더 내에 저장하면 된다. {Platform}은 `StandaloneOSX`, `Android` 등이 될 수 있으며 에셋 번들을 플랫폼별로 구분할 수 있게 된다.

이제 서버를 구동한다.

{% highlight bash %}
$ python manage.py runserver
{% endhighlight %}

## 리모트 서버로 테스트 - Addressables Group 설정하기

Addressables Groups 창에서 새로운 그룹을 만들고 이름을 `Remote`로 지정했지만 실제 리모트 서버에서 로드하는 것으로 설정하려면 몇 가지 설정이 필요하다. 먼저 해당 Group을 선택하고 인스펙터 창에서 Build & Load Paths를 Remote로 설정해야 한다.

![Remote setting]({{site.baseurl}}/assets/post/24-01-29-addressables/remote_setting.png){: width="640" .custom-align-center-img}

그 다음 Window -> Asset Management -> Addressables -> Profiles를 선택해서 Addressables Profiles 창을 열고 Remote 항목을 Custom으로 설정하고 아래와 같이 리모트 서버 주소를 입력한다. 각자 환경에 맞게 주소를 세팅하되, 서버에서 플랫폼별로 경로를 구분하도록 했으므로 storage/\[BuildTarget\]을 붙여줘야 한다.

![Addressables Profiles]({{site.baseurl}}/assets/post/24-01-29-addressables/addressables_profiles.png){: width="640" .custom-align-center-img}

Window -> Asset Management -> Addressables -> Settings를 열고 Catalog 섹션의 Build Remote Catalog 항목을 체크한다. 이 항목을 체크하고 어드레서블을 빌드하면 에셋 외에 카탈로그 파일도 생성되는데, 클라이언트는 에셋을 다운로드받기 전에 카탈로그를 먼저 확인한 후 다운로드 받을 에셋이 무엇인지 알 수 있게 된다. 이를 통해 앱을 빌드하지 않고 에셋 번들만 업데이트해서 클라이언트에게 다른 에셋을 제공할 수 있다.

Player Version Override는 카탈로그의 버전을 지정할 수 있는 기능이다. 기본적으로 `[UnityEditor.PlayerSettings.bundleVersion]`로 지정되어 있는데, 이렇게 하면 카탈로그 버전이 클라이언트 버전과 1:1로 매칭된다. 따라서 이전 버전의 클라이언트는 해당 버전의 카탈로그를 확인하여 그 버전에 해당하는 에셋 번들만 가져올 수 있게 되고, 다음 버전의 카탈로그는 클라이언트를 업데이트해야 확인할 수 있게 된다.

![Catalog]({{site.baseurl}}/assets/post/24-01-29-addressables/catalog.png){: width="640" .custom-align-center-img}

마지막으로 테스트 환경에 따라 Player Settings -> Other Settings -> Allow downloads over HTTP 항목에서 HTTP를 허용해야 한다. 만약 서버가 HTTPS로 동작한다면 이 작업은 필요 없다.

![Allow downloads over HTTP]({{site.baseurl}}/assets/post/24-01-29-addressables/allow_http.png){: width="480" .custom-align-center-img}

이제 에셋 번들을 빌드한다. Addressables Groups 창에서 Build -> New Build -> Default Build Script를 선택하면 된다.

![Build]({{site.baseurl}}/assets/post/24-01-29-addressables/build.png){: width="360" .custom-align-center-img}

그러면 {Project root}/ServerData/{Build Target} 폴더 내에(또는 위에 Addressables Profiles에서 Remote.BuildPath에 설정한 경로에) 카탈로그와 에셋 번들이 빌드되어 생성된다. 이 파일들을 리모트 서버의 storage/bundles/{Platform}/ 폴더에 업로드하면 된다.

## 에셋 번들 업데이트하기

카탈로그를 사용하기 때문에 클라이언트를 새로 빌드하지 않고 에셋 번들만 빌드해서 배포할 수 있다. Addressables Groups 창에서 Build -> New Build -> Default Build Script를 선택하거나 Build -> Update a Previous Build를 선택하면 된다. 새로 빌드된 파일을 서버에 업로드하는 것도 잊지 말아야 한다.

이미지를 새로 추가하거나 애니메이션를 새로 추가하는 등 에셋 번들을 자유롭게 변경해서 서버에 업로드하면 클라이언트를 새로 배포하지 않아도 그 변경사항이 적용된다. 그러나 에셋 번들의 모든 변경사항이 에셋 번들만의 업데이트로 해결되는 것은 아니다. 기존 클라이언트 배포에 포함되지 않은 스크립트나 쉐이더가 추가되는 경우 새 에셋 번들을 사용하기 위해서는 클라이언트를 새로 빌드해야 한다. 특히 머티리얼의 경우 기존 클라이언트에서 전혀 사용되지 않은 쉐이더를 사용하는 경우(기본 Standard 쉐이더 이더라도..!) 그 에셋 번들을 사용하기 위해서는 클라이언트를 배포해야 한다.

## 중복된 의존성을 가진 에셋

동일한 에셋을 여러 개의 Addressables Group 또는 Built in Scene에서 참조하는 경우 그 에셋은 각각의 Group이나 Built in에 중복으로 존재하게 된다. 따라서 에셋이 중복되어 하드디스크나 메모리 용량을 낭비하지 않도록 에셋간의 의존성을 잘 설계해야 한다. 어떤 에셋이 중복되는지에 관한 정보는 Window -> Asset Management -> Addressables -> Analyze로 열 수 있는 Addressables Analyze 창에서 확인할 수 있다. unity_builtin_extra는 유니티에서 기본 제공하는 에셋들인 것 같은데 이 에셋의 의존성이 중복되는 것은 어쩔 수 없는 것 같다. 아래 예에서는 아마 Cube 메시가 중복되는 것 같다.

![Addressables Analyze]({{site.baseurl}}/assets/post/24-01-29-addressables/addressables_analyze.png){: width="640" .custom-align-center-img}
