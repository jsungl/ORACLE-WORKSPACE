--======================================================
--system 관리자 계정
--======================================================
--한줄 주석
/*
여러줄주석
*/
show user;

--현재 등록된 사용자목록 조회
-- sys 슈퍼관리자
-- system 일반관리자(여러명 추가가능)
-- system 일반관리자는 db생성/삭제 권한 없음
-- sql문은 대소문자를 구분하지않는다
-- 사용자계정의 비밀번호, 테이블 내의 데이터는 대소문자를 구분한다
select * from dba_users; --쿼리(sql문)

-- 관리자는 일반사용자를 생성할수있다
create user kh
identified by kh --비밀번호(대소문자구분)
default tablespace users; -- 데이터가 저장될 영역 system | users




-- 사용자 삭제
-- drop user kh; 

-- 접속권한 create session 이 포함된 role(권한묶음) connect 부여
grant connect to kh;

-- 테이블 등 객체 생성권한이 포함된 role resource 부여
grant resource to kh;
--테이블 생성권한만 부여
--grant create table to kh;

-- 원래는 한번에 2개를 부여한다
--grant connect,resource to kh;


--chun계정 생성
create user chun
identified by chun
default tablespace users;

--connect, resource 를 부여
grant connect, resource to chun;

--role(권한묶음)에 포함된 권한 확인
--DataDictionary db의 각 객체에 대한 메타정보를 확인할수있는 read-only 테이블중 하나인 dba_sys_privs
select *
from dba_sys_privs
where grantee in ('CONNECT','RESOURCE');

--create view 권한부여
--resource role에 포함되지않는다
grant create view to kh;
grant create view to chun;

