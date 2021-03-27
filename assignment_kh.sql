1. 첫번째 테이블 명 : EX_MEMBER
* MEMBER_CODE(NUMBER) - 기본키                       -- 회원전용코드 
* MEMBER_ID (varchar2(20) ) - 중복금지                  -- 회원 아이디
* MEMBER_PWD (char(20)) - NULL 값 허용금지                 -- 회원 비밀번호
* MEMBER_NAME(varchar2(30))                             -- 회원 이름
* MEMBER_ADDR (varchar2(100)) - NULL값 허용금지                    -- 회원 거주지
* GENDER (char(3)) - '남' 혹은 '여'로만 입력 가능             -- 성별
* PHONE(char(11)) - NULL 값 허용금지                   -- 회원 연락처


2. EX_MEMBER_NICKNAME 테이블을 생성하자. (제약조건 이름 지정할것)
(참조키를 다시 기본키로 사용할 것.)
* MEMBER_CODE(NUMBER) - 외래키(EX_MEMBER의 기본키를 참조), 중복금지       -- 회원전용코드
* MEMBER_NICKNAME(varchar2(100)) - 필수                       -- 회원 이름



create table ex_member (
    member_code number,                                 -- 회원전용코드 
    member_id varchar2(20)  not null,                   -- 회원 아이디
    member_pwd char(20) not null,                       -- 회원 비밀번호
    member_name varchar2(30),                           -- 회원 이름
    member_addr varchar2(100) not null,                   -- 회원 거주지
    gender char(3)  not null,                              -- 성별
    phone char(11) not null,                                 -- 회원 연락처
    constraint pk_ex_member_code primary key(member_code),
    constraint uq_ex_member_id unique(member_id),
    constraint ck_ex_member_gender check(gender in ('남','여'))
);
comment on table ex_member is '회원관리테이블';
comment on column ex_member.member_code is '회원전용코드';
comment on column ex_member.member_id is '회원 아이디';
comment on column ex_member.member_pwd is '회원 비밀번호';
comment on column ex_member.member_code is '회원 비밀번호';
comment on column ex_member.member_name is '회원 이름';
comment on column ex_member.member_addr is '회원 거주지';
comment on column ex_member.gender is '전화번호';
comment on column ex_member.phone is '회원 연락처';


create table ex_member_nickname(
    member_code number constraint pk_ex_member_nickname primary key 
                        constraint fk_ex_member_nickname references ex_member(member_code),
    member_nickname varchar2(100) not null
);
comment on table ex_member_nickname is '회원별칭관리테이블';
comment on column ex_member_nickname.member_code is '회원전용코드';
comment on column ex_member_nickname.member_nickname is '회원 별칭';
--테이블 주석 조회
select *
from user_tab_comments
where table_name in ('EX_MEMBER','EX_MEMBER_NICKNAME');
--컬럼 주석 조회
select *
from user_col_comments
where table_name in ('EX_MEMBER','EX_MEMBER_NICKNAME');
--EX_MEMBER 제약조건 조회
select A.owner, 
    A.table_name, 
    B.column_name,
    constraint_name,
    A.constraint_type,
    A.search_condition
from user_constraints A join user_cons_columns B
    using(constraint_name)
where A.table_name = 'EX_MEMBER';
--EX_MEMBER_NICKNAME 제약조건 조회
select A.owner, 
    A.table_name, 
    B.column_name,
    constraint_name,
    A.constraint_type,
    A.search_condition
from user_constraints A join user_cons_columns B
    using(constraint_name)
where A.table_name = 'EX_MEMBER_NICKNAME';

