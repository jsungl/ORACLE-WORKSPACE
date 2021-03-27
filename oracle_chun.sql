--==================================================================
--CHUN 계정(과제하는 공간)
--==================================================================
--학과 테이블
select * from tb_department;

--학생 테이블
select * from tb_student;

--과목 테이블
select * from tb_class;

--교수 테이블
select * from tb_professor;

--교수 과목 테이블(어떤수업을 누가 가르치는가, 과목테이블과 교수테이블에서 컬럼사용)
select * from tb_class_professor;

--점수등급 테이블
select * from tb_grade;





        
-------------------------------------------------------------------------------------------------------------------------------------     
--DDL        

--1. 계열 정보를 저장할 카테고리 테이블을 만들려고 한다. 다음과 같은 테이블을 작성하시오.
create table tb_category (
    name varchar2(10),
    use_yn char(1) default 'Y'
);

--select column_name, data_type, data_default, nullable
--from user_tab_cols
--where table_name = 'TB_CATEGORY';

--2. 과목 구분을 저장한 테이블을 만들려고 한다. 다음과 같은 테이블을 작성하시오.
create table tb_class_type (
    no varchar2(5) PRIMARY KEY,
    name varchar2(10)
);

--select constraint_name,
--        uc.table_name,
--        ucc.column_name,
--        uc.constraint_type,
--        uc.search_condition
--from user_constraints uc
--    join user_cons_columns ucc
--        using(constraint_name)
--where uc.table_name = 'TB_CLASS_TYPE';


--3.TB_CATAGORY 테이블의 NAME 컬럼에 PRIMARY KEY를 생성하시오. (KEY 이름을 생성하지 않아도 무방함. 
--만일 KEY 이름 지정하고자 한다면 이름은 본인이 알아서 적당한 이름을 사용한다.)
alter table tb_category
add constraint pk_tb_category_name primary key(name);


--4. TB_CLASS_TYPE 테이블의 NAME 컬럼에 NULL 값이 들어가지 않도록 속성을 변경하시오
alter table tb_class_type
modify name not null;

--desc tb_class_type;

--5. 두 테이블에서 컬럼 명이 NO인 것은 기존 타입을 유지하면서 크기는 10 으로, 
--컬럼명이 NAME 인 것은 마찬가지로 기존 타입을 유지하면서 크기 20 으로 변경하시오.
alter table tb_class_type
modify no varchar2(10) 
modify name varchar2(20);

--desc tb_category;

alter table tb_category 
modify name varchar2(20);


--6. 두 테이블의 NO 컬럼과 NAME 컬럼의 이름을 각 각 TB_ 를 제외한 테이블 이름이 앞에 붙은 형태로 변경한다.
--(ex. CATEGORY_NAME)
alter table tb_category
rename column name to category_name;

--desc tb_class_type;

alter table tb_class_type
rename column name to class_type_name;
alter table tb_class_type
rename column no to class_type_no;


--7. TB_CATAGORY 테이블과 TB_CLASS_TYPE 테이블의 PRIMARY KEY 이름을 다음과 같이 변경하시오.
--Primary Key의 이름은 "PK_ + 컬럼이름"으로 지정하시오. (ex. PK_CATEGORY_NAME )
alter table tb_category
rename constraint pk_tb_category_name to pk_category_name;

alter table tb_class_type
rename constraint SYS_C007192 to pk_class_type_no;


--select constraint_name,
--        uc.table_name,
--        ucc.column_name,
--        uc.constraint_type,
--        uc.search_condition
--from user_constraints uc
--    join user_cons_columns ucc
--        using(constraint_name)
--where uc.table_name = 'TB_CLASS_TYPE';


--8. 다음과 같은INSERT 문을 수행한다
INSERT INTO TB_CATEGORY VALUES ('공학','Y'); 
INSERT INTO TB_CATEGORY VALUES ('자연과학','Y'); 
INSERT INTO TB_CATEGORY VALUES ('의학','Y'); 
INSERT INTO TB_CATEGORY VALUES ('예체능','Y'); 
INSERT INTO TB_CATEGORY VALUES ('인문사회','Y'); 
COMMIT;

select * from tb_category;

--select column_name, data_type, data_default, nullable
--from user_tab_cols
--where table_name = 'TB_CATEGORY';

--9. TB_DEPARTMENT의 CATEGORY 컬럼이 TB_CATEGORY 테이블의 CATEGORY_NAME 컬럼을 부모 값으로 참조하도록 FOREIGN KEY를 지정하시오.
--이 때 KEY 이름은 FK_테이블이름_컬럼이름으로 지정한다. (ex. FK_DEPARTMENT_CATEGORY )

alter table tb_department
add constraint fk_department_category foreign key(category) references tb_category(category_name);

--alter table tb_department
--drop constraint fk_department_category; 



--10. 춘 기술대학교 학생들의 정보만이 포함되어 있는 학생일반정보 VIEW를 만들고자 한다. 아래 내용을 참고하여 적절한 SQL 문을 작성하시오.
create view VW_학생일반정보
as
select student_no,
        student_name,
        student_address
from tb_student;

select * from VW_학생일반정보;

--11. 춘 기술대학교는 1년에 두 번씩 학과별로 학생과 지도교수가 지도 면담을 진행한다
--이를 위해 사용할 학생이름, 학과이름, 담당교수이름 으로 구성되어 있는 VIEW 를 만드시오.
--이때 지도 교수가 없는 학생이 있을 수 있음을 고려하시오 
--(단, 이 VIEW 는 단순 SELECT 만을 할 경우 학과별로 정렬되어 화면에 보여지게 만드시오.)

create or replace view VW_지도면담
as
select 
        student_name,
        department_name,
        nvl(professor_name,'지도교수없음') 지도교수이름
from tb_student S
    left join tb_department D 
        using (department_no)
    left join tb_professor P
        on S.coach_professor_no = P.professor_no
order by department_name
with read only;

select * from VW_지도면담;


--12. 모든 학과의 학과별 학생 수를 확인할 수 있도록 적절한 VIEW 를 작성해 보자.

create or replace view VW_학과별학생수
as
select department_name,
        count(*) student_count
from tb_student
    join tb_department
        using(department_no)
group by department_name
with read only;

select * from VW_학과별학생수;

--13. 위에서 생성한 학생일반정보 View를 통해서 학번이 A213046인 학생의 이름을 본인 이름으로 변경하는 SQL 문을 작성하시오.

select *
from VW_학생일반정보
where student_no = 'A213046';


update VW_학생일반정보
set student_name = '이재성'
where student_no = 'A213046';

--create or replace view VW_학생일반정보
--as
--select student_no,
--        student_name,
--        student_address
--from tb_student
--with read only;

--14. 13번에서와 같이 VIEW를 통해서 데이터가 변경될 수 있는 상황을 막으려면 VIEW를 어떻게 생성해야 하는지 작성하시오
-- dml하지 못하게 with read only 옵션을 사용하여 생성한다.




--15. 춘 기술대학교는 매년 수강신청 기간만 되면 특정 인기 과목들에 수강 신청이 몰려 문제가 되고 있다. 
--최근 3년을 기준으로 수강인원이 가장 많았던 3 과목을 찾는 구문을 작성해보시오.


select *
from (
            select  
                    class_no,
                    class_name,
                    count(*) 누적수강생수
            from tb_class C
                join tb_grade G
                    using(class_no)
            where substr(G.term_no,1,4) in ('2009','2008','2007')
            group by class_no, class_name
            order by 3 desc
        )
where rownum <= 3;
        



-------------------------------------------------------------------------------------------------------------------------------------     
--DML

--1. 과목유형 테이블(TB_CLASS_TYPE)에 아래와 같은 데이터를 입력하시오

select * from tb_class_type;

insert all
into tb_class_type values('01','전공필수')
into tb_class_type values('02','전공선택')
into tb_class_type values('03','교양필수')
into tb_class_type values('04','교양선택')
into tb_class_type values('05','논문지도')
select *
from dual;

--2. 춘 기술대학교 학생들의 정보가 포함되어 있는 학생일반정보 테이블을 맊들고자 핚다. 
--아래 내용을 참고하여 적젃핚 SQL 문을 작성하시오. (서브쿼리를 이용하시오)
--drop table TB_학생일반정보;
create table TB_학생일반정보
as
select student_no,
        student_name,
        student_address
from tb_student;

select * from tb_학생일반정보;

--3. 국어국문학과 학생들의 정보맊이 포함되어 있는 학과정보 테이블을 맊들고자 핚다. 
--아래 내용을 참고하여 적젃핚 SQL 문을 작성하시오. (힌트 : 방법은 다양함, 소신껏 작성하시오)
--drop table TB_국어국문학과;
create table TB_국어국문학과
as
select student_no,
        student_name,
        decode(substr(student_ssn,8,1), '1', 1900, '2', 1900, 2000) + substr(student_ssn,1,2) 출생년도,
        nvl(professor_name,'지도교수없음') 교수이름
from tb_student S
    join tb_department D
        using(department_no)
    join tb_professor P
        on S.coach_professor_no = P.professor_no
where D.department_name = '국어국문학과'; 


--4. 현 학과들의 정원을 10% 증가시키게 되었다. 이에 사용핛 SQL 문을 작성하시오. (단, 반올림을 사용하여 소수점 자릿수는 생기지 않도록 핚다)
--drop table tb_department_test;
select * from tb_department_test;

update tb_department_test
set capacity = round(capacity + (capacity * 0.1)); 

--5. 학번 A413042인 박건우 학생의 주소가 "서울시 종로구 숭인동 181-21 "로 변경되었다고 핚다. 
--주소지를 정정하기 위해 사용핛 SQL 문을 작성하시오.
create table tb_student_test
as
select *
from tb_student;

select * from tb_student_test where student_no = 'A413042';

update tb_student_test
set student_address = '서울시 종로구 숭인동 181-21'
where student_no = 'A413042';


--6. 주민등록번호 보호법에 따라 학생정보 테이블에서 주민번호 뒷자리를 저장하지 않기로 결정하였다. 
--이 내용을 반영핛 적젃핚 SQL 문장을 작성하시오.
--(예. 830530-2124663 ==> 830530 )
--drop table tb_student_test;
select * from tb_student_test;

update tb_student_test
set student_ssn = substr(student_ssn,1,6);

--7. 의학과 김명훈 학생은 2005년 1학기에 자신이 수강핚 '피부생리학' 점수가 잘못되었다는 것을 발견하고는 정정을 요청하였다. 
--담당 교수의 확인 받은 결과 해당 과목의 학점을 3.5로 변경키로 결정되었다. 적젃핚 SQL 문을 작성하시오
--drop table tb_grade_김명훈;

create table tb_grade_김명훈
as
select *
from tb_grade G
    join tb_student S
        using(student_no)
    join tb_department D
        using(department_no)
where S.student_name = '김명훈' and D.department_name = '의학과';

select * from tb_grade_김명훈;

update tb_grade_김명훈
set point = 3.5
where term_no = '200501' and class_no = (select class_no from tb_class where class_name = '피부생리학');


--8. 성적 테이블(TB_GRADE) 에서 휴학생들의 성적항목을 제거하시오

--drop table tb_grade_test;

create table tb_grade_test
as
select *
from tb_grade;

select *
from tb_grade_test;

delete from tb_grade_test
where student_no in (select student_no from tb_student where absence_yn = 'Y');

