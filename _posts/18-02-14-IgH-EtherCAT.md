---
title: IgH EtherCAT Master Stack API 분석
image: /assets/post/18-02-14-IgH-EtherCAT/ethercat.jpg
author: khlee
categories:
    - EtherCAT
layout: post
---

## 준비물

- IgH EtherCAT Master Stack 1.5.2와 Xenomai OS가 설치된 제어기
- 위 플랫폼에 대한 개발환경 (툴체인, 라이브러리 등)
- Digital I/O EtherCAT Slave 장치

## 참고자료

- [IgH EtherCAT Master Stack 라이브러리](https://etherlab.org/en/ethercat/)
- [IgH EtherCAT Master Stack 1.5.2 Documentation](https://etherlab.org/download/ethercat/ethercat-1.5.2.pdf)

## 예제코드

{% highlight c %}
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

#include <native/task.h>
#include <native/timer.h>
#include <ecrt.h>

#define INTERVAL 1000000

static void rt_task_proc(void *arg);
static void sigint_handler(int sig);

/* PDO list to use in application */
unsigned int slave0_6000_01;
unsigned int slave0_6000_01_bit;
unsigned int slave0_7010_01;
unsigned int slave0_7010_01_bit;

static ec_pdo_entry_reg_t pdo_entry_reg[] = {
    {0, 0, 0x0, 0x0, 0x6000, 1, &slave0_6000_01, &slave0_6000_01_bit},
    {0, 0, 0x0, 0x0, 0x7010, 1, &slave0_7010_01, &slave0_7010_01_bit},
    {}
};

static ec_master_t* master = NULL;
static ec_domain_t* domain = NULL;
static uint8_t* domain_pd = NULL;

static int alive = 1;

int main(int argc, char** argv)
{
    int i;
    int ret = 0;

    ec_master_info_t master_info;
    ec_slave_info_t* slave_info_list = NULL;
    ec_slave_config_t* slave = NULL;
    int slave_count = 0;

    RT_TASK* rt_task_plc = NULL;

    /* signal handler registration */
    signal(SIGINT, sigint_handler);

    /* configure master */
    master = ecrt_request_master(0);
    if(master == NULL)
    {
        printf("EtherCAT master request failed!\n");
        return 1;
    }

    domain = ecrt_master_create_domain(master);
    if(domain == NULL)
    {
        printf("EtherCAT domain creation failed!\n");
        ret = 1;
        goto CLEANUP;
    }

    ret = ecrt_master(master, &master_info);
    if(ret != 0)
    {
        printf("EtherCAT master information request failed!\n");
        ret = -ret;
        goto CLEANUP;
    }

    /* allocate momory for slave information */
    slave_count = master_info.slave_count;
    slave_info_list = (ec_slave_info_t*)malloc(sizeof(ec_slave_info_t) * slave_count);

    /* configure slaves */
    for(i = 0; i < slave_count; i++)
    {
        ret = ecrt_master_get_slave(master, i, &slave_info_list[i]);
        if(ret != 0)
        {
            printf("EtherCAT slave information request failed!\n");
            ret = -ret;
            goto CLEANUP;
        }

        slave = ecrt_master_slave_config(master, 0, i, slave_info_list[i].vendor_id,
            slave_info_list[i].product_code);
        if(slave == NULL)
        {
            printf("EtherCAT slave configuration failed!\n");
            ret = 1;
            goto CLEANUP;
        }
    }

    /* setup PDO registration array */
    for(i = 0; pdo_entry_reg[i].index != 0; i++)
    {
        if(pdo_entry_reg[i].position < slave_count)
        {
            pdo_entry_reg[i].vendor_id =
                slave_info_list[pdo_entry_reg[i].position].vendor_id;
            pdo_entry_reg[i].product_code =
                slave_info_list[pdo_entry_reg[i].position].product_code;
        }
    }

    /* get PDO entry list */
    ret = ecrt_domain_reg_pdo_entry_list(domain, pdo_entry_reg);
    if(ret != 0)
    {
        printf("EtherCAT PDO registration failed!\n");
        goto CLEANUP;
    }

    /* create real-time periodic task */
    rt_task_plc = (RT_TASK*)malloc(sizeof(RT_TASK));
    ret = rt_task_create(rt_task_plc, "rt_task_plc", 0, 50, T_JOINABLE);
    if(ret != 0)
    {
        printf("Real-time task creation failed!\n");
        goto CLEANUP;
    }

    /* activate EtherCAT master */
    ret = ecrt_master_set_send_interval(master, INTERVAL);
    if(ret != 0)
    {
        printf("EtherCAT setting send interval failed!\n");
        ret = -ret;
        goto CLEANUP;
    }

    ret = ecrt_master_activate(master);
    if(ret != 0)
    {
        printf("EtherCAT master activation failed!\n");
        ret = -ret;
        goto CLEANUP;
    }

    /* get PDO domain pointer */
    domain_pd = ecrt_domain_data(domain);
    if(domain_pd == NULL)
    {
        printf("EtherCAT mapping process data failed!\n");
        ret = 1;
        goto CLEANUP;
    }

    /* start real-time periodic task */
    ret = rt_task_start(rt_task_plc, &rt_task_proc, rt_task_plc);
    if(ret != 0)
    {
        printf("Real-time task start failed!\n");
        goto CLEANUP;
    }
    rt_task_join(rt_task_plc);

CLEANUP :
    if(slave_info_list != NULL)
        free(slave_info_list);
    if(rt_task_plc != NULL)
        free(rt_task_plc);

    if(master != NULL)
        ecrt_release_master(master);

    return ret;
}

static void rt_task_proc(void *arg)
{
    int sw, led;
    int count = 0;

    RT_TASK* rt_task_plc = (RT_TASK*)arg;
    RTIME current_time = rt_timer_read();

    /* set real-time task timer */
    rt_task_set_periodic(rt_task_plc, current_time + INTERVAL,
        rt_timer_ns2ticks(INTERVAL));

    while(alive)
    {
        /* retrieve */
        ecrt_master_receive(master);
        ecrt_domain_process(domain);
        sw = EC_READ_BIT(domain_pd + slave0_6000_01, slave0_6000_01_bit);

        /* computation */
        if(sw)
        {
            if(++count >= 500)
            {
                led = !led;
                count = 0;
            }
        }
        else
        {
            led = 0;
            count = 0;
        }

        /* publish */
        EC_WRITE_BIT(domain_pd + slave0_7010_01, slave0_7010_01_bit, led);        ecrt_domain_queue(domain);
        ecrt_master_send(master);

        /* wait until next period */
        rt_task_wait_period(NULL);
    }
}

static void sigint_handler(int sig)
{
    alive = 0;
}
{% endhighlight %}

## 설명

본 예제 코드는 slave 장치의 스위치가 on 상태인 경우 LED를 1Hz로 깜빡이게 하는 응용이다.<br>
IgH와 같은 역할을 하는 SOEM을 활용한 마스터 예제 코드와 비교해서 IgH가 더 성능도 좋고 기능도 많기 때문인지 예제 코드의 양이 많은 편이다.

## 마스터 초기화

{% highlight c %}
master = ecrt_request_master(0);
domain = ecrt_master_create_domain(master);
ecrt_master(master, &master_info);
slave_count = master_info.slave_count;
{% endhighlight %}

마스터 초기화는 현재 프로그램이 실행되고 있는 마스터 장치에서 0번 EtherCAT 인터페이스에 대한 오브젝트`master`를 받아온 후 그에 대한 도메인 오브젝트`domain`을 받는 것으로 이루어진다. 마스터 오브젝트`master`가 마스터 장치를 의미한다면, 도메인`domain`은 주기적으로 통신할 데이터(PDO)들을 의미한다.<br>
마스터 오브젝트의 필드는 IgH 라이브러리 내에서만 접근할 수 있도록 감추어져 있기 때문에 슬레이브 장치의 수 등 정보를 알기 위해서는 `ecrt_master()`로 마스터 오브젝트의 정보를 받아와야 한다. 슬레이브 장치의 수는 `master_info.slave_count`를 통해 알 수 있다.

## 슬레이브 초기화

{% highlight c %}
for(i = 0; i < slave_count; i++)
{
    ecrt_master_get_slave(master, i, &slave_info_list[i]);
    ecrt_master_slave_config(master, 0, i, slave_info_list[i].vendor_id,
        slave_info_list[i].product_code);
}
{% endhighlight %}

슬레이브 초기화를 위한 함수 `ecrt_master_slave_config()`는 초기화하려는 슬레이브의 Vendor ID와 Product code를 필요로 한다. 해당 정보는 `ecrt_master_get_slave()` 함수로 얻어올 수 있다.<br>
본 예제와 같이 슬레이브로부터 필요한 정보를 받아와서 초기화를 하는 방법이 있고 마스터에서 미리 설정된 정보를 이용하여 직접 초기화 하는 방법이 있다. 전자의 경우 슬레이브 내에 설정 정보들이 저장되어 있는 SII(Slave Information Interface)로부터 마스터가 초기화에 필요한 정보를 읽어 초기화가 이루어지며, 후자의 경우 사용자가 특정 슬레이브의 정보가 XML 포맷으로 정의된 ESI 파일을 마스터 프로그램(예를 들어 TwinCAT과 같은 프로그램)을 통해 입력하여 초기화가 이루어진다.

## 입출력(PDO) 설정

{% highlight c %}
static ec_pdo_entry_reg_t pdo_entry_reg[] = {
    {0, 0, 0x0, 0x0, 0x6000, 1, &slave0_6000_01, &slave0_6000_01_bit},
    {0, 0, 0x0, 0x0, 0x7010, 1, &slave0_7010_01, &slave0_7010_01_bit},
    {}
};
ecrt_domain_reg_pdo_entry_list(domain, pdo_entry_reg);
{% endhighlight %}

주기적으로 통신할 데이터를 정의하는 입출력 설정으로는 `ec_pdo_entry_reg_t` 타입의 구조체와 `ecrt_domain_reg_pdo_entry_list()` 함수가 사용된다. `ec_pdo_entry_reg_t` 구조체는 ecrt.h 파일에 다음과 같이 정의되어 있다.

{% highlight c %}
typedef struct {
    uint16_t alias;
    uint16_t position;
    uint32_t vendor_id;
    uint32_t product_code;
    uint16_t index;
    uint8_t subindex;
    unsigned int *offset;
    unsigned int *bit_position;
} ec_pdo_entry_reg_t;

{% endhighlight %}

alias와 position을 통해 어떤 슬레이브 장치인지 특정한다. `vendor_id`와 `product_code`는 특정한 슬레이브에 대한 정보로, 해당 슬레이브의 정보와 일치해야 한다. 예제 코드에서는 `ecrt_master_get_slave()` 함수를 통해 얻은 정보를 이용하여 이 값을 초기화하는 코드가 있다. `index`와 `subindex`는 특정한 슬레이브 장치에서 통신할 OD(Object Dictionary)의 index와 subindex를 의미한다. 이와 같은 정보를 입력한 구조체의 배열을 정의한 후 `ecrt_domain_reg_pdo_entry_list()` 함수를 호출하면 해당 구조체의 마지막 두 필드에 PDO 엔트리의 byte offset과 bit position이 저장된다. 이 값은 추후에 입출력을 위해 사용된다.

## 마스터 활성화

{% highlight c %}
ecrt_master_set_send_interval(master, INTERVAL);
ecrt_master_activate(master);
domain_pd = ecrt_domain_data(domain);
{% endhighlight %}

마스터가 통신할 주기를 설정하고 활성화한다. 통신할 주기는 `ecrt_master_set_send_interval()` 함수를 통해 설정할 수 있으며, 두 번째 인자에 주기를 나노초 단위로 입력하면 된다. 이후에 `ecrt_master_activate()` 함수를 통해 마스터 장치를 활성화한다. 활성화 이후에는 실시간 context로 전환되며 `malloc()`이나 대부분의 IgH 라이브러리 함수들을 포함하는 비실시간 함수들의 사용은 제한된다. 이 함수가 호출된 이후에는 실시간 함수들만 사용할 수 있다.<br>
`ecrt_domain_data()` 함수는 인자로 전달된 도메인에 대한 데이터 필드의 포인터를 받아온다. 이 값도 추후에 입출력을 위해 사용된다.

## 실행 단계

{% highlight c %}
while(alive)
{
    /* retrieve */
    ecrt_master_receive(master);
    ecrt_domain_process(domain);
    sw = EC_READ_BIT(domain_pd + slave0_6000_01, slave0_6000_01_bit);

    /* computation */
    /* write some computation code... */

    /* publish */
    EC_WRITE_BIT(domain_pd + slave0_7010_01, slave0_7010_01_bit, led);
    ecrt_domain_queue(domain);
    ecrt_master_send(master);

    /* wait until next period */
}

{% endhighlight %}

실행 단계에서는 `ecrt_master_set_send_interval()` 함수를 통해 설정한 주기마다 \[retrieve\] - \[computation\] - \[publish\]를 반복한다.<br>
retrieve에서는 `ecrt_mater_receive()` 함수와 `ecrt_domain_process()` 함수가 기본적으로 필요하며, 앞서 입출력 설정에서 입력으로 설정한 데이터를 슬레이브로부터 받아오는 것으로 구성된다. 데이터를 받아오는 기능은 ecrt.h에 매크로로 정의되어 있으며 데이터의 타입별로 매크로가 따로 정의되어 있다. (`EC_READ_BIT` 등) 이 매크로를 사용할 때 마스터 활성화 단계에서 얻은 도메인 데이터 필드의 포인터(`domain_pd`)와 함께 입출력 설정에서 `ecrt_domain_reg_pdo_entry_list()` 함수를 통해 얻은 byte offset과 bit position이 사용된다.<br>
computation에서는 retrieve에서 읽어오는 데이터를 토대로 publish에서 쓸 데이터를 계산한다. 이 위치의 코드는 응용에 따라 자유롭게 구성된다.<br>
publish에서는 retrieve와 반대로 먼저 `EC_WRITE_BIT` 등의 매크로로 도메인 데이터 필드에 값을 쓴 다음 `ecrt_domain_queue()` 함수와 `ecrt_master_send()` 함수를 통해 그 값을 슬레이브로 출력한다.
