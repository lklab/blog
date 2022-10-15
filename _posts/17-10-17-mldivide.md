---
title: "mldivide ('\\')를 활용한 linear regression"
image: /assets/post/17-10-17-mldivide/mldivide.jpeg
author: khlee
categories:
    - Machine Learning
layout: post
---

## 정의

행렬 왼쪽 나눗셈(mldivide, \\)은 행렬 $$A$$, $$X$$, $$Y$$로 이루어진 다음 시스템에 대해

$$A \times X = Y$$

다음과 같이 정의된다.

$$A \setminus Y = X $$

$$A \times (A \setminus Y) = Y$$

A가 역행렬이 존재하는 정사각 행렬일 경우 다음과 같이 계산할 수 있다.

$$A \setminus Y = A^{-1} \times Y = X$$

그러나 mldivide는 A의 역행렬이 존재하지 않거나 심지어 정사각 행렬이 아닐 경우에도 정의되는데, 이를 계산하기 위해 다음 링크에 있는 MATLAB 문서는 다음과 같이 그 알고리즘을 설명하고 있다.

[https://kr.mathworks.com/help/matlab/ref/mldivide.html#bt4jslc-6](https://kr.mathworks.com/help/matlab/ref/mldivide.html#bt4jslc-6)

복잡한 알고리즘은 모두 A가 정사각 행렬인 경우에 대한 내용이고, 정사각 행렬이 아닌 경우 QR solver로 해결하도록 되어 있다. MATLAB에는 mldivide 연산에 위와 같은 알고리즘이 구현되어 있어서, 이를 통해 정사각 행렬이 아닌 경우에도 연산이 가능하며, 나아가 linear regression도 mldivide로 계산할 수 있다.

## 의미

$$
\begin{bmatrix}
    a_{1,1} & a_{1,2} & \cdots & a_{1,m}\\
    a_{2,1} & a_{2,2} & \cdots & a_{2,m}\\
    \vdots & \vdots & \ddots & \vdots\\
    a_{n,1} & a_{n,2} & \cdots & a_{n,m}
\end{bmatrix}
\setminus
\begin{bmatrix}
    y_{1,1} & y_{1,2} & \cdots & y_{1,l}\\
    y_{2,1} & y_{2,2} & \cdots & y_{2,l}\\
    \vdots & \vdots & \ddots & \vdots\\
    y_{n,1} & y_{n,2} & \cdots & y_{n,l}
\end{bmatrix}
=
\begin{bmatrix}
    x_{1,1} & x_{1,2} & \cdots & x_{1,l}\\
    x_{2,1} & x_{2,2} & \cdots & x_{2,l}\\
    \vdots & \vdots & \ddots & \vdots\\
    x_{m,1} & x_{m,2} & \cdots & x_{m,l}
\end{bmatrix}
$$

위 그림과 같이 행렬 $$A$$의 크기를 $$n \times m$$, $$Y$$의 크기를 $$n \times l$$로 정의할 경우 $$n$$, $$m$$, $$l$$은 각각 다음을 의미한다.

* $$n$$ : 시스템을 이루는 식의 수
* $$m$$ : 시스템을 이루는 미지수의 수 (차원)
* $$l$$ : 시스템의 개수 (각 시스템은 동일한 계수를 갖지만, 미지수와 상수는 다름)

예를 들어 다음과 같은 시스템에 대해

$$
\begin{cases}
2x+3y-z=5\\
x-y+z=2\\
3x+2y-3z=-2
\end{cases}
$$

행렬로 다음과 같이 표현할 수 있고, mldivide로 해를 구할 수 있다.

$$
\begin{bmatrix}
    2 & 3 & -1\\
    1 & -1 & 1\\
    3 & 2 & -3
\end{bmatrix}
\setminus
\begin{bmatrix}
    5\\
    2\\
    -2
\end{bmatrix}
=
\begin{bmatrix}
    1\\
    2\\ 
    3
\end{bmatrix}
$$

$$n$$과 $$m$$이 동일하면서 $$A$$의 rank가 $$m$$과 같은 경우, 즉 역행렬이 존재하는 경우는 위와 같이 풀이가 가능하다.

그러나 정사각 행렬이 아닌 경우 $$n$$과 $$m$$의 관계에 따라 mldivide는 다음과 같은 의미를 갖는다.

* $$n$$(또는 $$A$$의 rank)이 $$m$$보다 작은 경우 : 무수히 많은 해
* $$n$$이 $$m$$보다 큰 경우 : Least square를 만족하는 Linear regression

$$n$$이 $$m$$보다 작은 경우 mldivide는 다음과 같이 $$m - n$$개에 해당하는 미지수를 $$0$$으로 설정한 후 나머지 미지수에 대한 값을 계산한다.

![mldivide result]({{site.suburl}}/assets/post/17-10-17-mldivide/20171018_111803.png)

## Linear Regression

$$n$$이 $$m$$보다 큰 경우 선형 시스템 상에서는 해가 존재하지 않게 된다. 대신에 mldivide는 Least square를 만족하는 Linear regression으로 동작한다. 따라서 다음 식과 같이 행렬곱이 mldivide의 역연산이 될 수 없다.

$$A \times (A \setminus Y) \neq Y$$

Linear regression의 경우 $$n$$, $$m$$의 의미는 다음과 같이 재 정의될 수 있다. $$l$$은 동일한 데이터, 속성에 대한 단순 반복이므로 중요하지 않다.

* $$n$$ : 데이터의 수
* $$m$$ : 속성의 수

이에 따라 행렬 $$A$$는 기존의 계수 행렬(Coefficient Matrix)에서 각 속성들의 관계를 나타내는 데이터들의 집합, 즉 Training data의 집합으로 재해석할 수 있고, $$Y$$ 행렬도 동일하게 Training data 집합의 속성을 갖는다. Linear regression의 결과인 $$X$$ 행렬은 각 속성들의 가중치를 나타낸다.

가장 간단하게, $$n$$개의 두 속성 $$x$$, $$y$$를 갖는 데이터를 이용하여 다음과 같은 선형 모델로 Regression할 때

$$b+ax=y$$

행렬 $$A$$, $$Y$$와 $$X$$는 다음과 같이 정의된다.

$$
A=
\begin{bmatrix}
    1 & x_{1}\\
    1 & x_{2}\\
    \vdots & \vdots\\
    1 & x_{n}
\end{bmatrix}
Y=
\begin{bmatrix}
    y_{1}\\
    y_{2}\\
    \vdots\\
    y_{n}
\end{bmatrix}
X=
\begin{bmatrix}
    b\\
    a
\end{bmatrix}
$$

행렬 $$A$$는 상수항을 의미하는 $$1$$로 이루어진 열과 각각의 속성에 해당하는 데이터로 이루어진 열들로 구성되며, $$Y$$는 남은 한 속성에 해당하는 데이터로 구성된다. 행렬 $$X$$는 상수항과 속성의 계수로 구성되며, 선형 모델을 나타낸다.

예를 들어서 키와 몸무게 사이의 관계에 관한 Linear regression 문제를 MATLAB을 사용하여 푸는 방법은 다음과 같다.

![linear regression]({{site.suburl}}/assets/post/17-10-17-mldivide/linear_regression.png){: .custom-align-center-img}
*데이터 : [https://github.com/johnmyleswhite/ML_for_Hackers/blob/master/07-Optimization/data/01_heights_weights_genders.csv](https://github.com/johnmyleswhite/ML_for_Hackers/blob/master/07-Optimization/data/01_heights_weights_genders.csv)*{: .custom-caption}

최종적으로 다음과 같은 선형 모델을 얻게 된다.

$$-350.7372+7.7173x_{height}=y_{weight}$$

## 계산

$$n > m$$인 행렬 $$A$$에 대해 일반적인 경우에는 다음과 같이 계산이 가능하다.

$$X = A \setminus Y = (A^{T} \times A)^{-1} \times A^{T} \times Y$$

MATLAB에서는 다음과 같이 입력하면 된다.

{% highlight matlab %}
inv(transpose(A) * A) * transpose(A) * Y
{% endhighlight %}

그러나 다음 행렬과 같이 데이터의 스케일 차이가 큰 경우 부동소수점 연산 정밀도의 한계로, 정확한 해를 구할 수 없게 된다.

![calculation]({{site.suburl}}/assets/post/17-10-17-mldivide/20171018_114105.png)

MATLAB에는 해를 구하기 위해 다음의 여러 가지 방법들을 제공한다.

* QR Solver :<br>
    [Q, R] = qr(A, 0)<br>
    X = R \ (Q' * Y)
* X = pinv(A) * Y
* X = linsolve(A, Y)
* inv(transpose(A) * A) * transpose(A) * Y

앞의 예제를 각각의 방법으로 구한 해와 RMSE는 다음과 같다.

| | exact solution | A \\ Y | QR Solver | pinv | linsolve | transpose |
|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|
| b | 0.0 | -0.0127 | -0.0555 | -0.0313 | -0.0127 | 0.0041 |
| a | 1.0 | 1.0000 | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| RMSE | 0.0 | 0.0078 | 0.0349 | 0.0590 | 0.0078 | 0.1243 |

`A \ Y`와 `linsolve`의 성능이 가장 좋은 것을 확인할 수 있다.

반면 상수항에 비해 데이터가 작은 경우에는 `QR Solver`가 가장 정확했다.

| | exact solution | A \\ Y | QR Solver | pinv | linsolve | transpose |
|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|
| b | 0.0 | -1.05998e-28 | -5.5511e-29 | -8.2740e-29 | -1.05998e-28 | -1.4724e-28 |
| a | 1.0 | 1.0000 | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| RMSE | 0.0 | 5.6798e-29 | 3.1554e-29 | 4.0409e-29 | 5.6798e-29 | 6.1834e-29 |

경우에 따라 다른 방법의 성능이 더 좋을 수 있으며, 데이터의 특성에 따라 적절한 방법을 선택해야 한다.
