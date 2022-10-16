---
title: Unity VR Support
image: /assets/post/17-10-24-Unity-VR-Support/Screenshot_20171023-235321.png
author: khlee
categories:
    - Unity
layout: post
---

화면 출력 관점에서 모바일에서 동작하는 VR 앱을 개발하기 위해서는 화면을 반으로 나누고, 각 화면의 시점(카메라)을 다르게 해서 3D로 보이도록 만들며, 기기의 센서 정보를 이용해 그에 맞게 시점을 회전하는 head tracking 등등이 필요하다.

예전에 처음 Unity를 사용해 VR 앱을 개발할 때에는 센서 값을 읽어오는 플러그인을 넣고, 카메라를 두 개 만든 다음 센서 값에 따라 카메라를 회전하는걸 직접 구현했었는데, 지금은 Unity에서 자동으로 해 준다. 카드보드, 데이드림, 오큘러스 등등의 VR 플랫폼 지원까지 해준다. 관련 내용은 [문서](https://docs.unity3d.com/Manual/VROverview.html)에 잘 나와 있다.

이번 글은 Unity에서 다 해주므로. 분량이 없다. Edit -> Project Settings -> Player에 들어가서 원하는 플랫폼에 대해 Virtual Reality Supported에 체크한방 날리고 카드보드인지 아니면 다른 플랫폼인지 선택하면 끝이다.

![player settings]({{site.suburl}}/assets/post/17-10-24-Unity-VR-Support/20171023_234700.png)

![player settings]({{site.suburl}}/assets/post/17-10-24-Unity-VR-Support/20171023_234901.png)

알아서 화면도 나눠주고 렌즈를 통해 보기 편하도록 화면 왜곡도 해 주며 head tracking도 된다.

![demo]({{site.suburl}}/assets/post/17-10-24-Unity-VR-Support/Screenshot_20171023-235321.png)

카드보드를 선택하면 안드로이드 4.4 Kit Kat (API level 19) 부터, 데이드림을 선택하면 안드로이드 7.0 Nougat (API level 24) 부터 앱을 실행할 수 있다.
