---
layout: portfolio
title: AI 및 친구와 함께 플레이할 수 있는 마피아 게임 개발
date: 2024-11-01
image: /assets/portfolio/aimafia/logo.png
tag:
  - 개인프로젝트
  - AI
  - C
  - C++
  - Python
  - Dart
  - Flutter
  - Android
  - iOS
  - 모바일
  - 지역화
  - 출시
summary:
  division: 정규 프로젝트
  period: 2024.11 - 2025.03 (5개월)
  platform: Ubuntu 24.04, Android API Level 23+, iOS 14+
  environment: WSL2, Docker, VSCode, Flutter
  language: C++, Python, Dart
  work: 1인 개발
---

## 구조

![Structure]({{site.baseurl}}/assets/portfolio/aimafia/aimafia-structure.png)

* 서버 구현사항
    * 메인 프로세스 1개, 게임 프로세스 여러 개, 운영 프로세스 1개로 구성됨
    * 메인 프로세스는 클라이언트와 최초로 연결되는 프로세스로, 게임을 시작하면 게임 프로세스를 하나 선택해서 게임을 실행하고 그 게임 프로세스의 TCP 포트를 클라이언트에 알려줌
    * 게임 프로세스는 여러 개가 실행될 수 있으며, 메인 프로세스의 중단 없이 게임 프로세스를 자유롭게 추가 실행하거나 중단시킬 수 있음
        * 이를 통해 사용자가 많아질 경우 각각의 게임 프로세스로 게임 로직을 분산하여 처리할 수 있음
        * 또한 일부 게임 프로세스가 예상치 못하게 중단되더라도 서버를 계속 유지할 수 있고, 게임 프로세스만 업데이트가 필요한 경우 전체 서버를 중단하지 않고 게임프로세스를 서서히 교체하는 방식으로 업데이트할 수 있음
    * 각각의 게임 프로세스는 게임을 여러 개 실행할 수 있음
    * 운영 프로세스는 서버의 점검 등으로 인해 서버가 실행 중이 아닐 경우 클라이언트와 대신 연결되어 현재 상황에 대한 메시지를 클라이언트에 전달하는 역할을 함
    * 주요 로직은 C++로 작성하였으며, LangChain 사용 등으로 Python이 필요한 부분만 Python으로 작성하여 C++에서 호출하는 방식으로 구현하였음
    * Boost::asio를 사용하여 코루틴 기반으로 각종 IO 작업을 비동기로 처리함
* 클라이언트는 Flutter로 구현하였음
* 서버와 클라이언트의 통신은 TLS가 적용된 TCP 소켓을 활용하며, 자체 포맷 패킷에 Protobuf로 직렬화된 데이터를 담아서 통신함
* 서버와 통신하는 클라이언트가 유효한지 확인하기 위해 Firebase의 App Check를 활용하였음

## AI 토론 구조

![Discussion Player]({{site.baseurl}}/assets/portfolio/aimafia/discussion-player.png)

* AI 플레이어의 토론은 Strategy로 추상화하여, 이를 기반으로 토론 문장을 생성함
    * Strategy에는 자신의 역할을 무엇이라고 주장하는지, 자신이 의심하는 대상은 누구인지 등에 대한 정보가 들어 있음
* 각 플레이어는 다른 플레이어의 Strategy와 기존 이벤트들을 기반으로 자신의 새로운 Strategy를 평가함
* LLM은 이 새로운 Strategy와 대화 내역, 게임 이벤트 등을 입력으로 받아 문장을 생성함
* 이러한 방식을 통해 LLM이 마피아 게임의 추론을 담당하지 않아도 되기 때문에 저렴한 모델을 사용하여 비용을 절감할 수 있음
    * 현재 입력 백만토큰 당 $0.075~$0.15 수준의 저렴한 모델만 사용하고 있음
* 새로운 Strategy를 평가하는 로직을 LLM에 맡기지 않고 직접 구현하기 때문에 개발자가 컨트롤할 수 있어서 게임의 흐름을 통제할 수 있음
    * 경찰이 자신이 경찰임을 밝히는 상황을 만들거나, 마피아가 거짓으로 자신이 경찰이라고 주장하는 상황 등을 제어할 수 있음

![Discussion Manager]({{site.baseurl}}/assets/portfolio/aimafia/discussion-manager.png)

* AI 플레이어가 각자 할 말만 하면 토론하는 느낌을 플레이어에게 줄 수 없기 때문에 위 그림과 같이 이전 발언에 대해 AI 플레이어가 반응하는 시스템을 구현하였음
* 새로운 토론이 생성되면 LLM이나 별도의 로직을 통해 티켓을 생성
    * 예시1) 이전 토론이 질문인 경우, LLM을 통해 누가 응답할지 결정
    * 예시2) 이전 토론에서 누군가 자신이 경찰이라고 주장할 경우, 진짜 경찰 플레이어가 그에 반응
* 티켓을 AI 플레이어에게 전달하여 LLM을 활용하여 응답 토론을 생성함
* 인간 플레이어의 토론을 LLM을 통해 Strategy로 변환

## 개발 환경

서버
* 운영체제: Windows 11(WSL2), MacOS 15(Docker)
* 툴: VSCode
* 빌드시스템: CMake, Ninja, C++20
* C++ 라이브러리: Boost, OpenSSL, Protobuf, ICU, Python3, gettext, sqlite3, spdlog
* Python 패키지: langchain, langgraph, protobuf, firebase

클라이언트
* 운영체제: Windows 11, MacOS 15
* 툴: VSCode, Flutter 3.24
* 라이브러리: riverpod, firebase, protobuf, games_services, google_mobile_ads, intl, shared_preferences, url_launcher, font_awesome_flutter, uuid, chat_bubbles, flutter_launcher_icons

## 게임 특징

* AI와 함께 마피아 게임을 할 수 있음
* 플레이어 수를 3~10명까지 선택할 수 있고 그에 맞게 마피아 수도 1~4명 선택 가능
* 인간 친구와 함께 플레이할 수 있도록 방을 생성하고 입장하는 기능이 있음 (멀티플레이 기능 제공)
* 혼자 플레이하는 경우 자신의 역할을 선택해서 게임을 시작할 수 있음
* Google Play Games 및 Apple Game Center와 연동하여 17개의 업적 달성 가능
* 13개의 언어 지원
* Android, iPhone의 세로 화면 및 iPad의 세로/가로 화면 등 다양한 화면 비율 지원
* 게임 중 배너 광고, 게임 후 전체화면 광고, 마피아의 암살 표적이 되었을 때 암살을 피할 수 있는 보상형 광고 출력

## 출시

[Google Play](https://play.google.com/store/apps/details?id=com.ninewands.aimafia)

[App Store](https://apps.apple.com/app/ai-mafia-game/id6741802923)

![Screenshot]({{site.baseurl}}/assets/portfolio/aimafia/screenshot01.png){: width="240"}
![Screenshot]({{site.baseurl}}/assets/portfolio/aimafia/screenshot00.png){: width="240"}
![Screenshot]({{site.baseurl}}/assets/portfolio/aimafia/screenshot02.png){: width="240"}
![Screenshot]({{site.baseurl}}/assets/portfolio/aimafia/screenshot03.png){: width="240"}
![Screenshot]({{site.baseurl}}/assets/portfolio/aimafia/screenshot04.png){: width="240"}
{: .custom-disable-p-align}
