---
title: "라즈베리파이 4 쿨링 시스템 제작기"
image: /assets/post/24-07-10-rpi-cooler/title.jpg
author: khlee
categories:
    - Embedded
layout: post
---

## 개요

2년 전에 라즈베리파이 4에 쿨링 시스템을 제작했던 경험을 기록하고자 한다. 현재 (2024년 7월) 기준으로 이미 라즈베리파이 5도 나와 있는 상태이지만 미루다가.. 이제 포스트를 작성한다.

예전에 라즈베리파이를 서버로 쓰다가 과열로 고장 낸 경험이 있기도 하고 요즘에는 라즈베리파이도 성능이 많이 올라서 쿨링 솔루션이 필수가 되었기 때문에 쿨링 시스템을 제작하기로 했다. 쿨링 시스템을 제작하면서 중점으로 둔 것은 쿨링 성능과 소음이다. 쿨링 성능이야 당연한거고, 방 안에 둘 것이기 때문에 소음도 중요하게 고려하였다.

## 제품 선택

#### 쿨러 없이 방열판만?

쿨러가 없으면 소음도 없으므로, 방열판만으로 발열을 잡아줄 수 있다면 가장 베스트가 되겠다. 라즈베리파이 세트와 함께 온 번들 방열판을 붙여서 테스트 해 보았는데, 역시 기본으로 70도를 넘겨서 안정적으로 사용하기에는 어렵겠다는 판단을 하였다.

<br/>

#### 저렴한 쿨러

라즈베리파이 4 쿨러를 소개하는 [이 영상](https://youtu.be/Bco9q9dGKko)을 보고 [방열판과 쿨러가 포함된 아크릴 케이스 제품](https://www.devicemart.co.kr/goods/view?no=12234823)을 선택하였다. 성능도 좋고 특히 6,500원이라 가성비도 훌륭했다.

![아크릴 케이스 조립]({{site.baseurl}}/assets/post/24-07-10-rpi-cooler/20220609_211931.jpg)

뚝딱뚝딱 조립

일단 쿨링 성능은 훌륭했다. 50도 이상을 넘기지 않고 40도 대를 유지하였다. 그런데 가성비 제품을 사서 그런가 소음이 장난 아니었다. 결국 소음 문제로 이 제품은 사용하지 않기로 했다.

<br/>

#### 최종 선택 - 알루미늄 방열 케이스

가성비 쿨러에 크게 실망하고 나서 돈을 아끼지 않기로 하였다. 그래서 구입한 것이 [미니 데스크탑 알루미늄 방열 케이스](https://www.coupang.com/vp/products/7560722945)다. (당시에는 엘레파츠에서 샀는데 지금 보니 쿠팡에서 판매하고 있다! 심지어 가격도 많이 저렴해졌다. 본인은 53,000원에 구매함)

![알루미늄 방열 케이스 조립]({{site.baseurl}}/assets/post/24-07-10-rpi-cooler/20220614_205039.jpg)

조립은 크게 어렵지 않았고 적당히 재밌었다.

케이스 내부에는 다음 사진과 같이 팬의 전원을 연결할 수 있는 핀이 있어서 선이 밖으로 삐져나오지 않아 깔끔하다.

![팬 전원 연결]({{site.baseurl}}/assets/post/24-07-10-rpi-cooler/20220614_212121.jpg)

거대한 크기의 팬과 히트싱크 덕에 쿨링 성능은 아주 탁월했다. 켜 놓고 있으면 40도를 넘기지 않았다. 소음도 나름 괜찮은 수준이다. 소리가 나긴 하는데 신경 안 쓰면 안 들릴 정도다. 냉장고 돌아가는 소리보다 작았다. 그런데 소리가 작은 건 아니라서 민감한 사람에게는 신경쓰일 것 같다.

## 온도에 따라 쿨러 켜고 끄기

팬 소음이 아예 없는 건 아니고 밤중에는 팬을 끄고 싶어서 프로그램을 통해 밤이 아닐 때 온도에 따라 팬의 전원을 제어하기로 했다. 다음과 같이 두 가지 방법을 고려하였다.

* GPIO 핀을 통해 팬 전원 연결
* 릴레이 스위치를 사용하여 5V 전원을 사용하고 GPIO 핀을 통해 on/off 제어

원래 케이스가 팬의 전원을 5V에 연결하도록 되어 있기도 하고, GPIO 핀은 전력 공급을 위한 용도가 아니므로 릴레이 스위치를 사용하는 방법으로 결정하였다. 이제 릴레이 스위치 제품을 찾아야 하는데 다음과 같은 조건을 만족하는 릴레이 스위치가 별로 없어서 찾기 어려웠다.

* 동작 전압: 3.3V
* 최대 부하 5V/2A 이상

조건에 맞는 [릴레이 스위치](https://smartstore.naver.com/makeitfun/products/4742037936)를 찾아서 이것으로 구매하였다.

<br/>

#### 회로 구성

회로 구성은 다음과 같다.

* Fan GND ----- RPI Pin 09 (Ground)
* Fan VCC ----- Relay
* Relay VCC ----- RPI Pin 02 (DC Power 5v)
* Relay GND ----- RPI Pin 06 (Ground)
* Relay IN ----- RPI Pin 40 (GPIO21)

회로를 연결한 모습

<br/>

#### 팬 제어 스크립트 작성

전체 코드는 [여기](https://github.com/lklab/rpi-fan-control/blob/main/rpi_fan_controller.py)서 확인할 수 있다.

먼저 GPIO21을 출력으로 설정한다.

{% highlight python %}
# setup GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setup(21, GPIO.OUT)
{% endhighlight %}

현재 온도를 가져오는 함수를 구현한다.

{% highlight python %}
def getTemperature(self) :
    file = open('/sys/class/thermal/thermal_zone0/temp', 'r')
    temp = float(file.read()) / 1000.0
    file.close()
    return temp
{% endhighlight %}

반복문에서 일정 주기마다 현재 온도를 읽어서 최소 온도보다 낮으면 팬을 끄고 최대 온도보다 높으면 팬을 켠다.

{% highlight python %}
def printLog(msg) :
	t = '[' + datetime.datetime.now().strftime("%Y%m%d-%H%M%S") + '] '
	print(t + msg)

def fanOnOff(self, isOn) :
    self.isFanOn = isOn
    GPIO.output(21, not isOn)

while self.threadFlag :
    fanOnRequired = False
    fanOffRequired = False

    # check temperature
    temperature = self.getTemperature()
    if temperature < self.settings['minTemp'] and self.isFanOn:
        fanOffRequired = True
        break
    elif  temperature > self.settings['maxTemp'] and not self.isFanOn:
        fanOnRequired = True
        break

    # control fan on/off
    if fanOnRequired :
        self.fanOnOff(True)
        printLog('fan on. temp: ' + str(temperature))

    elif fanOffRequired :
        self.fanOnOff(False)
        printLog('fan off. temp: ' + str(temperature))

    # sleep
    time.sleep(self.settings['period'])
{% endhighlight %}

밤 중에는 팬을 항상 끄도록 한다.

{% highlight python %}
# check off time
if self.offTime :
    now = datetime.datetime.now().time()
    if self.offTime['start'] < self.offTime['end'] :
        if self.offTime['start'] < now and now < self.offTime['end'] :
            if self.isFanOn :
                fanOffRequired = True
            break
    else :
        if self.offTime['end'] > now or now > self.offTime['start'] :
            if self.isFanOn :
                fanOffRequired = True
            break
{% endhighlight %}

그 외에 다음과 같은 명령을 소켓으로 받아서 다양한 기능을 하도록 구현하였다.

* enable: 팬 제어 기능 on/off
* period: 온도 체크 주기 설정
* min_temp: 팬을 끌 온도 설정
* max_temp: 팬을 켤 온도 설정
* off_time: 팬 제어가 동작하지 않고 팬을 항상 꺼 둘 시간대 설정
* control: 강제로 팬을 on/off
