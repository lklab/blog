---
title: "Future, async, await"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

플러터 강좌 [기본](https://youtu.be/oFXV4qSXNVs), [심화](https://youtu.be/HjhPhAUPHos)를 보고 정리한 내용입니다.

## Future

Future는 나중에 값을 얻을 수 있게 해 주는 클래스다. (C#의 Task와 비슷한듯)

`Future.delayed()` 함수를 사용하면 일정 시간 뒤에 해당하는 함수를 실행해준다. 그 동안 block되지는 않는다.

{% highlight dart %}
Future.delayed(time, () {
  String info2 = '데이터 처리 완료';
  print(info2);
});
{% endhighlight %}

## async, await

`async`, `await`를 사용해서 비동기를 구현할 수 있다. 아래는 예시.

{% highlight dart %}
void main() {
  showData();
}

void showData() async {
  startTask();
  String account = await accessData();
  fetchData(account);
}

void startTask() {
  String info1 = '요청 수행 시작';
  print(info1);
}

Future<String> accessData() async {
  String account = '';
  const Duration time = Duration(seconds: 3);

  await Future.delayed(time, () {
    account = '8,500만원';
    print(account);
  });

  return account;
}

void fetchData(String account) {
  String info3 = '잔액은 $account 입니다.';
  print(info3);
}
{% endhighlight %}

## FutureBuilder

FutureBuilder를 사용하면 데이터를 받아오길 기다린 후에 위젯을 빌드할 수 있다. 또한 데이터를 가져오는 중에는 `CircularProgressIndicator()` 위젯 등을 출력할 수 있게 한다.

## Event loop

플러터 앱을 실행하면 앱 전체 운영을 총괄하는 `isolate`라는 스레드가 생성된다. 그리고 다음 작업을 실행한다.

1. FIFO 방식의 Event queue에 MicroTask와 Event를 준비한다.
2. main 함수를 실행한다.
3. Event loop를 실행한다.

MicroTask는 짧은 시간 동안 먼저 실행되고 끝나는 작은 작업을 의미한다. 그 후에 Event loop가 Event queue에서 이벤트들을 꺼내(만약 있다면) 처리한다.

Event의 예시는 다음과 같다.

* Gesture
* Drawing
* Reading files
* Fetching data
* Button tap
* Future
* Stream
