show user;

create table tb_abc (
    id number
);

desc tb_abc;

--권한, roll을 조회
select *
from user_sys_privs; --권한

select *
from user_role_privs; --roll

select *
from role_sys_privs; --부여받은 roll에 포함된 권한


-- kh계정이 소유한 tb_coffee 테이블 조회
select *
from kh.tb_coffee; --다른계정의 테이블을 쉽게접근불가(kh계정에서 열람권한을 부여해야한다)

-- 데이터추가(kh계정에서 권한을 부여해야한다)
insert into kh.tb_coffee
values('프렌치카페',2000,'남양유업');

--view_emp 조회
select * from kh.employee; --employee테이블은 볼수없다
select * from kh.view_emp;