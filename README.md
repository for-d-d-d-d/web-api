# Welcom to GoraeBang!

          -.     .-
            '. .'
              |
     ,-----.  |
    : . .   `.|   .--.
    |         `--'  .'
    ' '--'    ...   '.    
     `-----`'''   '-..'
    -----------------------------------------------------------------


# ﻿■ Server API Index
#### ver.0.0.2
( _2nd_ // updated_at: 2016-07-27 20:30:05 )
- (0.0.1) 회원가입 (Finished_at: 2016-07-29)
- (0.0.2) 로그인 (Finished_at: 2016-07-29)
- (0.0.3-0) 회원데이터
- (0.0.4-0) 로그아웃


```ruby
    "ver.A.B.C-D" 의 표현은 다음과 같다.
    A = A차 완성본
    B = B번째 모듈 또는 프로젝트
    C = C번째 세부기능
    D = D=0 if 미완성
        D=1 if 피드백대기
        D=2 if 피드백반영 후 완성대기
        D= none if 완성(Client에서 완벽히 동작하는 것을 확인할 것)
```
---


## __| 회원가입(0.0.1) |__



### 요청(Request)
  - Method: '__POST__'
  - Url: "__/json/regist__"


### 예제(Example)
  - to GET method example


    http://api.goraebang.com/json/regist?user[email]=이메일&user[name]=이름&user[password]=패스워드&user[password_confirmation]=패스워드확인&authNum=인증코드


### 매개변수(Parameters)

key | value | desc
------ | ------ | ---
user[email] | 사용자 이메일 |  필수,<br> 이메일 양식
user[name] | 사용자 닉네임 | 필수
user[password] | 패스워드 | 필수, <br> 6자이상의 문자+숫자
user[password_confirmation] | 패스워드 확인 | 필수, <br> 패스워드 값과 동일
authNum | 인증코드 | 필수, <br> 승인된 접속자를 식별


### 반환(RETURN)

- Type: __'json'__
- Read : ``{"result" : 성공여부, "id": 가입한 회원 id(고유식별자)}``
  - 성공 ex) ``{"result":"SUCCESS", "id":"1"}``
  - 실패 ex) ``{"result":"ERROR", "id":"ERROR"}``
- __성공 요건__
  1. 가입자 이메일이 기존 회원과 중복되지 않을 때
  2. 패스워드와 패스워드 확인 문자열이 일치할 때

---


## __| 로그인(0.0.2) |__



### 요청(Request)
  - Method: '__POST__'
  - Url: "__/json/login__"


### 예제(Example)
  - to GET method example


    http://api.goraebang.com/json/login?user[email]=이메일&user[password]=패스워드&authNum=인증코드'


### 매개변수(Parameters)

key | value | desc
------ | ------ | ---
user[email] | 사용자 이메일 |  필수,<br> 이메일 양식
user[password] | 패스워드 | 필수, <br> 6자이상의 문자+숫자
authNum | 인증코드 | 필수, <br> 승인된 접속자를 식별


### 반환(RETURN)

- Type: __'json'__
- Read : ``{"result" : 성공여부, "id": 가입한 회원 id(고유식별자)}``
  - 성공 ex) ``{"result":"SUCCESS", "id":"1"}``
  - 실패 ex) ``{"result":"ERROR", "id":"ERROR"}``
- __성공 요건__
  1. 접속자 이메일이 회원DB 내에 존재할 때 (__탈퇴하지 않은 가입자__)
  2. 접속자 이메일과 패스워드가 DB상의 것과 일치할 때 (__계정확인__)

---


## __| 회원데이터(0.0.3-0) |__

---


# Todo
  - [x]로그인
  - [ ]로그아웃
  - [ ]이달의 신곡페이지를 jQuery써가지고 구현해 보시오. 밑에 언더바가 잘 보이게! - Yong-Hyun Kim
  - [ ].... <br/>

### Information
 ~~프로필 정보 기입에 대한 ‘Progress Bar’를 도입해서 프로필 정보 입력 수준을 비약적으로 끌어올릴 수 있었음~~
> (위에 이거 뭔소리임;;; 언제 누가 왜 썼는지 모르겠음ㄷㅋ)
