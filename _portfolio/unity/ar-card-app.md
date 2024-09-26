---
layout: portfolio
title: AR 기반 장난감 카드 인식 앱 개발
date: 2019-04-01
image: /assets/portfolio/ar-card-app/ar-app.jpg
tag:
  - 겜브릿지
  - Csharp
  - AR
  - Vuforia
  - 모바일
  - 서버 연동
  - 출시
summary:
  division: 외주
  period: 2019.04 - 2019.11 (8개월)
  platform: 모바일
  environment: Unity 2018.4.2f1
  library: Vuforia
  language: C#
  work: 기획, 클라이언트 개발
---

## 업무 내용

* 원청으로부터 요구사항을 받아 기획서 작성 및 합의
* 미리 등록된 특정 이미지를 카메라 화면에서 인식하는 기능 개발 (Vuforia 사용)
* 카메라 화면의 특정 이미지 위치에 영상 또는 사진을 출력하는 기능 개발
* 셀카 기능 개발
* 파리잡기, 갤러그 등 미니게임 개발
* 출시 후 유지보수 수행 (현재는 서비스 중단됨)

## 시스템 구조

* 인식할 카드 이미지들을 Vuforia에 업로드해서 처리된 결과물인 dataset을 다운로드
* 해당 dataset을 AWS에 구축한 서버에 업로드
* 클라이언트를 실행할 때 dataset을 다운로드
* 클라이언트의 Vuforia 모듈에서 카메라 화면을 처리하여 dataset에 포함된 이미지가 있는지 확인
* 이미지를 찾으면 해당 이미지의 키를 서버에 보내고 그에 해당하는 컨텐츠를 다운로드
* 클라이언트에서 컨텐츠에 따라 재생

![Vuforia]({{site.baseurl}}/assets/portfolio/ar-card-app/vuforia.png){: .custom-align-center-img .custom-disable-img-margin}

![AR App]({{site.baseurl}}/assets/portfolio/ar-card-app/ar-app.jpg){: .custom-align-center-img .custom-disable-img-margin}
*\<인식한 이미지 위에 동영상을 재생하는 데모\>*{: .custom-caption}
