---
title: Unity Monthly Tech Talk 7월
image: /assets/study/unity_csharp/006_monthly_tech_talk_2024_07/title.png
author: khlee
layout: post
last_modified_at: 2024-07-25
---

## 유니티 애플리케이션의 안드로이드 ANR(Application Not Responding) 오류를 줄이는 팁과 사례

일반적인 ANR 원인

* Ads
* 서드파티 패키지
* 네이티브 코드
* 저사양 기기
* 웹뷰

ANR 로그

* `at android.os.MessageQueue.nativePollOne(Native method)`: ANR이 발생했다는 뜻으로 추가적인 정보는 없음
* Input Dispatching Timed Out: 입력이 들어간 후 응답 타임아웃 발생
* Content Provider Timeout, Service Timeout, Broadcast Timeout: 주로 다른 스레드 끝나기 기다릴 때 발생

제안

* 패키지를 한꺼번에 초기화하지 말고 하나씩 초기화하기
* 모든 서드파티 패키지를 점검하기
* onPause와 관련된 긴 실행 프로세스를 주의
  * 백그라운드에서 긴 프로세스를 실행하면 ANR을 유발함
* CPU와 메모리 사용량을 확인
* UnityPlayerForActivityOrService.SynchronizationTimeout.setTimeoutForAll 설정을 확인 (java)
  * 우선적으로 권장하는 방법은 아님
* 불필요한 저사양 기기에 대한 지원 중단 고려

디버깅 전략

* 심볼 파일을 게임과 함께 업로드
* 개발자 옵션을 활성화하고 다음 설정
  * 엄격 모드 사용 (struct mode)
  * 충돌 다이얼로드 항상 표시
  * 백그라운드 ANR 표시
* ANR이 가장 많이 발생한 버전간 변경 사항을 확인
* Backtrace와 같은 로깅 소프트웨어를 사용
  * 브레드크럼, 워치독, 인스턴트 업데이트, 구성 가능한 필터를 제공

Firebase Test Lab: 테스트 자동으로 수행

안드로이드의 새로운 Activity인 GameActivity를 사용 (유니티 2023+)

## Untiy Sentis: HuggingFace의 샘플을 활용하여 간단한 온디바이스 음성인식 게임을 만들어보기

Sentis 특징

* 멀티플랫폼
* 온디바이스

ML Agent

* Huggy 라는 샘플 프로젝트 통해 확인할 수 있음 (Hugging face의 how huggy works)

Hugging Face 샘플로 Training data 생성용으로 사용도 가능!

#### 샘플들을 활용하여 간단한 예제를 만들어 보기

![예제 목록]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-150834.png)

LLaMa3:8B는 로컬에서 추론할 수 있는 LLM

[예제 프로젝트](https://github.com/skykim/202407_TechTalk_SentisDemo)

핸드 랜드마크 모델은 구글의 mediapipe를 사용한 것인데 텐서플로우로 되어 있어서 onnx로 변환해서 사용하였음

묵찌빠는 다음과 같이 트레이닝을 함. 핸드 랜드마크의 21개 랜드마크 좌표를 가지고 0~2(묵찌빠)로 classification.

![묵찌빠 트레이닝 1]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-151105.png)

![묵찌빠 트레이닝 2]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-151518.png)

여기에 C#에서 softmax 레이어를 추가해서 추론 진행

#### 대화가 가능한 AI NPC 만들기

![대화가 가능한 AI NPC 만들기]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-151927.png)

![대화가 가능한 AI NPC 만들기]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-152033.png)

RAG

* LLM의 Fine-tuning이 필요하지 않음
* 환각증상(Hallucination)을 줄여줌
* 실시간 정보를 검색하여 처리 가능
* 효율적으로 Prompt 입력 길이를 관리

Speech To Text Model

![Speech To Text Model]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-152328.png)

Sentence Embedding Model

![Sentence Embedding Model]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-152804.png)

Cosine Similarity: 문장 유사도 계산

![Cosine Similarity]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-153105.png)

LLM: 문장 생성

![LLM]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-153249.png)

LLM Prompt

![LLM Prompt]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-153506.png)

![LLM Prompt]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-153729.png)

Text To Speech Model

![Text To Speech Model]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-153823.png)

![Text To Speech Model]({{site.baseurl}}/assets/study/unity_csharp/006_monthly_tech_talk_2024_07/2024-07-25-154016.png)

#### AI 갤러리 만들기

Hugging Face Inference API를 사용해서 구현

Stable Diffusion XL 모델을 사용: SDXL 1.0-base (약 7GB)

무료로 사용할 수 있지만 유료를 더 좋을것임

Hugging Face API package를 Unity에 설치해야 함
