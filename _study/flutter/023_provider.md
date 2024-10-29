---
title: "Provider"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
last_modified_at: 2024-10-22
---

다음 플러터 강좌들을 보고 정리한 내용입니다.

* [Provider 입문 1: Provider와 State management](https://youtu.be/-3iD7f3e_SU)
* [Provider 입문 2: ChangeNotifierProvider와 MultiProvider](https://youtu.be/de6tAJS2ZG0)

## Provider

데이터에 따라 UI가 변경되어야 할 때 `setState()` 함수를 사용하면 해당 위젯 전체가 리빌드되기 때문에 비효율적이다. 또한 데이터를 갖고 있는 상위 위젯에서 데이터가 필요한 하위 위젯에 데이터를 전달할 때 widget tree를 따라 해당 경로에 있는 모든 위젯의 생성자를 통해 데이터를 전달해야 하므로 이 역시 불편하다.

Provider를 사용하면 이와 같은 문제를 해결할 수 있다.

Provider는 [이렇게](https://pub.dev/packages/provider/install) 설치할 수 있다.

## Provider.of<T>(context)

`Provider.of<T>(context)`를 사용해서 상위 위젯에 정의되어 있는 데이터를 하위 위젯에서 읽을 수 있다. 이를 위해서는 해당 데이터를 사용할 모든 위젯은 `Provider` 위젯 하위에 속해 있어야 한다.

{% highlight dart %}
@override
Widget build(BuildContext context) {
  return Provider(
    create: (BuildContext context) {
      return FishModel(name: 'Salmon', number: 10, size: 'big');
    },
    child: const MaterialApp(
      home: FishOrder(),
    ),
  );
}
{% endhighlight %}

`create` 매개변수에서는 전달할 데이터를 반환하는 함수를 정의하면 된다.

하위 위젯에서는 다음과 같이 데이터를 읽을 수 있다.

{% highlight dart %}
class FishOrder extends StatelessWidget {
  const FishOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
      body: Center(
        child: Column(
          children: [
            Text(
              'Fish name: ${Provider.of<FishModel>(context).name}',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
{% endhighlight %}

## ChangeNotifierProvider

`ChangeNotifierProvider`를 사용하면 데이터가 변경될 때 UI를 변경할 수 있다.

{% highlight dart %}
@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider<FishModel>(
    create: (BuildContext context) {
      return FishModel(name: 'Salmon', number: 10, size: 'big');
    },
    child: const MaterialApp(
      home: FishOrder(),
    ),
  );
}
{% endhighlight %}

이것이 동작하기 위해서는 데이터 클래스가 `ChangeNotifier`를 mixin해야 한다. 그리고 데이터가 변경되었을 때 `notifyListeners()` 함수를 호출하여 데이터가 변경되었음을 관련된 위젯에 알려야 한다.

{% highlight dart %}
class FishModel with ChangeNotifier {
  final String name;
  int number;
  final String size;

  FishModel({
    required this.name,
    required this.number,
    required this.size
  });

  void changeFishNumber() {
    ++number;
    notifyListeners();
  }
}
{% endhighlight %}

데이터가 변경되었을 경우 다음과 같이 `changeFishNumber()` 함수를 호출하면 된다. 이 때 `ElevatedButton`은 이벤트를 받을 필요가 없으므로 `listen: false`로 설정해 준다.

{% highlight dart %}
ElevatedButton(
  onPressed: () {
    Provider.of<FishModel>(context, listen: false).changeFishNumber();
  },
  child: Text(
    'Change fish number',
  ),
),
{% endhighlight %}

## MultiProvider

만약 데이터 클래스가 여러개인 경우 `MultiProvider` 위젯을 사용할 수 있다.

{% highlight dart %}
@override
Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<FishModel>(
        create: (BuildContext context) {
          return FishModel(name: 'Salmon', number: 10, size: 'big');
        },
      ),
      ChangeNotifierProvider<SeafishModel>(
        create: (BuildContext context) {
          return SeafishModel(name: 'Tuna', number: 0, size: 'middle');
        },
      ),
    ],
    child: const MaterialApp(
      home: FishOrder(),
    ),
  );
}
{% endhighlight %}

그 외 사용 방법은 동일하다.
