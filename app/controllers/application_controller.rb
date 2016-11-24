class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  
  # API Configuring
  # Song - jacket images of ERROR(no ready) song
  $noReadyJacket_600 = "https://scontent.xx.fbcdn.net/v/t1.0-9/15095721_1099306143519780_6966671705149925303_n.jpg?oh=d69e37d5e799c027f0d10ac0405ba314&oe=58C6FE81"
  $noReadyJacket_200 = "https://scontent.xx.fbcdn.net/v/t1.0-9/15170869_1099307433519651_7878652462893903239_n.jpg?oh=e1b27cbecfebd16f7cc4dbd11e2918be&oe=58C5E7EF"
  $noReadyJacket_100 = "https://scontent.xx.fbcdn.net/v/t1.0-9/15181138_1099308300186231_4990169546164635716_n.jpg?oh=c126e3c992d0526fb55fddb28ce31fa6&oe=58CC6F17"

  $onLoadingImg_600 = "https://scontent.xx.fbcdn.net/v/t1.0-9/15192547_1099306146853113_4842344464639567613_n.jpg?oh=f8d11b4f25e1399ade2d56ffbaee1757&oe=58D283B1"
  $onLoadingImg_200 = "https://scontent.xx.fbcdn.net/v/t1.0-9/15203363_1099307436852984_4613974185785380546_n.jpg?oh=bdffea4d86c104f893d6ead1e60aa92d&oe=58C9552C"
  $onLoadingImg_100 = "https://scontent.xx.fbcdn.net/v/t1.0-9/15171032_1099308303519564_8621030248640251868_n.jpg?oh=5580858221c7a39cc32cb82fe016b86f&oe=58B4E914"

  # Main Banner
  $contents = [
        [
            "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/service_landing1-e1475689497196.png",
            #"https://fullstack-64a3b.firebaseapp.com/images/redgo_main.png",
            "당신이 아직 불러보지 못한 좋은 노래가 많아요!",
            "\n\t\t\t고래방 사용방법을 밀어서 확인하세요 >"
        ],
        [
            "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/service_landing1-e1475689497196.png",
            #"https://fullstack-64a3b.firebaseapp.com/images/redgo_main.png",
            "\t\t\t먼저, 나만의 노래방 라인업! 마이리스트 기능!",
            "\n\t\t\t\t\t\t\t\t불러보고싶은 노래를 발견한다면 
             \n\t\t\t\t\t언제든지 흰색 상자아이콘을 Tab! Tab!"
        ],
        [
            "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/service_landing1-e1475689497196.png",
            #"https://fullstack-64a3b.firebaseapp.com/images/redgo_main.png",
            "\t\t\t\t\t\tSTEP 1. 애창곡을 통해 자신을 알려주세요~!!",
            "\n\t\t\t\t\t\t\t\t\t\t\t\t우선 TOP100 인기차트와 신곡, \n\t\t\t\t\t\t\t\t\t\t\t검색을 통해 애창곡을 담아주세요~"
        ],
        [
            "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/service_landing1-e1475689497196.png",
            #"https://fullstack-64a3b.firebaseapp.com/images/redgo_main.png",
            "\t\t\t\tSTEP 2. 자신을 충분히 알려주셨나요? 뤠디??",
            "\n\t\t\t\t\t\t\t\t\t애창곡 열 다섯개만 채워줘요~ 
             \n\t\t추천받을때 등줄기 오싹하게 해줄께요~ 흐흐"
        ],
        [
            "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/service_landing1-e1475689497196.png",
            #"https://fullstack-64a3b.firebaseapp.com/images/redgo_main.png",
            "\t\t\tSTEP 3. 오직 나를 위한 고래방의 선곡 준비끝!",
            "\n\t\t\t\t\t고래방 추천! 인생곡하나 겟 하고 가실께요! 
             \n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t하단 추천탭 ㄱㄱ~"
        ],
        [
            "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/service_landing1-e1475689497196.png",
            #"https://fullstack-64a3b.firebaseapp.com/images/redgo_main.png",
            "\t\t\t\t\t\t\t\tSTEP 4. 어, 이게뭐야. 마음에 안드신다구요?",
            "\n\t\t\t마음에 안드는 노래는 블랙리스트에 고이 묻어두세요. 
             \n\t\t\t\t\t\t\t\t\t\t\t\t\t\t이제 괴롭히지 않을꺼에요ㅠ"
        ],
        [
            "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/service_landing1-e1475689497196.png",
            #"https://fullstack-64a3b.firebaseapp.com/images/redgo_main.png",
            "\t\tSTEP 5. 아직 많이 부족할거에요! 어설프고 오작동까지 으으ㅠ",
            "\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t그치만 이제 시작인걸요? 
             \n\t\t\t\t\t\t\t앞으로 고래방이 발전하는 모습 많이 응원해주세요!>< "
        ],
        [
            "http://fourd.dothome.co.kr/wp-content/uploads/2016/10/service_landing1-e1475689497196.png",
            "\t\t\t\t\t\t\t나만의 노래방 비밀무기, 고래방!",
            "\n\t\t각종 제보/문의 또는 사소한 아이디어라도 
             \n\t\t\t'셋팅'>'문의하기'를 통해 말씀해주신다면
             \n\t\t\t\t넘나 감사한것!! 추첨을 통해 선물까지!
             \n\t\t\t\t\t\t\t\t고래방, 함께 만들어주세요><!"
        ]
  ]
end
