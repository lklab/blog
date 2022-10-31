---
title: SOEM을 활용하여 라즈베리파이를 EtherCAT 마스터로 만들기
image: /assets/post/17-07-17-EtherCAT/20170529_143851.jpg
author: khlee
categories:
    - EtherCAT
layout: post
---

라즈베리파이에 SOEM을 설치하여 EtherCAT 마스터로 동작하도록 할 것이다.
라즈베리파이는 B+ 모델을 사용했으며, OS로 2017년 03월 02일 버전 raspbian-jessie를 사용했다.

## 준비하기

먼저 최신 버전의 SOEM을 다운로드 받는다.

{% highlight bash %}
$ git clone https://github.com/OpenEtherCATsociety/SOEM
{% endhighlight %}

[http://openethercatsociety.github.io/](http://openethercatsociety.github.io/) 에서 받을 수 있는 1.3.1 버전에서는 make 기반으로 빌드가 가능했었는데, git에서 받은 버전은 cmake 기반으로 빌드를 한다.

사용하는 라즈베리파이에는 cmake가 설치되어있지 않으니 현재 최신 릴리즈 버전인 3.8.2 버전으로 설치했다. [[참고](https://cmake.org/install/)]

{% highlight bash %}
$ wget https://cmake.org/files/v3.8/cmake-3.8.2.tar.gz
$ tar -xvzf cmake-3.8.2.tar.gz
$ cd cmake-3.8.2/
$ ./bootstrap
$ make
$ make install
{% endhighlight %}

라즈베리파이가 구닥다리라 엄청 오래 걸렸다..

이제 [README.md](https://github.com/OpenEtherCATsociety/SOEM)에 나와있는 방법대로 SOEM 빌드를 한다!

{% highlight bash %}
$ cd SOEM
$ mkdir build
$ cd build
$ cmake ..
$ make
{% endhighlight %}

빌드하고 나면 몇 가지 예제 프로그램이 생성되는데 그 중 SOEM/build/test/linux/simple_test/ 경로에 있는 simple_test라는 프로그램을 실행할 것이다.

그 전에 하드웨어 세팅을 시작하자.
구닥다리 라즈베리파이 B+에는 wifi가 기본 내장되어있지 않아서 ssh를 쓰기 위해 wifi 동글을 사용했다. 따라서 네트워크 인터페이스가 wlan0, eth0 두 개가 되는데, wlan0은 ssh를 포함한 인터넷을, eth0은 EtherCAT 포트로 사용한다.

EtherCAT 슬레이브로 사용할 장치는 Beckhoff사의 EL9800 보드로 하였다.
EtherCAT을 통해 제어 가능한 각 8개의 On-board LED와 스위치가 있다.

![Beckhoff EL9800]({{site.baseurl}}/assets/post/17-07-17-EtherCAT/20170529_143851.jpg)

이제 예제 프로그램을 실행한다.

{% highlight bash %}
$ cd test/linux/simple_test/
$ ./simple_test eth0
{% endhighlight %}

실행시키면 다음 그림과 같이 PDO 값에 대해 모니터링해 준다.

![pdo]({{site.baseurl}}/assets/post/17-07-17-EtherCAT/pdo.png)

`O:` 뒤에 첫 1바이트가 LED를 의미하고, `I:` 뒤의 첫 1바이트가 스위치를 의미한다.

## 제어 프로그램 만들기

그냥 실행만 시키면 재미없으니 LED에 불을 켜 보자!

SOEM/test/linux/simple_test/simple_test.c 파일을 열어서 PDO 교환을 수행하는 다음 코드를 보면

{% highlight c %}
/* cyclic loop */
for(i = 1; i <= 10000; i++)
{
    ec_send_processdata();
    wkc = ec_receive_processdata(EC_TIMEOUTRET);

    if(wkc >= expectedWKC)
    {
        printf("Processdata cycle %4d, WKC %d , O:", i, wkc);

        for(j = 0 ; j < oloop; j++)
        {
            printf(" %2.2x", *(ec_slave[0].outputs + j));
        }

        printf(" I:");
        for(j = 0 ; j < iloop; j++)
        {
            printf(" %2.2x", *(ec_slave[0].inputs + j));
        }
        printf(" T:%"PRId64"\r",ec_DCtime);
        needlf = TRUE;
    }
    osal_usleep(5000);
}
{% endhighlight %}

`ec_slave[0].outputs + offset`이 출력(마스터 -> 슬레이브) PDO, 그러니까 RxPDO를 의미하고 `ec_slave[0].inputs + offset`이 TxPDO를 의미한다.

LED는 RxPDO의 첫 번째 바이트로 다음 변수를 통해 접근할 수 있다.

`ec_slave[0].outputs + 0`

정확한 내 장치의 SII에 저장된 PDO 목록을 보고싶다면 같이 빌드되는 예제 프로그램인 slaveinfo를 실행해보면 안다. 다음 명령어를 실행하면

{% highlight bash %}
$ ./slaveinfo eth0 -map
{% endhighlight %}

![pdo]({{site.baseurl}}/assets/post/17-07-17-EtherCAT/slaveinfo.png)

슬레이브의 SII에 저장된 PDO 매핑 정보가 출력되어 나온다.

다시 LED를 제어하는 것으로 돌아와서!
위 코드의 `for` 블록문 첫 번째에 다음 코드를 넣었다.
물론 함수의 첫 부분에 int형 `ledval`(초기값 0x1)과 `tick` 변수(초기값 0x0)를 선언하였다.

{% highlight c %}
/* cyclic loop */
for(i = 1; i <= 10000; i++)
{
    /* for LED output test */
    if(!(++tick % 50))
    {
        ledval <<= 1;
        if(ledval >= 0x100)
            ledval = 0x1;
        *(ec_slave[0].outputs) = ledval;
        tick = 0;
    }
    /* for LED output test */
    ec_send_processdata();
    wkc = ec_receive_processdata(EC_TIMEOUTRET);
{% endhighlight %}

이제 다시 build 디렉토리로 돌아와서 빌드한다.
다시 빌드할 때에는 make만 하면 된다.

{% highlight bash %}
$ cd ../../../build/
$ make
{% endhighlight %}

이제 실행시켜보면 된다.

<iframe class="video" src="https://www.youtube.com/embed/CrT6T_HWt78" allowfullscreen frameborder="0"></iframe>
