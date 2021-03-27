-------------------------------------------------------------------------------------------------------------
-- UNIQUE
-------------------------------------------------------------------------------------------------------------
--이메일, 주민번호, 닉네임
--전화번호는 UQ 사용하지말것(전화번호를 변경하는 경우도 자주생기므로)
--중복허용하지않음(다른행의 컬럼과 중복허용하지않음)

create table tb_cons_uq (
    no number not null,
    email varchar2(50) ,
    constraint uq_email unique(email)      --테이블레벨에 작성
);

insert into tb_cons_uq values(1,'abc@naver.com');
insert into tb_cons_uq values(2,'가나다@naver.com');
--insert into tb_cons_uq values(3,'abc@naver.com'); --ORA-00001: unique constraint (KH.UQ_EMAIL) violated
insert into tb_cons_uq values(4,null); --null값은 허용

select *
from tb_cons_uq;

--------------------------------------------------------------------------------------------------------------
--PRIMARY KEY
--------------------------------------------------------------------------------------------------------------
--레코드(행) 식별자
--not null + unique기능을 가지고 있으며 테이블당 1개만 설정 가능

create table tb_cons_pk(
    id varchar2(50),
    name varchar2(100) not null,
    email varchar2(200),
    constraint pk_id primary key(id), --테이블레벨에 작성
    constraint uq_email2 unique(email)
);

select *
from tb_cons_pk;

insert into tb_cons_pk
values('hoggd', '홍길동', 'hgd@naver.com');

insert into tb_cons_pk
values(null, '홍길동', 'hgd@naver.com'); --null값 대입불가(not null)

--제약조건검색
select constraint_name,
        uc.table_name,
        ucc.column_name,
        uc.constraint_type,
        uc.search_condition
from user_constraints uc
    join user_cons_columns ucc
        using(constraint_name)
where uc.table_name = 'TB_CONS_PK';

--복합 기본키(주키 | primary key | pk)
--여러컬럼을 조합해서 하나의 PK로 사용
--사용된 컬럼 하나라도 null이어서는 안된다

create table tb_order_pk(
    user_id varchar2(50),
    order_date date,
    amount number default 1 not null,
    constraint pk_user_id_order_date primary key(user_id, order_date) --user_id와 order_date를 하나로 묶어서 pk로 사용
);

--order_date 에서 시분초정보가 다르므로 계속해서 같은것을 추가할수있다.
--단 1초에 여러번추가하는경우 오류발생할수있음
insert into tb_order_pk
values ( 'hoggd', sysdate, 3);

select user_id,
        to_char(order_date, 'yyyy/mm/dd hh24:mi:ss'),
        amount
from tb_order_pk;


insert into tb_order_pk
values (null, sysdate, 3); --오류발생(pk로 null값이 사용될수없으므로)

-------------------------------------------------------------------------------------------------------------------------
--FOREIGN KEY
-------------------------------------------------------------------------------------------------------------------------
--참조 무결성을 유지하기 위한 조건
--참조하고 있는 부모테이블의 지정 컬럼값 중에서만 값을 취할수있게 하는것
--참조하고 있는 부모테이블의 지정컬럼은 PK, UQ제약조건이 걸려있어야한다
--department.dept_id(부모테이블)를 참조하고 있는 employee.dept_code(자식테이블)
--자식테이블의 컬럼에 외래키(FOREIGN KEY) 제약조건을 지정

create table shop_member(
    member_id varchar2(20),
    member_name varchar2(30) not null,
    constraint pk_shop_member_id primary key(member_id)
);

insert into shop_member values ('hoggd', '홍길동');
insert into shop_member values ('sinsa', '신사');
insert into shop_member values ('sejong', '세종');

select * from shop_member;

drop table shop_buy;

create table shop_buy(
    buy_no number,
    member_id varchar2(20),
    product_id varchar2(50),
    buy_date date default sysdate,
    constraint pk_shop_buy_no primary key(buy_no),
    constraint fk_shop_buy_member_id foreign key(member_id) references shop_member(member_id) on delete cascade
);

insert into shop_buy values(1, 'hoggd', 'soccer_shoes', default);
insert into shop_buy values(2, 'sinsa', 'basketball_shoes', default);
--ORA-02291: integrity constraint (KH.FK_SHOP_BUY_MEMBER_ID) violated - parent key not found 무결성제약조건위반
insert into shop_buy values(3, 'k123', 'football_shoes', default);

select * from shop_buy;
    

--fk기준으로 join -> relation
--구매번호 회원아이디 회원이름 구매물품아이디 구매시각
select buy_no,
        member_id,
        member_name,
        product_id,
        to_char(buy_date,'yyyy/mm/dd hh24:mi:ss')
from shop_buy
    join shop_member
        using(member_id);

--삭제 옵션
--on delete restricted : 기본값. 참조하는 자식행이 있는경우, 부모행 삭제불가
--                            자식행을 먼저 삭제후 부모행을 삭제
--on delete set null : 부모행 삭제시 자식컬럼은 null로 변경(자식테이블에작성)
--on delete cascade : 부모행 삭제시 자식행 삭제(자식테이블에작성)

delete from shop_member
where member_id = 'hoggd';
--ORA-02292: integrity constraint (KH.FK_SHOP_BUY_MEMBER_ID) violated - child record found
--참조하는 자식행이 있다면 부모행 삭제불가 ----> 자식행 삭제후 부모행 삭제


--정규화 작업
--이상현상(데이터무결성이 깨질 가능성) 방지 -> 별도의 코드로 관리(fk)
--정규화작업을 하지 않으면(테이블쪼개지않고 다 한테이블에 썼을때) 부서이름을 고칠때 2000줄을 고쳐야한다면
--정귷화작업을 하면(테이블을 쪼개서 fk로 테이블을 연결)1줄만 고치면됨 -> 데이터무결성 깨질확률 낮음



--식별관계 | 비식별관계
--비식별관계 : 참조하고있는 부모컬럼값을 PK로 사용하지않는경우, 여러행에서 참조가 가능한 1:N관계(중복허용)
--식별관계 : 참조하고있는 부모컬럼값을 다시 PK로 사용하는 경우, 부모행-자식행사이에 1:1관계(중복x)

create table shop_nickname(
    member_id varchar2(20),
    nickname varchar2(100),
    constraint fk_member_id foreign key(member_id) references shop_member(member_id),
    constraint pk_member_id primary key(member_id)
);

insert into shop_nickname
values('sinsa', '신솨'); --다시 같은것을 추가할수없다

select *
from shop_nickname;

------------------------------------------------------------------------------------------------------------------------------
--CHECK
------------------------------------------------------------------------------------------------------------------------------
--해당 컬럼의 값 범위를 지정
--null 입력가능

drop table tb_cons_ck;
create table tb_cons_ck(
    gender char(1),
    num number,
    constraint ck_gender check(gender in ('M','F')),
    constraint ck_num check(num between 0 and 100)
);

insert into tb_cons_ck
values('M',50);
insert into tb_cons_ck
values('F',100);

insert into tb_cons_ck
values('m',50); --ORA-02290: check constraint (KH.CK_GENDER) violated
insert into tb_cons_ck
values('M',1000); --ORA-02290: check constraint (KH.CK_NUM) violated


--------------------------------------------------------------------------------------------------------------------
-- CREATE
--------------------------------------------------------------------------------------------------------------------
-- subquery를 이용한 create는 not null 제약조건을 제외한 모든 제약조건, 기본값등을 제거한다

create table emp_bck
as
select * from employee;

select * from emp_bck;

-- 제약조건검색
select constraint_name,
        uc.table_name,
        ucc.column_name,
        uc.constraint_type,
        uc.search_condition
from user_constraints uc
    join user_cons_columns ucc
        using(constraint_name)
where uc.table_name = 'EMP_BCK'; --employee테이블을 복사했지만 not null 제약조건외에 제약조건들이 날아간다

--기본값 확인
select *
from user_tab_cols
where table_name = 'EMP_BCK'; --기본값(default)도 다 날라감



--------------------------------------------------------------------------------------------------------------------
-- ALTER
--------------------------------------------------------------------------------------------------------------------
-- table 관련 alter문은 컬럼, 제약조건에 대해 수정이 가능
/*
서브명령어 

-add 컬럼, 제약조건 추가
-modify 컬럼(자료형, 기본값) 변경. 단, 제약조건은 변경불가
--rename 컬럼명, 제약조건명 변경
--drop 컬럼, 제약조건 삭제
*/

create table tb_alter (
    no number
);

-- add 컬럼
-- 맨 마지막 컬럼으로 추가
alter table tb_alter add name varchar2(100) default '기본값' not null;

desc tb_alter;
select * from tb_alter;



-- add 제약조건
-- not null 제약조건은 추가가 아닌 수정(modify)으로 처리
alter table tb_alter
add constraint pk_tb_alter_no primary key(no);

-- 제약조건 조회
select constraint_name,
        uc.table_name,
        ucc.column_name,
        uc.constraint_type,
        uc.search_condition
from user_constraints uc
    join user_cons_columns ucc
        using(constraint_name)
where uc.table_name = 'TB_ALTER'; 

-- modify 컬럼
-- 자료형, 기본값, null 여부변경가능
-- 문자열에서 호환가능타입으로 변경가능 (char --- varchar2)
alter table tb_alter
modify name varchar2(500) default '홍길동' null;

-- 행이 있다면 변경하는데 제한이 있다
-- 존재하는 값보다는 작은 크기로 변경불가
-- null값이 있는 컬럼은 not null로 변경불가 (데이터무결성 깨짐)

-- modify 제약조건은 불가능
-- 제약조건은 이름 변경외에 변경불가
-- 변경하려면 해당제약조건 삭제후 재생성할것

-- rename 컬럼
alter table tb_alter
rename column no to num; --no컬럼을 num으로 변경


-- rename 제약조건

select constraint_name,
        uc.table_name,
        ucc.column_name,
        uc.constraint_type,
        uc.search_condition
from user_constraints uc
    join user_cons_columns ucc
        using(constraint_name)
where uc.table_name = 'TB_ALTER'; 


alter table tb_alter
rename constraint pk_tb_alter_no to pk_tb_alter_num;


-- 테이블 이름 변경
alter table tb_alter
rename to tb_alter_new;

rename tb_alter to tb_alter_new; --이런방법도 가능

-- drop 컬럼
desc tb_alter;

alter table tb_alter
drop column name; --name 컬럼삭제

-- drop 제약조건
alter table tb_alter
drop constraint pk_tb_alter_num; --제약조건삭제



--------------------------------------------------------------------------------------------------------------------
-- DROP
--------------------------------------------------------------------------------------------------------------------
-- 데이터베이스 객체(table, user, view 등) 삭제
drop table tb_alter_new; --테이블 삭제




--============================================================================
-- DCL
--============================================================================
-- Data Control Language
-- 권한 부여/회수 관련 명령어 : grant/revoke
-- TCL(Transaction Control Language)를 포함한다 : commit / rollback / savepoint


-- SYSTEM관리자계정으로 진행----------------------------------------------
-- qwerty계정 생성
create user qwerty
identified by qwerty
default tablespace users;

-- 접속권한 부여
-- create session권한 또는 connect role을 부여
grant connect to qwerty;
--grant create session to qwerty;

-- 객체 생성권한 부여
-- create table, create index...... 권한을 일일이 부여
-- resource role 한번에 다 부여
grant resource to qwerty;
------------------------------------------------------------------------------

--권한, role을 조회
select *
from user_sys_privs; --권한

select *
from user_role_privs; --role

select *
from role_sys_privs; --부여받은 role에 포함된 권한


-- 커피테이블 생성
create table tb_coffee (
    cname varchar2(100),
    price number,
    brand varchar2(100),
    constraint pk_tb_coffee_cname primary key(cname)
);

insert into tb_coffee
values('maxim', 2000, '동서식품');
insert into tb_coffee
values('kanu', 3000, '동서식품');
insert into tb_coffee
values('nescafe', 2500, '네슬레');

select * from tb_coffee;

-- qwerty계정에게 열람권한 부여
grant select on tb_coffee to qwerty;

-- qwerty계정에게 추가,수정,삭제 권한 부여
grant insert, update, delete on tb_coffee to qwerty;

-- 수정권한 회수
revoke insert, update, delete on tb_coffee from qwerty;

-- 열람권한 회수
revoke select on tb_coffee from qwerty;






--======================================================================
-- DATABASE OBJECT 1
--======================================================================
-- DB의 효율적으로 관리하고 작동하게 하는 단위

-- kh계정에서 접근할수있는 객체들을 볼수있다. 그중 하나가 table
select distinct object_type
from all_objects;

----------------------------------------------------------------------------------------------------------------
-- DATA DICTIONARY
----------------------------------------------------------------------------------------------------------------
--일반사용자 관리자로부터 열람 권한을 얻어 사용하는 정보조회테이블
--읽기전용
--객체 관련 작업을 하면 자동으로 그 내용이 반영

--1. user_xxx : 사용자가 소유한 객체에 대한 정보
--2. all_xxx : user_xxx를 포함. 다른 사용자로부터 사용권한을 부여받은 객체에 대한 정보
--3. dba_xxx : 관리자전용. 모든 사용자의 모든 객체에 대한 정보

--이용가능한 모든 dd(data dictionary)조회
select * from dict; --dictionary

--********************************************************************
-- user_xxx
--********************************************************************
-- xxx는 객체이름 복수형을 사용한다

-- user_tables
select * from user_tables; --kh계정의 모든 테이블정보 조회
select * from tabs; --동의어(synonym), 위와 같은 쿼리

-- user_sys_privs : 권한
-- user_role_privs : role(권한묶음)
-- role_sys_privs : 사용자가 가진 role에 포함된 포든 권한
select * from user_sys_privs;
select * from user_role_privs;
select * from role_sys_privs;

-- user_sequences
-- user_views
-- user_indexes
-- user_constraints

--********************************************************************
-- all_xxx
--********************************************************************
-- 현재계정이 소유하거나 사용권한을 부여받은 객체 조회

-- all_tables
select * from all_tables;

-- all_indexes
select * from all_indexes;


--********************************************************************
-- dba_xxx
--********************************************************************

select * from dba_tables; -- 일반사용자는 접근금지(관리자계정에서 해야함)

--특정 사용자의 테이블 조회
select *
from dba_tables
where owner in ('KH', 'QWERTY');

--특정 사용자의 권한 조회
select *
from dba_sys_privs
where grantee = 'KH';

select *
from dba_role_privs
where grantee = 'KH';

-- 테이블 관련 권한 확인
select *
from dba_tab_privs
where owner = 'KH';

-- 관리자가 kh.tb_coffee 읽기, 수정 권한을 qwerty에게 부여
grant select on kh.tb_coffee to qwerty;
grant insert, update, delete on kh.tb_coffee to qwerty;



----------------------------------------------------------------------------------------------------------------
-- STORED VIEW
----------------------------------------------------------------------------------------------------------------
-- 저장뷰
-- INLINE VIEW는 일회성이었지만 이를 객체로 저장해서 재사용이 가능하다
-- 가상테이블처럼 사용하지만 실제로 데이터를 가지고있는것은 아니다
-- 실제테이블과 링크개념

-- 뷰객체를 이용해서 제한적인 데이터만 다른 사용자에게 제공하는것이 가능하다
-- create view 권한을 부여받아야한다(관리자계정에서 부여)
create view view_emp
as
select emp_id,
        emp_name,
        substr(emp_no,1,8) || '******' emp_no,
        email,
        phone
from employee;

-- 테이블처럼 사용하면된다
select * from view_emp;

select *
from (
    select emp_id,
        emp_name,
        substr(emp_no,1,8) || '******' emp_no,
        email,
        phone
    from employee
);

-- dd에서 조회
select * from user_views;

-- 타사용자에게 선별적인 데이터(view_emp)를 제공
-- qwerty는 사원테이블에 접근은 하지만 전부 다 볼수있는것은 아니다
grant select on kh.view_emp to qwerty;

-- view 특징
--1. 실제 컬럼뿐 아니라 가공된 컬럼제공
--2. join을 사용하는 view 제공
--3. or replace 옵션 사용가능
--4. with read only 옵션 - dml못하게

create or replace view view_emp --drop할 필요없이 수정가능
as
select emp_id,
        emp_name,
        substr(emp_no,1,8) || '******' emp_no,
        email,
        phone,
        nvl(dept_title,'인턴') dept_title --dept_title을 추가
from employee E
    left join department D
        on E.dept_code = D.dept_id
with read only;


-- 성별, 나이등 복잡한 연산이 필요한 컬럼을 미리 view 지정해두면 편리하다
create or replace view view_employee_all
as
select E.*,
        decode(substr(emp_no,8,1),'1','남','3','남','여') gender
from employee E;

-- 여자사원만 조회
select *
from view_employee_all
where gender = '여';


----------------------------------------------------------------------------------------------------------------
-- SEQUENCE
----------------------------------------------------------------------------------------------------------------
-- 정수값을 순차적으로 자동생성하는 객체, 채번기(새로운번호를 부여받음)

/*
create sequence 시퀀스명
start with 시작값---------------------------기본값 1
increment by 증가값-----------------------기본값 1
maxvalue 최대값 | nomaxvlaue------------기본값은 nomaxvalue. 최대값에 도달하면 다시 시작값(cycle을 지정했을때) 혹은 에러유발
minvalue 최소값 | nominvlaue-------------기본값은 nominvalue. 최소값에 도달하면 다시 시작값(cycle을 지정했을때) 혹은 에러유발
cycle | cocycle-----------------------------순환여부. 기본값 nocycle
cache 캐싱개수 | nocache-----------------기본값 cache 20. 시퀀스객체로부터 20개씩 가져와서 메모리에서 채번
                                                     오류가 발생하여 숫자를 건너뛸수도 있다
*/

create table tb_names (
    no number,
    name varchar2(100) not null,
    constraints pk_tb_names_no primary key(no)
);

create sequence seq_tb_names_no
start with 1000
increment by 1
nomaxvalue
nominvalue
nocycle
cache 20;

insert into tb_names
values(seq_tb_names_no.nextval, '홍길동'); --번호부여(보통 PK로 설정)

select * from tb_names;

-- 현재 부여된 마지막 번호
select seq_tb_names_no.currval
from dual;

-- dd에서 조회
select * from user_sequences; --LAST_NUMBER : 메모리에서 가져간 마지막번호

-- 복합 문자열에 시퀀스 사용하기
-- 주문번호 kh-20210205-1001

create table tb_order (
    order_id varchar2(50),
    cnt number,
    constraints pk_tb_order_id primary key(order_id)
);

create sequence seq_order_id; --옵션을 기본값으로 설정하려면 생략해도된다 


insert into tb_order
values('kh-' || to_char(sysdate,'yyyymmdd') || '-' || to_char(seq_order_id.nextval, 'FM0000'), 100);

select * from tb_order;

-- alter문을 통해 시작값(start with값)은 절대 변경할수없다. 그때는 시퀀스객체 삭제후 재생성할것
alter sequence seq_order_id increment by 10; -- 증가값을 10으로 변경


----------------------------------------------------------------------------------------------------------------
-- INDEX
----------------------------------------------------------------------------------------------------------------
-- 색인
-- sql문 처리 속도 향상을 위해 컬럼에 대해 생성하는 객체
-- key : 컬럼값, value : 레코드 논리적 주소값 rowid
-- 저장하는 데이터에 대한 별도의 공간이 필요함(view와 다름)

-- 장점 
-- 검색속도가 빨라지고 시스템 부하를 줄여서 성능향상

-- 단점
-- 인덱스를 위한 추가저장공간이 필요함. 
-- 인덱스를 생성/수정/삭제하는데 별도의 시간이 소요됨

-- 단순조회 업무보다 변경작업(insert/update/delete)가 많다면 index 생성을 주의해야한다(데이터가 최소 50만개가 넘을경우)

-- 인덱스로 사용하면 좋은 컬럼
-- 1. 선택도 selectivity가 좋은 컬럼. 중복데이터가 적은 컬럼
--      id | 주민번호 | 전화번호 | email 등
--      pk | uq 제약조건이 사용된 컬럼은 자동으로 인덱스를 생성함 --> 삭제가 안되므로 삭제하려면 제약조건을 삭제해야함
select *
from user_indexes;
-- 2. where절에 자주 사용되어지는 경우, 조인기준컬럼인 경우 
-- 3. 입력된 데이터의 변경이 적은 컬럼


-- 인덱스가 없는 컬럼 job_code
select *
from employee
where job_code = 'J5';
--OPTIONS FULL : table full scan

-- 인덱스가 있는 컬럼 emp_id
select *
from employee
where emp_id = '201';
--OPTIONS UNIQUE SCAN : BY INDEX ROWID (중복값이 없음), 처리비용절감

--emp_name 조회
--원래 index설정안돼있었음
select *
from employee
where emp_name = '송종기';


-- emp_name 컬럼으로 인덱스 생성
select *
from user_indexes
where table_name = 'EMPLOYEE';

create index idx_employee_emp_name
on employee(emp_name); 
-- emp_name cost 1,3 -> 2,1로변경




--======================================================================
-- PL/SQL
--======================================================================
-- Procedural Language/SQL
-- SQL의 한계를 보완해서 SQL문 안에서 변수정의/조건처리/반복처리등의 문법을 지원

-- 유형
-- 1. 익명블럭(Anonymous Block) : PL/SQL 실행 가능한 1회용 블럭
-- 2. Procedure : 특정구문을 모아둔 서브프로그램. DB서버에 저장하고, 클라이언트에 의해 호출실행 
-- 3. Function : 반드시 하나의 값을 리턴하는 서브프로그램. DB서버에 저장하고 클라이언트에 의해 호출/실행
-- 4. trigger
-- 5. scheduler

/*

declare     --1. 변수선언부(선택)

begin       --2. 실행부(필수)
              (조건문, 반복문, 출력문)
exception   --3. 예외처리부(선택)
                (try-catch같은것)
end;        --4. 블럭종료선언(필수)
/     -->끝나는 기호(익명블럭 전체가 끝났다는 의미), 종료/에 라인주석을 작성하지말것.


*/

--세션별로 설정
--서버콘솔 출력모드 지정 ON
set serveroutput on;

begin
    --dms_output패키지의 put_line프로시저 : 출력문(Systemout같은것)
    dbms_output.put_line('Hello PL/SQL');
end;
/

--사원조회
declare
    v_id number;
begin
    select emp_id
    into v_id
    from employee
    where emp_name = '&사원명'; --이름 입력으로 해당사원 사번조회 
    
    dbms_output.put_line('사번 = ' || v_id);

exception
    when no_data_found then dbms_output.put_line('해당이름을 가진 사원이 없습니다');
end;
/


----------------------------------------------------------------------------------------------------------------
-- 변수선언/대입
----------------------------------------------------------------------------------------------------------------
-- 변수명 [constant] 자료형 [not null] [ := 초기값];

declare
    num number := 100; --constant(상수)로 지정하면 값변경 불가 : num constant number := 100;
    name varchar2(100); --name varchar2(100) not null := '홍길동';    not null은 초기값 지정 필수
    result number;

begin
    dbms_output.put_line('num = ' || num); --num = 100
    num := 200;
    dbms_output.put_line('num = ' || num); --num = 200
    name := '&이름';
    dbms_output.put_line('이름 = ' || name);
end;
/

--PL/SQL 자료형
--1. 기본 자료형
--      문자형 : varchar2, char, clob
--      숫자형 : number
--      날짜형 : date
--      논리형 : boolean(true | false | null)

--2. 복합 자료형
--      레코드
--      커서
--      컬렉션

--참조형은 다른 테이블의 자료형을 차용해서 쓸수있다
--1. %type
--2. %rowtype
--3. record


declare
    v_emp_name varchar2(100);
    v_emp_no varchar2(100);
begin
    select emp_name, emp_no
    into v_emp_name, v_emp_no
    from employee
    where emp_id = '&사번';
    
    dbms_output.put_line('이름 : ' || v_emp_name);
    dbms_output.put_line('주민번호 : ' || v_emp_no);
end;
/


declare
    --테이블해당컬럼 타입 지정 가능
    v_emp_name employee.emp_name%type;
    v_emp_no employee.emp_no%type;
begin
    select emp_name, emp_no
    into v_emp_name, v_emp_no
    from employee
    where emp_id = '&사번';
    
    dbms_output.put_line('이름 : ' || v_emp_name);
    dbms_output.put_line('주민번호 : ' || v_emp_no);
end;
/


declare 
    v_emp employee%rowtype; --%rowtype : 테이블 한행을 타입으로 지정, 매번컬럼들을 지정하기보다는 행을 통째로 가져와서 원하는 컬럼값만 출력
begin
    select *
    into v_emp
    from employee
    where emp_id = '&사번';
    
    dbms_output.put_line('이름 : ' || v_emp.emp_name);
    dbms_output.put_line('부서코드 : ' || v_emp.dept_code);
end;
/


--record
--사번, 사원명, 부서명등 employee rowtype에는 존재하지 않는 컬럼조합을 타입으로 선언

declare
    type my_emp_rec is record(
        emp_id employee.emp_id%type,
        emp_name employee.emp_name%type,
        dept_title department.dept_title%type
    ); --타입이 my_emp_rec라는 3가지 컬럼으로 이루어진 한 행(가상의 record)을 만들었다고 보면된다
    my_row my_emp_rec;
begin

    select E.emp_id, E.emp_name, D.dept_title
    into my_row
    from employee E
        left join department D
            on E.dept_code = D.dept_id
    where emp_id = '&사번';
    
    --출력
    dbms_output.put_line('사번 : ' ||  my_row.emp_id);
    dbms_output.put_line('이름 : ' ||  my_row.emp_name);
    dbms_output.put_line('부서명 : ' ||  my_row.dept_title);
end;
/


--사원명을 입력받고 사번, 사원명, 직급명, 부서명을 참조형 변수를 통해 출력하세요

declare
    type my_emp_rec is record(
        emp_id employee.emp_id%type,
        emp_name employee.emp_name%type,
        job_name job.job_name%type,
        dept_title department.dept_title%type
    ); 
    my_row my_emp_rec;
begin
    select E.emp_id, E.emp_name, J.job_name, D.dept_title
    into my_row
    from employee E
        left join department D
            on E.dept_code = D.dept_id
        left join job J
            using(job_code)
     where E.emp_name = '&사원이름';
     
    --출력 
    dbms_output.put_line('사번 : ' ||  my_row.emp_id);
    dbms_output.put_line('이름 : ' ||  my_row.emp_name);
    dbms_output.put_line('직급명 : ' || my_row.job_name);
    dbms_output.put_line('부서명 : ' ||  my_row.dept_title);
end;
/


----------------------------------------------------------------------------------------------------------------
-- PL/SQL 안의 DML
----------------------------------------------------------------------------------------------------------------
-- 이 안에서 commit / rollback 트랜잭션(더 쪼갤수없는 작업단위) 처리까지 해줄것

create table member (
    id varchar2(30),
    pwd varchar2(50) not null,
    name varchar2(100) not null,
    constraint pk_member_id_2 primary key(id)
);



desc member;


begin 
    --insert into member
    --values('hoggd', '1234', '홍길동');
    
    update member set 
    pwd = 'abcd'
    where id = 'hoggd';
    --트랜잭션 처리
    commit;
end;
/

select * from member;


--사용자입력값 받아서 id,pwd,name을 새로운 행으로 추가하는 익명블럭을 작성하세요
begin
    insert into member
    values('&id', '&pwd', '&name');
    commit;
end;
/


select * from emp_copy;
desc emp_copy;
--emp_copy에 사번 마지막번호에 +1 처리한 사번으로 
--이름, 주민번호, 전화번호, 직급코드, 급여등급을 등록하는 PL/SQL 익명블럭 작성하기
declare
    last_num number;
begin
    select emp_id
    into last_num
    from (
                select emp_id
                from emp_copy
                order by 1 desc
            )
    where rownum < 2;

    insert into emp_copy(emp_id, emp_name, emp_no, phone, job_code, sal_level)
    values(last_num+1, '&이름', '&주민번호', '&전화번호', '&직급코드', '&급여등급');
    
    commit;
end;
/



desc emp_copy;
insert into emp_copy(emp_id, emp_name, emp_no, job_code, sal_level)
values('400', '이이이', '900115-1234567', 'J1', 'S1');





---------------------------------------------------------------------------------------
--조건문
---------------------------------------------------------------------------------------
--1. if 조건식 then .... end if;
--2. if 조건식 then .... else ..... end if;
--3. if 조건식1 then .... elsif 조건식2 then ...... end if;

declare 
    name varchar2(100) := '&이름';
begin
    if name = '홍길동' then
        dbms_output.put_line('반갑습니다 홍길동님');
    else
        dbms_output.put_line('누구냐 넌?');
    end if;    
    
    dbms_output.put_line('------------끝-------------');
end;
/



declare 
    num number := &숫자; -- ' '를 안하면 숫자형으로 인식
begin 
    if mod(num,3) = 0 then
        dbms_output.put_line('3의배수를 입력하셨습니다');
    elsif mod(num,3) = 1 then
        dbms_output.put_line('3으로 나눈 나머지가 1입니다');
    elsif mod(num,3) = 2 then
        dbms_output.put_line('3으로 나눈 나머지가 2입니다');    
    end if;
end;
/


--사번을 입력받고 해당사원 직급이 J1이라면 '대표' 출력
--J2라면 '임원'
--그외는 '평사원'이라고 출력하세요

select * from emp_copy;

declare
    num emp_copy.emp_id%type := '&사번';
    v_code emp_copy.job_code%type;
begin
    select job_code
    into v_code
    from emp_copy
    where emp_id = num;


     if v_code = 'J1' then
        dbms_output.put_line('대표');
    elsif v_code = 'J2' then
        dbms_output.put_line('임원');
    else
        dbms_output.put_line('평사원');
        
    end if;
end;
/

---------------------------------------------------------------------------------------
--반복문
---------------------------------------------------------------------------------------
--1. 기본loop - 무한반복(탈출조건식)
--2. while loop - 조건에 따른 반복
--3. for loop - 지정횟수만큼 반복실행

--기본 loop
declare 
    n number := 1;
begin
    loop
        dbms_output.put_line(n);
        n := n+1;
        
        --탈출조건
--        if n > 100 then
--            exit;
--        end if;
        exit when n >100;
    end loop;
end;
/


--난수(실수) 출력
declare
    rnd number;
    n number := 1;
begin
    loop
        --start 이상, end 미만의 난수
        rnd := dbms_random.value(1,11);
--        rnd := trunc(dbms_random.value(1,11)); 정수로 출력하고싶으면 소수점이하 버림 
        dbms_output.put_line(rnd);
        
        n := n + 1;
        exit when n > 10;
    end loop;
end;
/


--while loop

declare
    n number := 0;
begin
    while n < 10 loop
        dbms_output.put_line(n);
        n := n + 1;
    end loop;

end;
/

--짝수만 출력

declare
    n number := 0;
begin
    while n < 10 loop
        if mod(n, 2) = 0 then
            dbms_output.put_line(n);
        end if;
        n := n + 1;
    end loop;

end;
/


--사용자로부터 단수(2~9단)을 입력받아 해당단수의 구구단을 출력하기
--2~9외의 숫자를 입력하면 '잘못입력하셨습니다' 출력후 종료

declare
    dan number := &단수;
    n number := 1;
begin
    if dan between 2 and 9 then
        while n < 10 loop
            dbms_output.put_line(dan || '*' || n || '=' || dan * n );
            n := n + 1;
        end loop;
    else
        dbms_output.put_line('잘못입력하셨습니다');
    end if;
end;
/


-- for ... loop
-- 증감변수를 별도로 선언하지 않아도 된다
-- 자동 증가처리(무조건 1씩증가)
-- reverse 키워드 사용시 1씩 감소

begin
    -- 증감변수 n을 declare절에 선언할필요없이 바로사용가능
    -- 시작값..종료값(시작값 < 종료값)
    for n in 1..5 loop
        dbms_output.put_line(n);
    end loop;
    
--    for n in reverse 1..5 loop
--        dbms_output.put_line(n);
--    end loop;
end;
/

--210 ~ 220번 사이의 사원을 조회(사번, 이름, 전화번호)

declare
    e employee%rowtype; --행변수
begin
    for n in 210..220 loop
        select *
        into e
        from employee
        where emp_id = n;
    
        dbms_output.put_line('사번 : ' || e.emp_id);
        dbms_output.put_line('이름 : ' || e.emp_name);
        dbms_output.put_line('전화번호 : ' || nvl(e.phone,'전화번호없음'));
        dbms_output.put_line(' ');
    end loop;
    
    
end;
/

--@실습문제 : tb_number테이블에 난수 100개(0~999)를 저장하는 익명블럭을 생성하세요
--실행시마다 생성된 모든 난수의 합을 콘솔에 출력할것
--drop table tb_number;
create table tb_number (
    id number, --pk sequence객체로부터 채번
    num number, --난수
    reg_date date default sysdate,
    constraint pk_tb_number_id primary key(id)
);

select * from tb_number;
--truncate table tb_number;
create sequence seq_tb_number_id;
--drop sequence seq_tb_number_id;

declare
    rnd number;
    sum_rnd number := 0;
begin
    for n in 1..100 loop
         rnd := trunc(dbms_random.value(0,1000));
         sum_rnd := sum_rnd + rnd;
         insert into tb_number(id,num)
         values(seq_tb_number_id.nextval, rnd);
    end loop;
    --commit;
    dbms_output.put_line(sum_rnd);
end;
/




--===================================================================================
-- DATABASE OBJECT2
--===================================================================================
-- PL/SQL 문법을 사용하는 객체

-----------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION
-----------------------------------------------------------------------------------------------------------------------------------
-- 문자열 앞뒤에 d..b 헤드폰 씌우기 함수
-- 매개변수, 리턴선언시 자료형 크기지정하지 말것
create or replace function db_func (p_str varchar2)
return varchar2 --무조건 리턴값이 있다
is
    --사용할 지역변수 선언
    result varchar2(1000);
begin
    --실행로직
    result := 'd' || p_str || 'b';
    return result;
end;
/


--실행
--1. 일반 sql문
select db_func(emp_name)
from employee;

--2. 익명블럭/다른 PL/SQL객체 에서 호출가능
set serveroutput on;
begin
    dbms_output.put_line(db_func('&이름'));
end;
/

--3. exec | execute 프로시저/함수 호출하는 명령
var text varchar2; --세션별로 유지되는 변수
exec :text := db_func('신사임당');
print text;

--Data Dictionary에서 확인
select * 
from user_procedures
where object_type = 'FUNCTION';


--성별 구하기 함수
--선언
create or replace function fn_get_gender(p_emp_no employee.emp_no%type)
return varchar2
is
    gender varchar2(3);
begin
    if substr(p_emp_no,8,1) in ('1', '3') then
        gender := '남';
    else
        gender := '여';
    end if;
    
--    type 1
--    case
--        when substr(p_emp_no,8,1) in ('1', '3') then
--            gender := '남';
--        else
--            gender := '여';
--    end case;

--    type 2 : decode와 비슷. 단하나의 계산식만 제공
--    case substr(p_emp_no,8,1)
--        when '1' then gender := '남';
--        when '3' then gender := '남';
--        else gender := '여';
--    end case;
    return gender;
end;
/

--호출
select emp_name,
        fn_get_gender(emp_no) gender
from employee;


--주민번호를 입력받아 나이를 리턴하는 함수 fn_get_age를 작성하고
--사번, 사원명, 주민번호, 성별, 나이 조회(일반 sql문)
create or replace function fn_get_age(p_emp_no employee.emp_no%type)
return number
is
    age number;
begin
    if substr(p_emp_no,8,1) in ('1', '2') then
        age := extract(year from sysdate) - (substr(p_emp_no,1,2) + 1900) + 1;
    else
        age := extract(year from sysdate) - (substr(p_emp_no,1,2) + 2000) + 1;
    end if;
    return age;
end;
/

select emp_id,
        emp_name,
        emp_no,
        fn_get_gender(emp_no) 성별,
        fn_get_age(emp_no) 나이
from employee;


-----------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE
-----------------------------------------------------------------------------------------------------------------------------------
-- function도 procedure안에 포함된다
-- 일련의 작업절차를 작성해 객체로 저장해둔것
-- 함수와 달리 리턴값이없다
-- OUT매개변수를 사용하면 호출부쪽으로 결과를 전달가능. 여러개의 값을 리턴하는 효과연출할수있다


--1. 매개변수 없는 프로시저
select * from member;

--member 테이블 행전체를 삭제하는 프로시저
create or replace procedure proc_del_member
is
    --지역변수 선언
    
begin
    --실행구문
    delete from member;
    commit;
end;
/

--호출
--1-1. 익명블록 | 타 프로시저 객체에서 호출 가능
begin
    proc_del_member();
    --proc_del_member; 도 된다
end;
/

--1-2. execute 명령
execute proc_del_member;

-- DD에서 확인
select *
from user_procedures
where object_type = 'PROCEDURE';

-- 소스코드확인
select *
from user_source
where name = 'PROC_DEL_MEMBER';


-- 2. 매개변수 있는 프로시저
-- 매개변수 mode 기본값 in
create or replace procedure proc_del_emp_by_id(p_emp_id emp_copy.emp_id%type)
is
begin
    delete from emp_copy
    where emp_id = p_emp_id;
    commit;
    dbms_output.put_line(p_emp_id || '번 사원을 삭제했습니다');
end;
/

select * from emp_copy;


-- 호출
-- 익명블록에서 호출
begin
    proc_del_emp_by_id('&삭제할_사번') --공백이 사이에 있으면 안된다
end;
/

-- OUT매개변수 사용하기
-- 사번을 전달해서 사원명, 전화번호를 리턴(OUT매개변수)받을수있는 프로시저
create or replace procedure proc_select_emp_by_id(
    p_emp_id in emp_copy.emp_id%type,
    p_emp_name out emp_copy.emp_name%type,
    p_phone out emp_copy.phone%type
)
is
    
begin
    select emp_name, phone
    into p_emp_name, p_phone
    from emp_copy
    where emp_id = p_emp_id;
end;
/


-- 익명블럭에서 호출
declare
    v_emp_name emp_copy.emp_name%type;
    v_phone emp_copy.phone%type;
begin
    proc_select_emp_by_id('&사번', v_emp_name, v_phone);
    dbms_output.put_line('v_emp_name : ' || v_emp_name);
    dbms_output.put_line('v_phone : ' || v_phone);
end;
/


--upsert 예제 : insert + update
create table job_copy
as
select *
from job;

select * from job_copy;
desc job_copy;

--pk, not null제약조건 추가
alter table job_copy
add constraint pk_job_copy primary key(job_code)
modify job_name not null;


--직급정보를 추가하는 프로시저
create or replace procedure proc_man_job_copy(
    p_job_code job_copy.job_code%type,
    p_job_name job_copy.job_name%type
)
is
    v_cnt number := 0;
begin
    --1.존재여부 확인
    select count(*)
    into v_cnt
    from job_copy
    where job_code = p_job_code;
    --2.분기처리
    if(v_cnt = 0) then
        --존재하지않으면 insert
        insert into job_copy
        values(p_job_code, p_job_name);
    else    
        --존재하면 update
        update job_copy
        set job_name = p_job_name
        where job_code = p_job_code;
    end if;
       
    --3.트랜잭션처리
    commit;
end;
/


--익명블럭에서 호출
begin
    proc_man_job_copy('J8', '수습사원');
end;
/




-------------------------------------------------------------------------------------------------------------------
-- CURSOR
-------------------------------------------------------------------------------------------------------------------
-- SQL의 처리결과 ResultSet을 가리키고 있는 포인터 객체
-- 하나이상의 row에 순차적으로 접근가능

--1. 암묵적 커서 : 모든 sql실행시 암묵적커서가 만들어져 처리됨
--2. 명시적 커서 : 변수로 선언후 open~fetch~close과정에 따라 행에 접근할수있다

--명시적커서
--파라미터가 없는 커서
declare
    v_emp emp_copy%rowtype;
    
    cursor my_cursor
    is
    select * from emp_copy order by emp_id;

begin
    open my_cursor;
    loop
        fetch my_cursor into v_emp; --한행씩 접근해서 가져옴
        exit when my_cursor%notfound;
        dbms_output.put_line('사번 : ' || v_emp.emp_id);
        dbms_output.put_line('사원명 : ' || v_emp.emp_name);
    end loop;
    
    close my_cursor;
end;
/


--파라미터 있는 커서
declare
    v_emp emp_copy%rowtype;
    
    cursor my_cursor(p_dept_code emp_copy.dept_code%type)
    is
    select * 
    from emp_copy
    where dept_code = p_dept_code
    order by emp_id;

begin
    open my_cursor('&부서코드');
    loop
        fetch my_cursor into v_emp; --한행씩 접근해서 가져옴
        exit when my_cursor%notfound;
        dbms_output.put_line('사번 : ' || v_emp.emp_id);
        dbms_output.put_line('사원명 : ' || v_emp.emp_name);
        dbms_output.put_line('부서코드 : ' || v_emp.dept_code);
        dbms_output.put_line(' ');
    end loop;
    
    close my_cursor;
end;
/

-- for..in문을 통해 처리
--1. open ~ fetch ~ close 작업 자동
--2. 행변수는 자동으로 선언

--파라미터 없는 커서
declare
    cursor my_cursor
    is
    select * --커서안의 컬럼이 제한되도 유연하게 처리한다
    from employee;
begin
    for my_row in my_cursor loop
        dbms_output.put_line(my_row.emp_id || ' : ' || my_row.emp_name);
    end loop;

end;
/

--파라미터 있는 커서
declare
    cursor my_cursor(p_job_code emp_copy.job_code%type)
    is
    select emp_id, emp_name, job_code
    from emp_copy
    where job_code = p_job_code;
begin
    for my_row in my_cursor('&직급코드') loop
        dbms_output.put_line(my_row.emp_id || ' : ' || my_row.emp_name);
    end loop;

end;
/



-------------------------------------------------------------------------------------------------------------------
-- TRIGGER
-------------------------------------------------------------------------------------------------------------------
-- 연쇄반응
-- 특정이벤트(DDL, DML, LOGON)가 발생했을때 실행될 코드를 모아둔 데이터베이스 객체

-- 종류
--1. DDL Trigger
--2. DML Trigger
--3. LOGON/LOGOFF Trigger

-- 예를 들어 게시판 테이블에서 게시물을 삭제했을때
-- 삭제테이블을 따로 만들어서 삭제된 행 데이터를 삭제테이블에 insert
-- 삭제테이블로 이동시키는것을 trigger가 할수있다

/*
create or replace trigger 트리거명
    before | after                                      --원 DML문 실행 전 | 실행 후에 trigger를 실행할지 결정
    insert | update | delete on 테이블명         --or로 묶어서 모두 실행가능
    [for each row]                                    --행level trigger , 생략하면 문장level trigger
begin
    --실행코드
end;
/

- 행레벨 트리거 : 원 DML문이 처리되는 행마다 트리거실행(10행수정하면 10번실행됨)
- 문장레벨 트리거 : 원 DML문이 실행시 트리거 1번 실행(10행수정해도 1번실행됨)

의사 pseudo 레코드(행레벨트리거에서만 유효)
- :old 원 DML문 실행전 데이터
- :new 원 DML문 실행후 데이터

insert
    :old null
    :new 추가된 데이터
update
    :old 변경전 데이터
    :new 변경후 데이터
delete
    :old 삭제전 데이터
    :new null(삭제후데이터는 없으므로)

**트리거 내부에서는 transaction 처리하지않는다. 원 DML문의 transaction에 자동포함된다.
*/


create or replace trigger trig_emp_salary
    before                                      
    insert or update on emp_copy         
    for each row                                    
begin
    dbms_output.put_line('변경전 salary : ' || :old.salary);
    dbms_output.put_line('변경후 salary : ' || :new.salary);
    
    insert into emp_copy_salary_log (emp_id, before_salary, after_salary)
    values(:new.emp_id, :old.salary, :new.salary);
    
end;
/


update emp_copy
set salary = salary + 1000000
where dept_code = 'D5';

--insert into emp_copy(emp_id, emp_name, emp_no, job_code, sal_level, salary)
--values('400', '이이이', '900115-1234567', 'J1', 'S1', 7000000);


--rollback; --trigger안의 실행된 dml문도 같이 rollback된다 


--pk추가
alter table emp_copy
add constraint pk_emp_copy_emp_id primary key(emp_id);



--급여변경 로그테이블(insert or update가 일어나면 급여변경로그테이블에 추가)
create table emp_copy_salary_log (
    emp_id varchar2(3),
    before_salary number,
    after_salary number,
    log_date date default sysdate,
    constraint fk_emp_id foreign key(emp_id) references emp_copy(emp_id)
);



select * from emp_copy;
select * from emp_copy_salary_log;




--emp_copy 에서 사원을 삭제할경우 emp_copy_del 테이블로 데이터를 이전시키는 trigger를 생성하세요
--quit_date에 현재날짜를 기록할것
create table emp_copy_del
as
select E.*
from emp_copy E
where 1 = 2 ;


select * from emp_copy_del;


create or replace trigger trig_emp_copy_del
    before                                      
    delete on emp_copy         
    for each row                                    
begin
    insert into emp_copy_del(emp_id, emp_name, emp_no, dept_code, job_code, sal_level, quit_date)
    values(:old.emp_id, :old.emp_name, :old.emp_no, :old.dept_code, :old.job_code, :old.sal_level, sysdate);
end;
/

delete from emp_copy
where emp_id = '400';



--trigger를 이용한 상품재고 관리
--set serveroutput on;

create table product(
    pcode number,
    pname varchar2(100),
    price number,
    stock_cnt number default 0, --재고
    constraint pk_product_pcode primary key(pcode)
);

create table product_io (
    iocode number,
    pcode number,
    amount number,
    status char(1),
    io_date date default sysdate,
    constraint pk_product_io_code primary key(iocode),
    constraint fk_product_io_pcode foreign key(pcode) references product(pcode)
);

alter table product_io
add constraint ck_product_io_status check(status in ('I','O'));


--시퀀스 생성
create sequence seq_product_pcode;

create sequence seq_product_io_iocode
start with 1000;


insert into product 
values (seq_product_pcode.nextval, '아이폰12', 1500000, 0);

insert into product 
values (seq_product_pcode.nextval, '갤럭시21', 990000, 0);


select * from product;
select * from product_io;


--입출고 데이터가 insert되면 해당상품의 재고수량을 변경(update)하는 트리거
create or replace trigger trig_product
    before
    insert on product_io
    for each row
begin
    --입고할때
    if :new.status = 'I' then
        update product
        set stock_cnt = stock_cnt + :new.amount
        where pcode = :new.pcode;
    --출고할때
    else
        update product
        set stock_cnt = stock_cnt - :new.amount
        where pcode = :new.pcode;
     end if;
end;
/


--입출고 내역
insert into product_io
values(seq_product_io_iocode.nextval, 1, 5, 'I', sysdate);

insert into product_io
values(seq_product_io_iocode.nextval, 1, 100, 'I', sysdate);

insert into product_io
values(seq_product_io_iocode.nextval, 1, 30, 'O', sysdate);

--insert into product_io
--seq_product_io_iocode.nextval, (select pcode from product where pname = '아이폰12'), 5, 'I', sysdate

commit;

--1. 원 DML문의 대상테이블의 접근할수없다
--2. 트리거 안에서는 원 DML문을 제어할수없다
