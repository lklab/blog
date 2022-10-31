---
title: Unity로 VR 캐릭터 컨트롤하는 앱 개발하기
image: /assets/post/17-10-25-Unity-VR-Controller/unity_vr_controller.jpg
author: khlee
categories:
    - Unity
layout: post
---

## 소개

이번엔 [지난 글]({{ site.baseurl }}{% post_url 17-10-24-Unity-VR-Support %})과 [저번 글]({{ site.baseurl }}{% post_url 17-10-18-Unity-Bluetooth-Controller %})의 내용을 합쳐서 Bluetooth Controller를 통해 1인칭 캐릭터를 컨트롤할 수 있는 VR앱을 만들 것이다.

## 준비

Assets Store에서 [괜찮은 프로젝트](https://www.assetstore.unity3d.com/kr/#!/content/15)를 받아온다.<br>
\- 2018년 11월 현재 위 프로젝트는 서비스되지 않아서 받아올 수 없다.

![sample project]({{site.baseurl}}/assets/post/17-10-25-Unity-VR-Controller/20171024_224745.png)

## 씬 수정

필요없는 부분은 다 지우고 먼저 1인칭 캐릭터 역할을 할 GameObject를 적당한 위치에 적당한 크기로 하나 만든다.

![scene view]({{site.baseurl}}/assets/post/17-10-25-Unity-VR-Controller/20171026_001652.png)

![inspector]({{site.baseurl}}/assets/post/17-10-25-Unity-VR-Controller/20171026_001706.png)

벽과 바닥을 뚫고 다니면 안 되니까 Capsule Collider를 추가하고 물리엔진과 상호작용(중력이라던가 다른 물체와 충돌이라던가)을 할 수 있도록 Rigidbody를 추가한다. 중요한게 Rigidbody에서 Constraints안에 Freeze Rotation의 모든 축을 체크해야 한다. 물리엔진에 의해 캐릭터가 회전하지 않도록 제약을 걸어 두는 것으로, 이렇게 하지 않으면 Capsule Collider의 곡면 때문에 캐릭터가 자기 맘대로 막 굴러다닌다.

그 다음엔 캐릭터 GameObject의 하위 Object로 포함되도록 Camera를 추가한다.

![scene view]({{site.baseurl}}/assets/post/17-10-25-Unity-VR-Controller/20171026_003124.png)

![inspector]({{site.baseurl}}/assets/post/17-10-25-Unity-VR-Controller/20171026_003150.png)

카메라의 위치는 적당히 잡아주면 된다. 단, X와 Z 좌표는 0으로 해 두는 것이 좋다.

## 스크립트 작성

이제 스크립트를 하나 추가한다.

{% highlight csharp %}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof (Rigidbody))]
[RequireComponent (typeof (CapsuleCollider))]

public class BlueControlManager : MonoBehaviour
{
    private GameObject cameraObject;
    private Rigidbody CharacterRigidbody;

    private bool jumpPushed = false;

    // contants
    private float speed = 2.2f;
    private float gravity = 10.0f;
    private bool grounded = false;

    private float maxVelocityChange = 1.5f;

    private float jumpHeight = 0.5f;
    private Vector3 jumpVelocity;

    void Start()
    {
        cameraObject = GameObject.Find("Camera");
        CharacterRigidbody = GetComponent<Rigidbody>();

        // From the jump height and gravity we deduce the upwards speed 
        // for the character to reach at the apex.
        jumpVelocity = new Vector3(0, Mathf.Sqrt(2 * jumpHeight * gravity), 0);
    }
 
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.JoystickButton0))
            jumpPushed = true;
    }

    void FixedUpdate()
    {
        if(grounded)
        {
            // get joystick data
            Vector2 joystickPosition = new Vector2();
            joystickPosition.x = Input.GetAxis("Horizontal");
            joystickPosition.y = Input.GetAxis("Vertical");
            joystickPosition = joystickPosition.normalized;

            // Calculate how fast we should be moving
            Vector3 targetVelocity = new Vector3(0, 0, 0);
            Vector3 forward = new Vector3(0, 0, 0);
            Vector3 right = new Vector3(0, 0, 0);

            forward.x = cameraObject.transform.forward.x;
            forward.z = cameraObject.transform.forward.z;
            right.x = cameraObject.transform.right.x;
            right.z = cameraObject.transform.right.z;
            forward = forward.normalized;
            right = right.normalized;
            targetVelocity = forward * joystickPosition.y + right * joystickPosition.x;
            targetVelocity *= speed;

            // Apply a force that attempts to reach our target velocity
            Vector3 velocity = CharacterRigidbody.velocity;
            Vector3 velocityChange = (targetVelocity - velocity);
            velocityChange.x = Mathf.Clamp(velocityChange.x,
                -maxVelocityChange, maxVelocityChange);
            velocityChange.z = Mathf.Clamp(velocityChange.z,
                -maxVelocityChange, maxVelocityChange);
            velocityChange.y = 0;
            CharacterRigidbody.AddForce(velocityChange, ForceMode.VelocityChange);

            // Jump
            if(jumpPushed)
                CharacterRigidbody.AddForce(jumpVelocity, ForceMode.VelocityChange);
        }

        grounded = false;
        jumpPushed = false;
    }
 
    void OnCollisionStay(Collision collisionInfo)
    {
        foreach(ContactPoint contact in collisionInfo.contacts)
        {
            if(contact.normal.y > 0.7f)
            {
                grounded = true;
                break;
            }
        }
    }
}
{% endhighlight %}

주요 특징

1. UI 처리는 `Update()` 함수에서, 물리적 처리는 `FixedUpdate()` 함수에서 한다.<br>
`Update()` 함수는 프레임마다 한 번 호출되며, 초당 프레임의 변화에 따라 호출 주기가 달라지는 반면 `FixedUpdate()` 함수는 호출 주기가 일정하다. `Input.GetKeyDown()` 함수는 버튼이 눌린 시점의 프레임에서만 true를 반환한다. 따라서 `FixedUpdate()` 함수에서 `Input.GetKeyDown()` 함수로 값을 읽어오는 경우 프레임 타이밍에 따라 버튼을 눌러도 `true`값을 읽지 못할 수도 있다. 반면에 물리적 처리는 호출 주기가 일정한 `FixedUpdate()` 함수에서 처리해야 자연스럽게 동작하며 그렇지 않고 `Update()` 함수에서 처리할 경우 초당 프레임 변화에 따라 다르게 동작할 것이다.

2. 캐릭터를 움직일 때는 `rigidbody`의 `AddForce()` 함수 사용<br>
캐릭터를 움직이는 방법, 즉 캐릭터의 위치를 바꾸는 방법은 위치 자체를 바꾸는 방법, 속도를 바꾸는 방법, 힘(가속도)를 주는 방법의 세 가지가 있다. 위치 자체를 바꾸는 것은 캐릭터가 순간이동하는 것으로 구현될 것이며, 속도를 바꾸거나 힘을 주어야 위치가 연속적으로 변할 것이다. 힘을 주는 방법이 위치와 속도가 연속적으로 변하는 것이므로 가장 자연스럽게 동작할 것이다.

3. `grounded` (캐릭터가 땅을 밟고 서 있는지) 판단 조건<br>
캐릭터의 Collider가 다른 Collider와 접촉할 때 호출되는 `OnCollisionStay()` 함수에서 항상 `grounded`를 `true`로 바꾸도록 하면 벽과 접촉할 때에도 땅을 밟고 있다고 판단하여 벽타기가 가능하다. 따라서 `OnCollisionStay()` 함수의 인자로 주어지는 Collision 정보 내에서 다른 Collider와 접촉한 방향이 옆쪽이 아닌 아래쪽 방향이 있는 경우에만 땅을 밟고 있다고 판단하게 한다.

## 플레이 영상

<iframe class="video" src="https://www.youtube.com/embed/6hyWDXpkXFM" allowfullscreen frameborder="0"></iframe>
