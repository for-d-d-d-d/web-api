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
( _2nd_ // updated_at: 2016-08-08 04:35:05 )
- (0.0.1) 회원가입 (Finished_at: 2016-07-29)
- (0.0.2) 로그인 (Finished_at: 2016-07-29)
- (0.0.3-0) 회원데이터
- (0.0.4-0) 로그아웃
- (0.0.5-0) 실행 시 첫 화면 
- (0.0.6-0) 이 달의 신규 등록
- (0.0.7-0) 검색(검색 엔진 연구)
- (0.0.8-1) 마이리스트 create
- (0.0.9-1) 마이리스트 read
- (0.0.10-1) 마이리스트 update
- (0.0.11-1) 마이리스트 delete
- (0.0.12-1) 마이리스트 내부 노래 create
- (0.0.13-1) 마이리스트 내부 노래 read
- (0.0.14-1) 마이리스트 내부 노래 update
- (0.0.15-1) 마이리스트 내부 노래 delete
- (0.0.16-1) 노래 차단
- (0.0.17-1) 차단된 노래 read
- (0.0.18-1) 차단된 노래 delete(차단해제)
- (0.0.19-0) 개인정보 변경
- (0.0.20-0) 회원 탈퇴


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


## __| 마이리스트 CREATE(0.0.8-1) |__



### 요청(Request)
  - Method: '__POST__'
  - Url: "__/json/myList_create__"


### 예제(Example)
  - to GET method example


    http://api.goraebang.com/json/myList_create?id=회원ID&title=myList타이틀&authNum=인증코드'


### 매개변수(Parameters)

key | value | desc
------ | ------ | ---
id | 사용자 레코드 id값 |  필수
title | myList 타이틀 | 필수, <br>조건없음
authNum | 인증코드 | 필수, <br> 승인된 접속자를 식별


### 반환(RETURN)

- Type: __'json'__
- Read : ``{"id": 가입한 회원 id(고유식별자), "message" : 성공여부}``
  - 성공 ex) ``{"id":"1", "message":"SUCCESS"}``
  - 실패 ex) ``{"id":"ERROR", "message":"ERROR"}``
- __성공 요건__
  1. 파라미터가 전부 존재할 때 (__통신상태만 CHECK__)


---


## __| 마이리스트 READ(0.0.9-1) |__



### 요청(Request)
  - Method: '__POST__'
  - Url: "__/json/myList_read__"


### 예제(Example)
  - to GET method example


    http://api.goraebang.com/json/myList_read?id=회원ID&authNum=인증코드'


### 매개변수(Parameters)

key | value | desc
------ | ------ | ---
id | 사용자 레코드 id값 |  필수
authNum | 인증코드 | 필수, <br> 승인된 접속자를 식별


### 반환(RETURN)

- Type: __'json DATA-SET'__
- Read : ``[{"id": 마이리스트 id(고유식별자), "title": 마이리스트 타이틀}...{}]``
- __성공 요건__
  1. 가입된 회원


---


## __| 마이리스트 UPDATE(0.0.10-1) |__



### 요청(Request)
  - Method: '__POST__'
  - Url: "__/json/myList_update__"


### 예제(Example)
  - to GET method example


    http://api.goraebang.com/json/myList_update?id=회원ID&myList_id=수정할myListID&title=수정할myList타이틀&authNum=인증코드'


### 매개변수(Parameters)

key | value | desc
------ | ------ | ---
id | 사용자 레코드 id값 |  필수
myList_id | myList id값 |  필수
title | 수정할 타이틀 | 필수, <br>조건없음
authNum | 인증코드 | 필수, <br> 승인된 접속자를 식별


### 반환(RETURN)

- Type: __'json'__
- Read : ``{"id": 변경된 myList id(고유식별자), "message" : 성공여부}``
  - 성공 ex) ``{"id":"1", "message":"SUCCESS"}``
  - 실패 ex) ``{"id":"1", "message":"ERROR"}``
- __성공 요건__
  1. 파라미터가 전부 존재할 때 (__통신상태만 CHECK__)
  2. 요청한 리스트가 내 계정에 존재하는 리스트가 맞을 때


---


## __| 마이리스트 DELETE(0.0.11-1) |__



### 요청(Request)
  - Method: '__POST__'
  - Url: "__/json/myList_delete__"


### 예제(Example)
  - to GET method example


    http://api.goraebang.com/json/myList_delete?id=회원ID&myList_id=삭제하려는myListID&authNum=인증코드'


### 매개변수(Parameters)

key | value | desc
------ | ------ | ---
id | 사용자 레코드 id값 |  필수
myList_id | 삭제하려는myList ID | 필수
authNum | 인증코드 | 필수, <br> 승인된 접속자를 식별


### 반환(RETURN)

- Type: __'json DATA-SET'__
- Read : ``[{"id": 마이리스트 id(고유식별자), "title": 마이리스트 타이틀}...{}]``
- __성공 요건__
  1. 파라미터가 전부 존재할 때 (__통신상태만 CHECK__)
  2. 요청한 리스트가 내 계정에 존재하는 리스트가 맞을 때


---


## __| 마이리스트 내부 노래 CREATE(0.0.12-1) |__



### 요청(Request)
  - Method: '__POST__'
  - Url: "__/json/mySong_create__"


### 예제(Example)
  - to GET method example


    http://api.goraebang.com/json/mySong_create?id=회원ID&myList_id=소속될myListID&song_id=추가할songID&authNum=인증코드'


### 매개변수(Parameters)

key | value | desc
------ | ------ | ---
id | 사용자 레코드 id값 |  필수
myList_id | 소속될myListID | 필수
song_id | 추가할songID | 필수
authNum | 인증코드 | 필수, <br> 승인된 접속자를 식별


### 반환(RETURN)

- Type: __'json'__
- Read : ``{"id": 생성된 레코드 id(고유식별자), "message" : 성공여부}``
  - 성공 ex) ``{"id":"1", "message":"SUCCESS"}``
  - 실패 ex) ``{"id":"", "message":"ERROR"}``
- __성공 요건__
  1. 파라미터가 전부 존재할 때 (__통신상태만 CHECK__)


---


## __| 마이리스트 내부 노래 READ(0.0.13-1) |__



### 요청(Request)
  - Method: '__POST__'
  - Url: "__/json/mySong_read__"


### 예제(Example)
  - to GET method example


    http://api.goraebang.com/json/mySong_read?id=회원ID&myList_id=읽어들일myListID&authNum=인증코드'


### 매개변수(Parameters)

key | value | desc
------ | ------ | ---
id | 사용자 레코드 id값 |  필수
myList_id | 읽어들일 myList ID | 필수
authNum | 인증코드 | 필수, <br> 승인된 접속자를 식별


### 반환(RETURN)

- Type: __'json DATA-SET'__
- Read : ``[{"id": mySong 레코드 id(고유식별자), "mylist_id": 소속된 myList레코드 외래 키, "song_id": Song레코드의 외래 키}...{}]``
- __성공 요건__
  1. 가입된 회원


---


## __| 마이리스트 내부 노래 UPDATE(0.0.14-1) |__



### 요청(Request)
  - Method: '__POST__'
  - Url: "__/json/mySong_update__"


### 예제(Example)
  - to GET method example


    http://api.goraebang.com/json/mySong_update?id=회원ID&myList_id=현재소속된myListID&targetList_id=이동할myListID&mySong_id=수정하려는mySongID&authNum=인증코드'


### 매개변수(Parameters)

key | value | desc
------ | ------ | ---
id | 사용자 레코드 id값 |  필수
myList_id | 현재소속된 myList ID |  필수
targetList_id | 이동할 myList ID |  필수
mySong_id | 수정하려는 mySong ID | 필수
authNum | 인증코드 | 필수, <br> 승인된 접속자를 식별


### 반환(RETURN)

- Type: __'json'__
- Read : ``{"id": 변경된 mySong_id(고유식별자), "message" : 성공여부}``
  - 성공 ex) ``{"id":"1", "message":"SUCCESS"}``
  - 실패 ex) ``{"id":"1", "message":"ERROR"}``
- __성공 요건__
  1. 파라미터가 전부 존재할 때 (__통신상태만 CHECK__)
  2. 현재 소속 리스트와 이동할 타겟 리스트가 서로 다를 때


---


## __| 마이리스트 내부 노래 DELETE(0.0.15-1) |__



### 요청(Request)
  - Method: '__POST__'
  - Url: "__/json/mySong_delete__"


### 예제(Example)
  - to GET method example


    http://api.goraebang.com/json/mySong_delete?id=회원ID&mySong_id=삭제하려는mySongID&authNum=인증코드'


### 매개변수(Parameters)

key | value | desc
------ | ------ | ---
id | 사용자 레코드 id값 |  필수
mySong_id | 삭제하려는 mySong ID | 필수
authNum | 인증코드 | 필수, <br> 승인된 접속자를 식별


### 반환(RETURN)

- Type: __'json DATA-SET'__
- Read : ``[{"id": mySong 레코드 id(고유식별자), "mylist_id": 소속된 myList레코드 외래 키, "song_id": Song레코드의 외래 키}...{}]``
- __성공 요건__
  1. 파라미터가 전부 존재할 때 (__통신상태만 CHECK__)
  2. 요청한 노래의 소속 리스트가 내 계정에 존재하는 리스트가 맞을 때


---


# Todo
  - [x]로그인
  - [ ]로그아웃
  - [ ]이달의 신곡페이지를 jQuery써가지고 구현해 보시오. 밑에 언더바가 잘 보이게! - Yong-Hyun Kim
  - [ ].... <br/>

### Information
 ~~프로필 정보 기입에 대한 ‘Progress Bar’를 도입해서 프로필 정보 입력 수준을 비약적으로 끌어올릴 수 있었음~~
> (위에 이거 뭔소리임;;; 언제 누가 왜 썼는지 모르겠음ㄷㅋ)
