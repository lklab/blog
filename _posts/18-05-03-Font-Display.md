---
title: 임베디드 환경에서 폰트 출력하기
image: /assets/post/18-05-03-Font-Display/oled.jpg
author: khlee
categories:
    - Embedded
layout: post
---

디스플레이에 문자열을 픽셀 단위로 처리하여 출력하는 알고리즘을 개발하기 위해 먼저 각 문자별로 비트맵이 정의된 C 배열이 필요하다.

C 배열을 구하기 위해 열심히 구글링을 하던 중 굉장한 것을 찾았다.

[https://www.mikroe.com/glcd-font-creator](https://www.mikroe.com/glcd-font-creator)

GLCD Font Creator라는 프로그램인데, 시스템에 정의된 폰트와 스타일, 크기를 설정하면 그에 맞는 C 배열을 생성해 준다.

생성된 C 배열의 구조는 다음과 같다.

![generated c array]({{site.baseurl}}/assets/post/18-05-03-Font-Display/20180504_121423.png)

C 배열에서 각각의 줄은 줄 끝에 주석으로 설명된 문자에 해당하는 비트맵이고 순서는 아스키 코드를 따른다.

각각의 줄에서 가장 첫 번째 바이트는 개별 비트맵의 가로 픽셀 길이를 의미한다. 모든 문자의 비트맵은 가로, 세로가 고정된 고정길이로 정의되는데 (그림 예시에서는 7x15 픽셀), 가변길이로 출력하고 싶은 경우 첫 번째 바이트를 보고 비트맵의 특정 부분만 추려서 출력하면 된다.

나머지는 비트맵인데, 왼쪽 위부터 세로로 8비트씩 한 바이트이고 바이트 index는 수직 방향이 우선이다. 한 바이트의 8개 픽셀에서 가장 위쪽 픽셀이 LSB이고 아래쪽 픽셀이 MSB이다.

예를 들어 'a' 문자의 경우 첫 번째 바이트인 0x06은 비트맵 중 폰트가 정의된 가로 픽셀 수를 의미하고 나머지는 다음과 같이 비트맵 데이터를 담고 있다.

![generated c array: a character]({{site.baseurl}}/assets/post/18-05-03-Font-Display/20180504_134433.png)

![bit align]({{site.baseurl}}/assets/post/18-05-03-Font-Display/bit_align.png)

따라서 byte 3의 경우 0x06이고 이 값이 배열의 5번째 바이트(index=4)에 존재하는 것을 알 수 있다.

비트맵이 정의된 C 배열을 얻었으니 이제 이 배열을 해석하여 특정 픽셀에 값을 써 주는 알고리즘을 개발하면 된다. 다음은 그 코드이다.

{% highlight c %}
#define LCD_WIDTH 256
#define LCD_HEIGHT 64

int draw_string(const char* string, int base_x, int base_y,
    const unsigned char* font, int width, int height, int start, int end,
    int spacing, int line_spacing, int monospace)
{
    int x, y;
    int cur_x, cur_y, char_x, char_y;

    int height_byte = (height + 7) / 8;
    int entry_size = height_byte * width + 1;

    int index;
    int bitmap_width;
    const unsigned char* bitmap = NULL;

    unsigned char data;
    unsigned char bit_index;
    unsigned char bit;

    char_x = base_x;
    char_y = base_y;
    cur_x = char_x;
    cur_y = char_y;

    if((cur_y + height) > LCD_HEIGHT)
        return -1; /* out of LCD size */
    if(width <= -spacing)
        return -1; /* invalid argument */

    while(*string != '\0')
    {
        /* new line character */
        if(*string == '\n')
        {
            char_x = base_x;
            cur_x = char_x;
            char_y += height + line_spacing;
            cur_y = char_y;
            string++;
            continue;
        }

        if(*string < start || *string > end)
        {
            string++;
            continue; /* invalid character */
        }

        /* get character data */
        index = *string - start;
        if(monospace)
            bitmap_width = width;
        else
            bitmap_width = font[entry_size * index];
        bitmap = &(font[entry_size * index + 1]);

        if(char_x + bitmap_width > LCD_WIDTH)
            return -1; /* out of LCD size */

        /* draw character */
        for(x = 0; x < bitmap_width; x++)
        {
            for(y = 0; y < height_byte; y++)
            {
                data = bitmap[x * height_byte + y];

                for(bit_index = 0; bit_index < 8; bit_index++)
                {
                    if((y * 8 + bit_index) >= height)
                        break; /* skip unused bits */

                    bit = data & 0x01;
                    data >>= 1;

                    /*
                     * TODO: Implement draw_pixel() function
                     * for your target system.
                     */
                    draw_pixel(cur_x, cur_y, bit);
                    cur_y++;
                }
            }
            cur_x++;
            cur_y = char_y;
        }

        /* process the next character */
        char_x += bitmap_width + spacing;
        cur_x = char_x;
        string++;
    }

    return 0;
}
{% endhighlight %}

이 코드를 사용하기 위해서는 다음을 수정해야 한다.

1. `LCD_WIDTH`와 `LCD_HEIGHT`를 타겟 디스플레이의 가로/세로 픽셀 길이로 정의
2. `draw_pixel()` 함수를 각자 타겟 디스플레이에 맞는 코드로 구현

`int draw_pixel(x, y, bit)` 함수는 디스플레이의 왼쪽 위를 (0, 0) 좌표로 정의했을 때 (x, y) 위치에 해당하는 픽셀을 bit 값으로 설정하는 함수이다. bit는 0 또는 1이 입력된다.

이 코드의 파라미터에 대한 설명은 다음과 같다.

1. `string`: 출력할 문자열 (`'\0'` 문자로 끝나는)
2. `base_x`: 문자열의 왼쪽 위 점이 위치할 디스플레이 상의 x 좌표
3. `base_y`: 문자열의 왼쪽 위 점이 위치할 디스플레이 상의 y 좌표
4. `font`: 앞에서 GLCD font creator를 통해 생성한 C 배열
5. `width`: 폰트의 가로 픽셀 길이
6. `height`: 폰트의 세로 픽셀 길이
7. `start` 폰트에 정의된 시작 문자의 아스키 코드
8. `end`: 폰트에 정의된 끝 문자의 아스키 코드
9. `spacing`: 자간
10. `line_spacing`: 줄 간격
11. `monospace`: 1이면 고정길이 출력 0이면 가변길이 출력

파라미터가 많은데, 기존 코드에서는 구조체를 통해 함수를 호출하도록 하였으나 설명을 위해 하나하나 풀어서 작성하였다.

`width`, `height`는 폰트의 가로 및 세로 픽셀 수이다. GLCD font creator에서 생성하는 C 배열은 가변길이 폰트라도 크기가 가장 큰 문자를 기준으로 가로 및 세로 픽셀 수가 모든 문자에 대해 고정으로 정의된다. (빈 부분의 픽셀 값은 0)

`start`, `end`의 경우 GLCD font creator에서 C 배열을 생성할 때 메모리 절약을 위해 사용하지 않는 아스키 코드 구간을 삭제하고 비트맵을 생성하도록 설정할 수 있는데, 여기서 생성하도록 설정된 아스키 코드 구간의 첫 문자가 `start`이고, 마지막 문자가 `end`이다.<br>
기본 설정의 경우 32 ~ 127 구간의 C 배열을 생성하므로 `start=32`, `end=127`을 지정하면 된다.

`spacing`, `line_spacing`: 자간과 줄간격도 설정할 수 있도록 구현하였다.<br>
`monospace`: 가변길이 문자열을 고정길이로 출력할 경우 어색하기 때문에 `monospace` 파라미터를 사용하여 어떤 방식으로 출력할지 설정하도록 하였다.

위 함수의 사용 예는 다음과 같다.

{% highlight c %}
draw_string("Hello\nWorld!", 0, 0, consolas7x15, 7, 15, 32, 127, 0, 0, 1);
{% endhighlight %}
