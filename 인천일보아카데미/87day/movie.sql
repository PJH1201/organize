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
DELETE schedules;
commit;