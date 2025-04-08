---
title: 'Unity 6의 웹 플랫폼 소개'
image: /assets/study/unity_csharp/008_unity6_preview/a484e6382320712c8ac99818017121ad3f6f1ce1-3584x2012.avif
author: khlee
layout: post
last_modified_at: 2025-04-08
---

[Unity 6의 웹 플랫폼 소개](https://youtu.be/eCTKiBVUdRM)를 보고 작성한 내용입니다.

## 이름 변경

기존에는 WebGL에 HTML5 아이콘이었는데, Web(Unity Web, Web Target)으로 이름을 변경했다.

## 모바일 브라우저 지원

Unity 6에서 모바일 브라우저를 공식 지원한다. iOS Safari 15+, Chrome 58+에서 지원한다.

## WebGPU

아직은 실험적인 기능이다. 컴퓨트쉐이더와 같은 고급 GPU 기능을 사용할 수 있다. 따라서 VFX Graph와 GPU skinning을 사용할 수 있다. 또, Deferred 렌더링과 같은 URP 고급 기능을 사용할 수 있게 된다.

WebGPU를 사용하려면 브라우저가 지원해야 한다. Chrome과 Edge는 공식 지원하지만 Safari는 별도의 설정을 해야 한다.

## 지원하지 않는 기능

WebGPU가 HDRP의 요구사항을 충족하지 않기 때문에 HDRP를 사용할 수 없다.

C# 스레드를 사용할 수 없다. 브라우저에서 멀티스레드를 사용하는 것은 불가능하지 않지만, 가비지컬렉션과 C# 스레드의 양립이 기술적으로 어려워서 C# 스레드를 아직 사용할 수 없다.

## 업로드 최적화

로딩 시간을 줄이기 위해 빌드 크기를 줄이는 것을 추천

* Platform Settings의 Code Optimization에서 Disk Size with LTO를 선택 (단, 빌드 시간이 증가함)
* Compression Format을 Brotli를 사용 (효과가 가장 큼)
    * 단, 웹서버가 Brotli를 지원해야 함
    * 지원하지 않는다면 Decompression Fallback을 켜고 별도의 압축 코드를 로더에 내장할 수 있음
* 코드 크기 줄이기
    * Managed Stripping Level을 High로 설정 (IL2CPP에서 C++로 변환할 때 프로젝트에서 사용하지 않는 코드를 빌드에서 제거, 다만 리플렉션 사용 시 주의)
    * IL2CPP Code Generation을 Faster (smaller) builds로 설정 (IL2CPP에서 제네릭 관련 코드를 포인터를 사용하여 여러 타입에서 공유하는 코드로만 변환)
    * Target WebAssembly 2023 켜기 (브라우저 요구사항 높아짐)
