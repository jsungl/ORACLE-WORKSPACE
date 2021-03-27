create table test_sample(
    id number,
    nick_name varchar2(100) default '홍길동',
    name varchar2(100) not null,
    enroll_date date default sysdate not null
);


select * from test_sample;

--기본값 확인
select column_name, data_type, data_default, nullable
from user_tab_cols
where table_name = 'TEST_SAMPLE';

desc test_sample;

--제약조건 확인
select constraint_name,
        uc.table_name,
        ucc.column_name,
        uc.constraint_type,
        uc.search_condition
from user_constraints uc
    join user_cons_columns ucc
        using(constraint_name)
where uc.table_name = 'DEPARTMENT'; 

--null로 제약조건 변경
alter table test_sample
modify name varchar2(500) null;


--제약조건 추가
--alter table 테이블명
--add constraint 제약조건이름 foreign key(emp_id) references emp_copy(emp_id);


--제약조건 삭제
--alter table 테이블명
--drop constraint 제약조건이름; 



--set serveroutput on;

