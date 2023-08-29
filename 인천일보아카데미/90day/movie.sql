--영화 정보 테이블
CREATE TABLE MOVIES(
    MVCODE NCHAR(7),            -- 영화 코드(MV0001)
    MVTITLE NVARCHAR2(50),      -- 제목
    MVDIRECTOR NVARCHAR2(100),   -- 감독
    MVACTORS NVARCHAR2(200),    -- 배우
    MVGERNE NVARCHAR2(200),     -- 장르
    MVINFO NVARCHAR2(200),      -- 기본정보
    MVOPEN DATE,                -- 개봉일
    MVPOSTER NVARCHAR2(200),    -- 포스터URL
    MVSTATE NCHAR(1)            -- 상태(1,0)
);

ALTER TABLE MOVIES
ADD CONSTRAINT PK_MOVIES PRIMARY KEY(MVCODE);

ALTER TABLE MOVIES
MODIFY MVTITLE NOT NULL;

ALTER TABLE MOVIES
ADD CONSTRAINT UK_MOVIES UNIQUE(MVTITLE, MVOPEN);

SELECT * FROM MOVIES;
DESC MOVIES;

DELETE from MOVIES;
drop table MOVIES;
commit; 

--극장코드, 극장이름, 극장주소, 전화번호, 극장정보, 이미지

CREATE TABLE THEATERS(
    THCODE NCHAR(7),        --코드
    THNAME NVARCHAR2(50),   --이름
    THADDR NVARCHAR2(200),  --주소
    THTEL NVARCHAR2(50),    --전화번호
    THINFO NVARCHAR2(200),  --정보
    THIMG NVARCHAR2(500)    --이미지
);

ALTER TABLE THEATERS
ADD CONSTRAINT PK_THEATERS PRIMARY KEY (THCODE);

ALTER TABLE THEATERS
ADD CONSTRAINT UK_THNAME UNIQUE (THNAME);

SELECT * FROM THEATERS;

-- 극장이름, 영화제목, 월일시간, 상영관

CREATE TABLE SCHEDULES(
    MVCODE NCHAR(7),       --영화코드 ( FK_MOVIES(MVCODE))
    THCODE NCHAR(7),       --극장코드 ( FK_THEATERS(THCODE))
    SCHALL NVARCHAR2(50),  --상영관
    SCDATE DATE            --예매 가능한 날짜 및 시간

);

ALTER TABLE SCHEDULES
ADD CONSTRAINT PK_SCHEDULES PRIMARY KEY(THCODE, SCHALL, SCDATE)
ADD CONSTRAINT FK_SCHEDULES_MVCODE FOREIGN KEY(MVCODE)
REFERENCES MOVIES(MVCODE)
ADD CONSTRAINT FK_SCHEDULES_THCODE FOREIGN KEY(THCODE)
REFERENCES THEATERS(THCODE);

ALTER TABLE SCHEDULES
MODIFY MVCODE NOT NULL;

INSERT INTO SCHEDULES(MVCODE, THCODE, SCHALL, SCDATE)
VALUES(
        (SELECT MVCODE FROM MOVIES WHERE MVTITLE = '오펜하이머'),
        (SELECT THCODE FROM THEATERS WHERE THNAME = 'CGV강남'),
        '1관 6층',
        TO_DATE('20230824 16:30','YYYYMMDD HH24:MI:SS')
        );

DESC SCHEDULES;
SELECT * FROM SCHEDULES;

-- 스케쥴이 등록된 영화 목록
SELECT *
FROM MOVIES
WHERE MVCODE IN ( SELECT MVCODE
                  FROM SCHEDULES
                  WHERE SCDATE > SYSDATE
                  GROUP BY MVCODE)
AND MVSTATE = '1';


-- 스케줄이 등록된 극장 목록

SELECT *
FROM THEATERS
WHERE THCODE IN ( SELECT THCODE
                  FROM SCHEDULES
                  WHERE SCDATE > SYSDATE
                  GROUP BY THCODE);
                  
-- 예약 가능한 날짜 목록
SELECT TO_CHAR(SCDATE,'MM/DD') AS SCDATE
FROM SCHEDULES
WHERE SCDATE > SYSDATE
GROUP BY TO_CHAR(SCDATE,'MM/DD')
ORDER BY SCDATE;
                
-- 예매 페이지 (영화 목록, 극장 목록 출력)
-- 예매할 영화를 선택 >> CONTROLLER 영화코드 전송
-- >> 선택한 영화를 예매할 수 있는 극장목록 조회

SELECT *
FROM THEATERS
WHERE THCODE IN ( SELECT THCODE
                  FROM SCHEDULES
                  WHERE SCDATE > SYSDATE AND MVCODE ='MV00028'
                  GROUP BY THCODE);                  

-- 예매 페이지 (영화 목록, 극장 목록 출력)
-- 예매할 영화를 선택 >> CONTROLLER 극장코드 전송
-- >> 선택한 영화를 예매할 수 있는 영화목록 조회

SELECT *
FROM MOVIES
WHERE MVCODE IN ( SELECT MVCODE
                  FROM SCHEDULES
                  WHERE SCDATE > SYSDATE
                  AND THCODE = 'TH00001'
                  GROUP BY MVCODE)
AND MVSTATE = '1';

-- '타겟' 'MV00004', 'CGV 구로' 'TH00004'
-- 예매 가능한 날짜 조회

SELECT TO_CHAR(SCDATE,'MM/DD') AS SCDATE
FROM SCHEDULES
WHERE SCDATE > SYSDATE AND MVCODE = 'MV00021' AND THCODE = 'TH00004'
GROUP BY TO_CHAR(SCDATE,'MM/DD')
ORDER BY SCDATE;

--'타겟' 'MV00004', 'CGV구로' 'TH00004','20230830'
SELECT SCHALL, TO_CHAR(SCDATE,'HH24:MI') AS SCDATE
FROM SCHEDULES
WHERE SCDATE > SYSDATE AND MVCODE = 'MV00022' AND THCODE = 'TH00003'
AND TO_CHAR(SCDATE, 'YYYYMMDD') = '20230827';



-- 예매 정보 테이블
CREATE TABLE RESERVES(
    RECODE NCHAR(7),      -- 예매코드 (PK)
    MID NVARCHAR2(20),    -- 예매자아이디 ( FK - MEMBERS(MID))
    MVCODE NCHAR(7),      -- 영화코드 ( FK - MOVIES(MVCODE))
    THCODE NCHAR(7),      -- 극장코드 ( FK - SCHEDULES)
    SCHALL NVARCHAR2(50), -- 상영관   ( FK - SCHEDULES)
    SCDATE DATE,          -- 상영시작 날짜 (FK - SCHEDULES)
    REDATE DATE           -- 예매날짜
);

-- 예매 정보 테이블 제약 조건
ALTER TABLE RESERVES
ADD CONSTRAINT PK_RESERVES PRIMARY KEY(RECODE)
ADD CONSTRAINT FK_RESERVES_MID FOREIGN KEY(MID)
    REFERENCES MEMBERS(MID)
ADD CONSTRAINT FK_RESERVES_MVCODE FOREIGN KEY(MVCODE)
    REFERENCES MOVIES(MVCODE)
ADD CONSTRAINT FK_RESERVES_SCHEDULES FOREIGN KEY(THCODE, SCHALL, SCDATE)
    REFERENCES SCHEDULES(THCODE, SCHALL, SCDATE);

-- 회원정보 테이블
CREATE TABLE MEMBERS(
    MID NVARCHAR2(20),      -- 회원 아이디(PK)
    MPW NVARCHAR2(20),      -- 비밀번호(NOT NULL)
    MNAME NVARCHAR2(50),    -- 이름
    MEMAIL NVARCHAR2(100),  -- 이메일(UK)
    MDATE DATE,             -- 가입일
    MPROFILE NVARCHAR2(500),-- 프로필이미지
    MSTATE NCHAR(2)        -- 상태( [0]계정상태, [1]연동상태)
);
-- 계정 상태 Y: 이용가능 계정 , N: 정지
-- 연동상태  C: 일반회원, K: 카카오회원
-- MSTATE :: 'YC' : 이용가능한 일반회원
-- MSTATE :: 'YK' : 이용가능한 카카오회원

--회원 정보 테이블 제약조건
ALTER TABLE MEMBERS
ADD CONSTRAINT PK_MEMBERS PRIMARY KEY(MID)
ADD CONSTRAINT PK_MEMAIL UNIQUE(MEMAIL);

ALTER TABLE MEMBERS
MODIFY MPW NOT NULL
MODIFY MNAME NOT NULL;

-- 관람평 테이블
CREATE TABLE REVIEWS(
    RVCODE NCHAR(7),           --리뷰코드(PK)
    RECODE NCHAR(7),           --예매코드(FK - RESERVE(RECODE))
    MID NVARCHAR2(20),         --작성자아이디(FK - MEMBERS(MID))
    RVCOMMENT NVARCHAR2(1000), --리뷰내용
    RVDATE DATE               --작성일
);
ALTER TABLE REVIEWS
ADD CONSTRAINT PK_REVIEWS PRIMARY KEY(RVCODE)
ADD CONSTRAINT FK_REVIEWS_RECODE FOREIGN KEY(RECODE)
    REFERENCES RESERVES(RECODE)
ADD CONSTRAINT FK_REVIEWS_MID FOREIGN KEY(MID)
    REFERENCES MEMBERS(MID);

UPDATE SCHEDULES
SET SCDATE = SCDATE +7;


SELECT * FROM MOVIES
WHERE ROWNUM BETWEEN 1 AND 10
ORDER BY MVOPEN DESC;

SELECT MVTITLE, MVOPEN FROM MOVIES
ORDER BY MVOPEN DESC;


SELECT * FROM MEMBERS;
DESC MEMBERS;
SELECT * FROM reserves;
DESC RESERVES;
SELECT * FROM REVIEWS;
DESC REVIEWS;

SELECT * FROM MOVIES WHERE MVCODE = 'MV00022';

SELECT * FROM MOVIES;                
SELECT * FROM SCHEDULES;
select * from theaters;
commit;
