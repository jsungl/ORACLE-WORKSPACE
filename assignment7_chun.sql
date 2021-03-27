--1. 학생이름과 주소지를 표시하시오. 단, 출력 헤더는 "학생 이름", "주소지"로 하고, 정렬은 이름으로 오름차순 표시하도록 한다.
select student_name "학생 이름",
         student_address 주소지
from tb_student
order by student_name;

--2. 휴학중인 학생들의 이름과 주민번호를 나이가 적은 순서로 화면에 출력하시오.
select student_name,
         student_ssn
from tb_student
where absence_yn = 'Y'
order by student_ssn desc;

--3. 주소지가 강원도나 경기도인 학생들 중 1900년대 학번을 가진 학생들의 이름과 학번, 주소를 이름의 오름차순으로 화면에 출력하시오.
--단, 출력헤더에는 "학생이름","학번", "거주지 주소" 가 출력되도록 한다
select student_name 학생이름,
         student_no 학번,
         student_address "거주지 주소"
from tb_student
where student_address like '%강원도%' or student_address like '%경기도%'
        and extract(year from entrance_date) between 1900 and 1999 
order by student_name;


--4. 현재 법학과 교수 중 가장 나이가 많은 사람부터 이름을 확인할 수 있는 SQL 문장을 작성하시오. 
--(법학과의 '학과코드'는 학과 테이블(TB_DEPARTMENT)을 조회해서 찾아 내도록 하자)
select professor_name,
         professor_ssn
from tb_professor
where department_no = (
                                  select department_no
                                  from tb_department
                                  where department_name = '법학과'
                                )
order by 2;


--5. 2004년2학기에 'C3118100' 과목을 수강한 학생들의 학점을 조회하려고 핚다. 
--학점이 높은 학생부터 표시하고, 학점이 같으면 학번이 낮은 학생부터 표시하는 구문을 작성해보시오.
select student_no,
         point
from tb_grade
where class_no = 'C3118100' and term_no = '200402'
order by point desc, student_no ;


--6. 학생 번호, 학생 이름, 학과 이름을 학생 이름으로 오름차순 정렬하여 출력하는 SQL 문을 작성하시오.
select student_no,
         student_name,
         (
         select department_name from tb_department where department_no = S.department_no
         ) 학과이름
from tb_student S
order by student_name;


--7. 춘 기술대학교의 과목 이름과 과목의 학과 이름을 출력하는 SQL 문장을 작성하시오
select class_name 과목이름,
         (
          select department_name from tb_department where department_no = C.department_no
         ) 학과이름
from tb_class C;

--8. 과목별 교수 이름을 찾으려고 한다. 과목 이름과 교수 이름을 출력하는 SQL 문을 작성하시오.
select (
          select class_name from tb_class where class_no = CP.class_no
         ) CLASS_NAME,
         (
          select professor_name from tb_professor where professor_no = CP.professor_no
         ) PROFESSOR_NAME
from tb_class_professor CP;


--9. 8번의 결과 중 ‘인문사회’ 계열에 속한 과목의 교수 이름을 찾으려고 한다. 
--이에 해당하는 과목 이름과 교수 이름을 출력하는 SQL 문을 작성하시오

select  (
          select class_name from tb_class where class_no = A.class_no
         ) CLASS_NAME,
         (
          select professor_name from tb_professor where professor_no = A.professor_no
         ) PROFESSOR_NAME
from (
         select *
         from tb_class_professor
         where class_no in (
                                    select class_no
                                    from tb_class
                                    where department_no in (
                                                                       select department_no
                                                                       from tb_department
                                                                       where category = '인문사회'
                                                                     )
                                )

        )A;


--10. ‘음악학과’ 학생들의 평점을 구하려고 한다. 음악학과 학생들의 "학번", "학생 이름", "전체 평점"을 출력하는 SQL 문장을 작성하시오. 
--(단, 평점은 소수점 1자리까지만 반올림하여 표시한다.)
select A.student_no 학번,
         A.student_name 학생이름,
         (
            select round(avg(point),1)
            from tb_grade
            where student_no = A.student_no
         ) "전체평점"
from (
         select student_no, 
                  student_name
         from tb_student 
         where department_no = (
                                            select department_no
                                            from tb_department
                                            where department_name = '음악학과'
                                         )
        )A
order by 1;

        
        
--11. 학번이 A313047인 학생이 학교에 나오고 있지 않다. 지도 교수에게 내용을 전달하기 위해 학과 이름, 학생 이름과 지도 교수 이름이 필요하다. 
--이때 사용할 SQL 문을 작성하시오. 단, 출력헤더는 ‚"학과이름", "학생이름", "지도교수이름"으로 출력되도록 한다.

select (
          select department_name
          from tb_department
          where department_no = S.department_no
         ) 학과이름,
        student_name 학생이름,
        (
         select professor_name
         from tb_professor
         where professor_no = S.coach_professor_no
        ) 지도교수이름
from tb_student S
where student_no = 'A313047';


--12. 2007년도에 '인간관계론' 과목을 수강한 학생을 찾아 학생이름과 수강학기를 표시하는 SQL 문장을 작성하시오.
select (
          select student_name
          from tb_student
          where student_no = A.student_no
        )STUDENT_NAME,
        term_no TERM_NAME
from (
         select student_no, term_no
         from tb_grade
         where class_no = (
                                  select class_no
                                  from tb_class
                                  where class_name = '인간관계론'
                                 )
            and substr(term_no,1,4) = '2007'
        ) A;                        


--13. 예체능 계열 과목 중 과목 담당교수를 한 명도 배정받지 못한 과목을 찾아 그 과목 이름과 학과 이름을 출력하는 SQL 문장을 작성하시오


select class_name 과목이름,
        (
         select department_name
         from tb_department
         where department_no = A.department_no 
        ) 학과이름
from (  select class_name,department_no
          from tb_class C
          where department_no in (
                                             select department_no
                                             from tb_department
                                             where category = '예체능'
                                           ) 
                    and not exists (
                                          select 1
                                          from tb_class_professor
                                          where class_no = C.class_no
                                        )

        ) A;

--14. 춘 기술대학교 서반아어학과 학생들의 지도교수를 게시하고자 한다. 
--학생이름과 지도교수 이름을 찾고 만일 지도 교수가 없는 학생일 경우 "지도교수 미지정"으로 표시하도록 하는 SQL 문을 작성하시오. 
--단, 출력헤더는 "학생이름", "지도교수"로 표시하며 고학번 학생이 먼저 표시되도록 한다.
select student_name 학생이름,
        nvl((
            select professor_name
            from tb_professor
            where professor_no = coach_professor_no
        ),'지도교수 미지정') 지도교수
from tb_student 
where department_no = (
                                    select department_no
                                    from tb_department
                                    where department_name = '서반아어학과'
                                 )
order by student_no;



--15. 휴학생이 아닌 학생 중 평점이 4.0 이상인 학생을 찾아 그 학생의 학번, 이름, 학과 이름, 평점을 출력하는 SQL 문을 작성하시오.
select student_no,
        student_name,
        (
         select department_name
         from tb_department
         where department_no = A.department_no
         ) 학과이름,
         (
          select avg(point)
          from tb_grade
          where student_no = A.student_no
         ) 평점
from (
            select *
            from tb_student S
            where (
                        select avg(point)
                        from tb_grade 
                        where student_no = S.student_no
                     ) >= 4 
        )A
where absence_yn = 'N'; 


--16. 환경조경학과 전공과목들의 과목 별 평점을 파악할 수 있는 SQL 문을 작성하시오

select class_no,
        class_name,
        (
         select trunc(avg(point),8)
         from tb_grade
         where class_no = A.class_no
        ) 과목별평점
from (
        select *
        from tb_class
        where department_no = (
                                            select department_no
                                            from tb_department
                                            where department_name = '환경조경학과'
                                         )
        ) A
where class_type like '전공%';


--17. 춘 기술대학교에 다니고 있는 최경희 학생과 같은 과 학생들의 이름과 주소를 출력하는 SQL 문을 작성하시오

select student_name,
        student_address
from tb_student
where department_no = (
                                    select department_no 
                                    from tb_student
                                    where student_name = '최경희'
                                 );
        
--18. 국어국문학과에서 총 평점이 가장 높은 학생의 이름과 학번을 표시하는 SQL문을 작성하시오.

select student_no, student_name
from (
         select   student_no,
                   student_name,
                  (
                    select avg(point)
                    from tb_grade
                    where student_no = S.student_no
                  ) avg
         from tb_student S
         where department_no = (
                                            select department_no
                                            from tb_department
                                            where department_name = '국어국문학과'
                                          )
         order by 3 desc 
        )
where rownum < 2;
                                    
        
--19. 춘 기술대학교의 "환경조경학과"가 속한 같은 계열 학과들의 학과 별 전공과목 평점을 파악하기 위핚 적절한 SQL 문을 찾아내시오. 
--단, 출력헤더는 "계열 학과명", "전공평점"으로 표시되도록 하고, 평점은 소수점 한 자리까지만 반올림하여 표시되도록 한다.     
            
select  (
            select department_name
            from tb_department
            where department_no = C.department_no
            ) 계열학과명,

            round(avg( (
                            select avg(point)
                            from tb_grade
                            where class_no = C.class_no
                            )
                         ) ,1) 전공평점

from tb_class C 
where department_no in (
                                     select department_no
                                    from tb_department  
                                    where category = (
                                                                select category
                                                                from tb_department
                                                                where department_name = '환경조경학과'
                                                              )
                                 )
        and class_type like '전공%'
group by department_no;


