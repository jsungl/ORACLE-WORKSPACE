--====================================================
-- kh계정
--====================================================
show user;

-- table sample 생성(테이블생성권한이 있어야됨)
create table sample(
    id number
);

-- 현재 계정의 소유 테이블 목록 조회
select * from tab;

--사원테이블관리
select * from employee;
--부서테이블관리
select * from department;
--직급테이블관리
select * from job;
--지역테이블관리
select * from location;
--국가테이블관리
select * from nation;
--급여등급테이블관리
select * from sal_grade;


-- table(entity) relation(확장된개념) ->표
-- 데이터를 보관하는 객체(권한도 객체다)
-- 열(column,field,attribute) -> 세로,데이터가 담길 형식
-- 행(row,record,tuple) -> 가로,실제 데이터가 담겨있다
-- 도메인(domain) -> 하나의 column에 취할수있는 값의 범위(그룹)

-- 테이블 명세
-- column명    널여부(NOT NULL : null일수없다,필수형)   자료형(자료형,해당크기)
-- describe employee;
desc employee;




--======================================================================
-- DATA TYPE
--======================================================================
-- column에 지정해서 값을 제한적으로 허용 
-- 1. 문자형 varchar2 | char
-- 2. 숫자형 number
-- 3. 날짜시간형 date | timestamp
-- 4. LOB

------------------------------------------------------------------------
-- 문자형
------------------------------------------------------------------------
-- 고정형 char(byte) : 최대 2000byte
-- char(10) 'korea' 영소문자는 글자당 1byte이므로 실제 크기는 5byte. 고정크기가 10byte이므로 결국 10byte로 저장됨.
--            '안녕' 한글은 글자당 3byte(11g XE)이므로 실제크기는 6byte. 고정형이므로 10byte로 저장됨.
-- 가변형 varchar2(byte) : 최대 4000byte
-- varchar2(10) 'korea' 영소문자는 글자당 1byte이므로 실제크기는 5byte. 가변형 5byte로 저장됨.
--                  '안녕' 한글은 글자당 3byte(11g XE)이므로 실제크기는 6byte. 가변형이므로 6byte로 저장됨.
-- 고정형,가변형 모두 지정한 크기 이상의 값은 추가할수없다

-- 가변형 long : 최대 2GB(정수형이아니라 문자형임. 헷갈리지말것!)
-- LOB타입 중의 CLOB(Character LOB)는 단일컬럼 최대 4GB까지 지원

create table tb_datatype (
-- 컬럼명 자료형 널여부 기본값
    a char(10),
    b varchar2(10)
);
-- 테이블 조회(*는 모든 컬럼)
select * from tb_datatype;

-- 데이터 추가 : 한행을 추가
insert into tb_datatype
values('hello','hello');
insert into tb_datatype
values('안녕','안녕');
--column사이즈보다 큰 데이터를 넣을경우 오류(15byte를 10byte에 넣으려해서)
--insert into tb_datatype
--values('에브리바디','안녕'); 

--데이터가 변경(insert,update,delete)되는 경우, 실제 적용되는것이 아니라 메모리상에서 먼저 처리된다
--commit을 통해 실제 database에 적용해야한다
--sqlplus에서도 db에 접근할수있는데 commit이전값만 확인가능. commit해야 db에 저장된걸 확인가능
commit;


--lengthb(컬럼명) : number - 저장된 데이터의 실제크기를 리턴
select a, lengthb(a), b, lengthb(b)
from tb_datatype;


------------------------------------------------------------------------
-- 숫자형
------------------------------------------------------------------------
-- 정수,실수를 구분하지 않는다
-- number(p,s)
-- p : 표현가능한 전체 자리수
-- s : p 중 소수점 이하 자리수
/*
값 1234.567
---------------------------------------
number              1234.567 저장
number(7)           1235 저장(반올림)
number(7,1)         1234.6 저장(반올림)
number(7,-2)        1200 저장(반올림)

*/

create table tb_datatype_number (
    a number,
    b number(7),
    c number(7,1),
    d number(7,-2)
); 

select * from tb_datatype_number;

insert into tb_datatype_number
values(1234.567, 1234.567, 1234.567, 1234.567);
-- 지정한 크기보다 큰 숫자는 오류발생
--insert into tb_datatype_number
--values(1234567890.123, 12345678.567, 12345678.567, 1234.567);
commit;
-- 마지막 commit 시점 이후 변경사항취소(commit의 반대로 commit해서 db에 저장된것은 취소못한다)
-- rollback; 




------------------------------------------------------------------------
-- 날짜시간형
------------------------------------------------------------------------
-- date 년월일시분초
-- timestamp 년월일시분초 밀리초 지역대

create table tb_datatype_date (
    a date,
    b timestamp
);

select * from tb_datatype_date;
-- 시분초까지 표현된걸 확인하려면
-- to_char : 날짜/숫자를 문자열로 표현
select to_char(a,'yyyy/mm/dd hh24:mi:ss'),b
from tb_datatype_date;

insert into tb_datatype_date
values (sysdate, systimestamp);


-- 날짜형 +- 숫자(1=하루) = 날짜형
select to_char(a,'yyyy/mm/dd hh24:mi:ss'),
        to_char(a+1,'yyyy/mm/dd hh24:mi:ss'),
        b
from tb_datatype_date;

-- 날짜형 - 날짜형 = 숫자(1=하루)
select sysdate - a --0.009일차
from tb_datatype_date;
-- to_date : 문자열을 날짜형으로 변환함수
select to_date('2021/01/23') - a
from tb_datatype_date;

--dual 가상테이블
select (sysdate + 1) - sysdate
from dual;


--===============================================
-- DQL
--===============================================
-- Data Query Language 데이터 조회(검색)을 위한 언어
-- select문
-- 쿼리 조회결과를 ResultSet(결과집합)라고 하며, 0행이상을 포함한다
-- from절에 조회하고자 하는 테이블명시
-- where절에 의해 특정행을 filtering 가능
-- select절에 의해 컬럼을 filtering 또는 추가가능
-- order by 절에 의해 행을 정렬할수있다
/*
구조
(처리순서)
select 컬럼명 (5)               필수
from 테이블명 (1)              필수
where 조건절 (2)              선택
group by 그룹기준컬럼 (3)  선택
having 그룹조건절 (4)        선택
order by 정렬기준컬럼 (6)  선택

*/
select *
from employee
where dept_code = 'D9' --데이터는 대소문자 구분
order by emp_name asc; --asc:오름차순 desc:내림차순

-- && || 이 아닌 and or만 사용가능
--1. job테이블에서 job_name 컬럼정보만 출력
select job_name
from job;
--2. department테이블에서 모든 컬럼을 출력
select *
from department;
--3. employee 테이블에서 이름,이메일,전화번호 ,입사일을 출력
select emp_name,email,phone,hire_date
from employee;
--4. employee 테이블에서 급여가 2,500,000원 이상인 사원의 이름과 급여를 출력
select emp_name,salary
from employee
where salary >= 2500000;
--5. employee 테이블에서 급여가 3,500,000원 이상이면서 직급코드가 'J3'인 사원을 조회
select *
from employee
where salary >= 3500000 and job_code = 'J3';
--6. employee 테이블에서 현재 근무중인 사원을 이름 오름차순으로 정렬해서 출력
select *
from employee
where QUIT_YN = 'N'
order by emp_name asc;




----------------------------------------------------------------------------------------
-- SELECT
----------------------------------------------------------------------------------------
-- table의 존재하는 컬럼
-- 가상컬럼(산술연산)
-- 임의의 값(literal)
-- 각 컬럼은 별칭(alias)를 가질수있다. as와 ""(쌍따옴표) 생략가능
-- 별칭에 공백,특수문자가 있거나 숫자로 시작하는 경우 ""(쌍따옴표) 필수
select emp_name as "사원명", --여기서 ""사용
        phone "전화번호", --as생략가능
        salary * 12 급여, --연봉, as,""둘다 생략가능
        123, --임의의값
        '안녕' --임의의값
from employee;

-- 실급여 : salary + (salary * bonus)
select emp_name,
        salary,
        bonus,
        salary + (salary * nvl(bonus,0)) 실급여
from employee;
-- null값과는 산술연산 할수없다. 그 결과는 무조건 null이다
-- bonus가 null인경우 결과값 null
-- null % 1(X) 나머지 연산자는 사용불가
select null + 1,
        null - 1,
        null * 1,
        null / 1
from dual; --1행짜리 가상테이블

-- nvl(col, null일때 값) : null처리 함수
-- col의 값이 null이 아니면, col값 리턴
-- col의 값이 null이면 (null일때 값)을 리턴
select bonus,
        nvl(bonus,0) null처리후
from employee;

-- distinct 중복제거용 키워드
-- select절에 단 한번 사용가능하다
-- 직급코드를 중복없이 출력
select distinct job_code
from employee;

-- 여러 컬럼사용시 컬럼을 묶어서 고유한 값으로 취급한다
select distinct job_code,dept_code --job_code와 dept_code를 하나의 행으로 보고 중복제거
from employee;

-- 문자 연결연산자 ||
-- +는 산술연산만 가능하다
select '안녕' || '하세요' || 123
from dual;

select emp_name || '(' || phone || ')'
from employee;


----------------------------------------------------------------------------------------
-- WHERE
----------------------------------------------------------------------------------------
-- 테이블의 모든 행중 결과집합에 포함될 행을 필터링한다
-- 특정행에 대해 true(포함) | false(제외) 결과를 리턴한다
/*
    =                           같은가(2개가 아니고 1개인점 주의)
    !=, ^=, <>               다른가
    >, <, >=, <= 
    between .. and ..        범위연산
    like, not like              문자패턴 연산
    is null, is not null        null 여부
    in, not in                  값 목록에 포함여부
    
    and 
    or
    not                         제시한 조건 반전
*/

-- 부서코드가 D6가 아닌 사원 조회
select emp_name, dept_code
from employee
where not dept_code = 'D6'; --!=,<>,^=

-- 급여가 2,000,000원 보다 많은 사원조회
select emp_name, salary
from employee
where salary > 2000000;

-- 부서코드가 D6이거나 D9인 사원 조회
select emp_name, dept_code
from employee
where dept_code in ('D6' ,'D9');
-- where dept_code = 'D6' or dept_code = 'D9'
-- 날짜형 크기 비교 가능
-- 과거<미래
select emp_name,hire_date
from employee
where hire_date < '2000/01/01'; --1월1일보다 이전. 날짜형식의 문자열은 자동으로 날짜형으로 형변환

-- 20년 이상 근무한 사원조회
-- 날짜형 - 날짜형 = 숫자(1=하루)
-- 날짜형 - 숫자(1=하루) = 날짜형
select emp_name,hire_date
from employee
where SYSDATE-hire_date >= 365*20 and quit_yn = 'N';
-- where to_date('2021/01/22') - hire_date > 365*20

-- 범위 연산
-- 급여가 200만원 이상 400만원 이하인 사원 조회(사원명,급여)
select emp_name,salary
from employee
where salary between 2000000 and 4000000;

-- 입사일이 1990/01/01 ~ 2001/01/01 인 사원조회(사원명,입사일)
select emp_name,hire_date
from employee
where quit_yn = 'N' and 
    hire_date between '1990/01/01' and '2001/01/01';
-- where hire_date >= '1990/01/01' and hire_date <= '2001/01/01';


-- like, not like
-- 문자열 패턴 비교 연산
-- wildcard : 패턴 의미를 가지는 특수문자
-- _아무문자 1개
-- %아무문자 0개이상

select emp_name
from employee
where emp_name like '전%'; --전으로 시작, 0개이상의 문자가 존재하는가
-- 전, 전전, 전차, 전진, 전형돈, 전전전전(O) : 전으로 시작
-- 파전(X)

select emp_name
from employee
where emp_name like '전__'; --전으로 시작, 연달아 2개의 문자가 존재하는가
-- 전형돈, 전전전 (O)
-- 전, 전진, 파전, 전당포아저씨 (X)

-- 이름에 가운데 글자가 '옹'인 사원조회, 단 이름은 3글자이다
select emp_name
from employee
where emp_name like '_옹_';

-- 이름에 '이'가 들어가는 사원조회
select emp_name
from employee
where emp_name like '%이%';

-- email컬럼값의 '_' 이전 글자가 3글자인 이메일을 조회
select email
from employee
-- where email like '____%'; -- 와일드카드_와 문자로 처리하고싶은_를 구분X , 4글자 이후 0개 이상의 문자열 뒤따르는가 -> 문자열이 4글자이상인가
where email like '___\_%' escape '\'; --임의의 escaping문자 등록(단 데이터에 존재하지 않는값으로 등록해야됨)

-- in, not in 값목록에 포함여부
-- 부서코드가 D6 또는 D8인 사원 조회
select emp_name, dept_code
from employee
where dept_code in ('D6','D8');
--where dept_code not in ('D6','D8'); D6 또는 D8이 아닌 사원
--where dept_code != 'D6' and dept_code != 'D8';


-- 인턴사원 조회(dept_code가 null인 사원)
-- null값은 산술연산, 비교연산 모두 불가능하다
-- is null , is not null : null 비교연산
select emp_name, dept_code
from employee
where dept_code is null;

-- D6,D8 사원이 아닌 사원조회(인턴사원 포함)
select emp_name, dept_code
from employee
where dept_code not in ('D6','D8') or dept_code is null;

-- nvl버전 : D6,D8 사원이 아닌 사원조회(인턴사원 포함)
select emp_name, dept_code
from employee
where nvl(dept_code,'D0') not in ('D6','D8'); --null값을 직접 비교하지못하므로 dept_code가 null이면 'D0'으로 치환하여 비교한다


----------------------------------------------------------------------------------------
-- ORDER BY
----------------------------------------------------------------------------------------
-- select 구문중 가장 마지막에 처리
-- 지정한 컬럼 기준으로 결과집합을 정렬해서 보여준다

-- number 0 < 10
-- string ㄱ < ㅎ, a < z
-- date  과거 < 미래
-- null값 위치를 결정가능 : nulls first | nulls last
-- asc 오름차순(기본값)
-- desc 내림차순
-- 복수개의 컬럼 차례로 정렬가능

select *
from employee; --order by를 하지않으면 oracle에서는 정렬을 보장하지않는다

select emp_id, emp_name, dept_code, job_code, hire_date
from employee
order by dept_code, job_code; -- dept_code로 먼저 정렬하고 그 다음 job_code 순서대로 정렬

select emp_id, emp_name, dept_code, job_code, salary, hire_date
from employee
order by salary desc;

-- alias 사용가능(select절 다음 순서에서만 적용가능. 즉 order by절에서만 사용가능)
select emp_id 사번,
        emp_name 사원명
from employee
order by 사원명;

-- 1부터 시작하는 컬럼순서 사용가능(컬럼 추가,삭제시 변동될수있으므로 비추)
select *
from employee
order by 9 desc; --컬럼순서가 9번째인 salary를 내림차순으로 정렬


--====================================================================
-- BUILT - IN FUNCTION
--====================================================================
-- 일련의 실행 코드 작성해두고 호출해서 사용함
-- 반드시 하나의 리턴값을 가짐

-- 1. 단일행 함수(single-row function) : 각 행마다 반복 호출되어서 호출된 수만큼 결과를 리턴함
--      a. 문자처리 함수
--      b. 숫자처리 함수
--      c. 날짜처리 함수
--      d. 형변환 함수
--      e. 기타 함수

-- 2. 그룹함수(group function) : 여러행을 그룹핑한후, 그룹당 하나의 결과를 리턴함

----------------------------------------------------------------------------------------------
-- 단일행 함수
----------------------------------------------------------------------------------------------

--********************************************************************************************
-- a. 문자 처리함수
--********************************************************************************************

-- length(col) : number
-- 문자열의 길이를 리턴
select emp_name, length(emp_name)
from employee;
-- where절에서도 사용가능
select emp_name, email
from employee
where length(email) < 15;

-- lengthb(col)
-- 값의 byte수 리턴
select emp_name, lengthb(emp_name),
         email, lengthb(email)
from employee;

-- instr( string, search[, startposition[, occurence]] )
-- string에서 search가 위치한 index를 반환
-- oracle에서는 1-based index. index는 1부터 시작
-- startposition 검색시작위치
-- occurence 출현순서
select instr('kh정보교육원 국가정보원','정보'), --3(3번지에 있다)
        instr('kh정보교육원 국가정보원','안녕'), --0(값없음)
        instr('kh정보교육원 국가정보원','정보',5), --11(5번지부터 찾아라)
        instr('kh정보교육원 국가정보원 정보문화사','정보',1,3), --15(1번지부터 찾는데 3번째 발견된것)
        instr('kh정보교육원 국가정보원','정보',-1) --11(음수면 뒤에서부터 검색)
from dual;

-- email컬럼값중 @의 위치는?
select email, instr(email,'@')
from employee;

-- substr(string, startIndex[, length])
-- string에서 startIndex부터 length개수만큼 잘라내어 리턴
-- length생략시에는 문자열 끝까지 반환
select substr('show me the money',6,2), --me(6번지부터 2개를 잘라서 출력)
        substr('show me the money',6), -- me the money
        substr('show me the money',-5,3) --mon
from dual;


--@실습문제 : 사원명에서 성(1글자로 가정)만 중복없이 사전순으로 출력
select distinct substr(emp_name,1,1) 성
from employee
order by 성 asc;

-- lpad | rpad (string, byte[, padding_char])
-- byte수의 공간에 string을 대입하고, 남은 공간은 padding_char를 왼쪽 | 오른쪽에 채울것
-- padding char는 생략시 공백문자
select lpad(email, 20, '#'),
        rpad(email, 20, '#'),
        '[' || lpad(email, 20) || ']', --공백문자
        '[' || rpad(email, 20) || ']' --공백문자
from employee;

--@실습문제 : 남자사원만 사번, 사원명, 주민번호, 연봉 조회
--주민번호 뒤 6자리는 ****** 숨김처리할것

select emp_id,
        emp_name,
        rpad(substr(emp_no,1,7), 14, '*'),
        --substr(emp_no,1,8) || '*******'
        salary
from employee
where substr(emp_no,8,1) in ('1','3'); 


--********************************************************************************************
-- b. 숫자 처리함수
--********************************************************************************************

--mod(피젯수,젯수)
--나머지 함수, sql에는 나머지연산자 %가 없다

select mod(10,2), --0
        mod(10,3) --1
from dual;

--입사년도가 짝수인 사원 조회
select emp_name,
        extract(year from hire_date) year --날짜함수 : 년도만 추출
from employee
where mod(extract(year from hire_date),2) = 0
order by year;

--ceil(number)
--소수점 기준으로 올림
select ceil(123.456),
        ceil(123.456 * 100)  / 100 --부동소수점 방식으로 처리(소수점 이동시켜서 올림)
from dual;

--floor(number)
--소수점기준으로 버림
select floor(456.789),
        floor(456.789 * 10) / 10
from dual;

--round(number[, position])
--position 기준(기본값 0, 소수점기준)으로 반올림처리
select round(234.567),
        round(234.567,1), --소수점 1번째자리까지
        round(234.567,-1), --일의자리에서 반올림
        round(234.567,-2) --십의 자리에서 반올림 
from dual;

--trunc(number[, position])
--버림(자리수를 지정가능, floor보다 많이쓰임)
select trunc(123.567),
        trunc(123.567,2) --소수점이하 2번째자리까지 남기고 버림
from dual;




--********************************************************************************************
-- c. 날짜 처리함수
--********************************************************************************************
--날짜형 + 숫자 = 날짜형
--날짜형 - 날짜형 = 숫자형

--add_months(date,number)
--date기준으로 몇달(number) 전후의 날짜형을 리턴
select sysdate, --오늘날짜
        sysdate + 5,
        add_months(sysdate,1), --1달후
        add_months(sysdate,-1), --1달전
        add_months(sysdate+5,1) --말일을 가리킴(2월30일은 없으므로)
from dual;

--months_between(미래,과거)
--두 날짜형의 개월수 차이를 리턴한다
select sysdate,
        to_date('2021/07/08'), --날짜형으로 변환함수
        trunc(months_between(to_date('2021/07/08'),sysdate),1) diff
from dual;

--이름, 입사일, 근무개월수(n개월), 근무개월수(n년 m개월) 조회
select emp_name,
        hire_date,
        trunc(months_between(sysdate,hire_date)) || '개월' "근무개월수(n개월)",
        trunc(months_between(sysdate,hire_date) / 12) || '년'
        || trunc(mod(months_between(sysdate,hire_date),12)) || '개월' "근무개월수(n년 m개월)"
from employee;


--extract(year | month | day | hour | minute | second   from date) : number
--날짜형 데이터에서 특정필드만 숫자형으로 리턴
select extract(year from sysdate) yyyy,
        extract(month from sysdate) mm,
        extract(day from sysdate) dd,
        extract(hour from cast(sysdate as timestamp)) hh, --시분초는 바로 추출할수없으므로 형변환이 필요하다
        extract(minute from cast(sysdate as timestamp)) mi,
        extract(second from cast(sysdate as timestamp)) ss
from dual;

--trunc(date)
--시분초 정보를 제외한 년월일 정보만 리턴
select to_char(sysdate, 'yyyy/mm/dd hh24:mi:ss') date1, --문자형으로 변환
        to_char(trunc(sysdate), 'yyyy/mm/dd hh24:mi:ss') date2 --d-day계산시 시분초를 날리고 계산에 사용가능 
from dual;



--********************************************************************************************
-- d. 형변환함수
--********************************************************************************************
/*
              to_char          to_date
            ----------->    --------->
    number          string          date
            <----------     <---------
             to_number        to_char
             
*/


--to_char(date | number[ , format])

select to_char(sysdate, 'yyyy/mm/dd pm hh24:mi:ss (day)') now, --(dy) : 월
        to_char(sysdate, 'fmyyyy/mm/dd pm hh24:mi:ss (day)') now, --fm : 형식문자로 인한 공백 또는 앞글자 0을 제거
        to_char(sysdate, 'yyyy"년" mm"월" dd"일" ') now --""로 묶어줘야함
from dual;

select to_char(1234567,'fml9,999,999,999') won, --L : 지역화폐,
        to_char(1234567,'fml9,999') won, --자리수가 모자라 오류(형식문자 자리수를 충분히 줘야한다)
        to_char(123.4,'9999.99') won, --소수점 이상의 빈자리는 공란, 소수점이하 빈자리는 0처리 
        to_char(123.4,'0000.00') won --빈자리는 모두 0처리
from dual;

--이름,급여(3자리 콤마),입사일(1990-9-3(화))을 조회
select emp_name 이름,
        to_char(salary,'fm9,999,999,999') 급여,
        to_char(hire_date,'fmyyyy-mm-dd (dy)') 입사일
from employee;


--to_number(string, format)
select to_number('1,234,567','9,999,999') + 100,
--      '1,234,567' + 100  오류발생(형변환필요)
         to_number('￦3,000','L9,999') + 100 --ㄹ한자로 해야함
from dual;

--자동형변환 지원
select '1000' + 100,
        '99' + 1
from dual;

--to_date(string, format)
--string이 작성된 형식문자 format으로 전달
select to_date('2020/09/09', 'yyyy/mm/dd') + 1 --날짜 + 숫자 = 날짜
from dual;

--'2021/07/08 21:50:00' 를 2시간후의 날짜 정보를 yyyy/mm/dd hh24:mi:ss형식으로 출력
select to_char(to_date('2021/07/08 21:50:00', 'yyyy/mm/dd hh24:mi:ss') + (2/24) ,'yyyy/mm/dd hh24:mi:ss')
from dual;

--현재시각 기준 1일 2시간 3분 4초후의 날짜 정보를 yyyy/mm/dd hh24:mi:ss형식으로 출력
select to_char(sysdate +1 + (2/24) + (3/(24*60)) + (4/(24*60*60)),'yyyy/mm/dd hh24:mi:ss')
from dual;

--기간타임
--interval year to month : 년월기간
--interval date to second : 일시분초 기간

--1년 2개월 3일 4시간 5분 6초후 조회
select to_char(add_months(sysdate,14) + 3 + (4/24) + (5/(24*60)) + (6/(24*60*60)) ,'yyyy/mm/dd hh24:mi:ss') result
from dual;

select to_char(sysdate + to_yminterval('01-02') + to_dsinterval('3 04:05:06'),
        'yyyy/mm/dd hh24:mi:ss') result
from dual;

--numtodsinterval(diff,unit)
--numtoyminterval(diff,unit)
--diff : 날짜차이
--unit : year | month | day | hour | minute | second
select extract(day from 
        numtodsinterval( 
        to_date('20210708','yyyymmdd') - sysdate,'day')) diff, --day만 추출
        numtodsinterval( 
        to_date('20210708','yyyymmdd') - sysdate,'day') diff
from dual;



--********************************************************************************************
-- e. 기타함수
--********************************************************************************************
--null처리함수
--nvl(col, nullvalue)

--nvl2(col, notnullvalue, nullvalue)
--col값이 null이 아니면 두번째인자를 리턴, null이면 세번째인자를 리턴
select emp_name,
        bonus,
        nvl(bonus, 0) nvl1,
        nvl2(bonus, '있음', '없음') nvl2
from employee;


--선택함수1
--decode(expr, 값1, 결과값1, 값2, 결과값2, ....[, 기본값])
select emp_name,
        emp_no,
        decode(substr(emp_no,8,1), '1', '남', '2', '여', '3', '남', '4', '여') gender,
        decode(substr(emp_no,8,1), '1', '남', '3', '남', '여') gender --기본값 '여'
from employee;

--직급코드에 따라서 J1-대표, J2/J3-임원, 나머지는 평사원으로 출력(사원명,직급코드,직위)
select emp_name,
        job_code,
        decode(job_code,'J1','대표','J2','임원','J3','임원','평사원') 직위
from employee;

--where절에도 사용가능
--여사원만 조회
select emp_name,
         emp_no
from employee
where decode(substr(emp_no,8,1), '1', '남', '3', '남', '여') = '여'; 


--선택함수2
--case
/*
type1(decode와 유사)

case 표현식
    when 값1 then 결과1
    when 값2 then 결과2
    when 값3 then 결과3
    ...
    [else 기본값]
    end

type2

case (true/false로 떨어질수있는 조건식을 줘야함)
    when 조건식1 then 결과1
    when 조건식2 then 결과2
    ....
    [else 기본값]
    end

*/

--type1
select emp_no,
        case substr(emp_no,8,1)
            when '1' then '남'
            when '3' then '남'
            else '여'
            end gender
from employee;

--type2
select emp_no,
        case 
            when substr(emp_no,8,1) = '1'  then '남'
            when substr(emp_no,8,1) = '3' then '남'
            else '여'
            end gender
from employee;

select emp_name, 
        job_code,
        case 
            when job_code = 'J1'  then '대표'
            when job_code in ('J2','J3') then '임원'
            else '평사원'
            end 직급코드
from employee;



----------------------------------------------------------------------------------------------
-- 그룹행 함수
----------------------------------------------------------------------------------------------
--여러행을 그룹핑하고, 그룹당 하나의 결과를 리턴하는 함수
--모든 행을 하나의 그룹, 또는 group by를 통해서 세부그룹지정이 가능하다

--sum(col) 모든행의 salary값을 하나의 그룹으로
select sum(salary),
--      sum(salary),emp_name 그룹함수의 결과와 일반컬럼을 동시에 조회할수없다
        sum(bonus), --null인 컬럼은 제외하고 누계처리
        sum(salary + (salary * nvl(bonus,0))) --가공된 컬럼(원래없는컬럼)도 그룹함수 가능
from employee;


--avg(col)
--평균
select round(avg(salary),1) avg,
        to_char(round(avg(salary),1), 'fmL9,999,999') avg
from employee;

--부서코드가 D5인 부서원의 평균급여 조회
select to_char(round(avg(salary), 1), 'fmL9,999,999') avg
from employee
where dept_code = 'D5';

--남자사원의 평균급여 조회
select to_char(round(avg(salary), 1), 'fmL9,999,999') avg
from employee
where substr(emp_no,8,1) in ('1','3') ;


--count(col)
--null이 아닌 컬럼의 개수
--*모든 컬럼, 즉 하나의 행을 의미
select count(emp_name),
        count(bonus), --bonus컬럼이 null이 아닌 행의 수
        count(dept_code),
        count(*)
from employee;

--보너스를 받는 사원수 조회(where절 이용)
select count(*)
from employee
where bonus is not null;

select sum(
        case
            when bonus is not null then 1
            when bonus is null then 0 --이것도 필요없긴하다
            end 
            ) bonusman --가상컬럼을 만들어서 다더하면 9가 나온다
from employee;

--사원이 속한 부서 총수(중복없음)
select count(distinct dept_code)
from employee;

--max(col) | min(col)
--숫자, 날짜(과거->미래), 문자(ㄱ->ㅎ)
select max(salary), min(salary),
        max(hire_date), min(hire_date),
        max(emp_name), min(emp_name)
from employee;


--===================================================================================
--DQL2
--===================================================================================

--------------------------------------------------------------------------------------------------------------------------------------------
--GROUP BY
---------------------------------------------------------------------------------------------------------------------------------------------
--지정컬럼기준으로 세부적인 그룹핑이 가능하다
--group by구문없이는 전체를 하나의 그룹으로 취급한다
--group by 절에 명시한 컬럼만 select절에 사용가능하다
--일반컬럼 | 가공컬럼 가능
select sum(salary),
--        emp_name, 그룹함수의 결과와 일반컬럼을 동시에 조회할수없다
        dept_code
from employee
group by dept_code; --부서코드 별로 급여를 더해서 출력

select emp_name,dept_code,salary
from employee;

select job_code,
        trunc(avg(salary),1)
from employee
group by job_code
order by job_code;


--부서코드별 사원수,급여평균,급여합계 조회
select nvl(dept_code,'인턴') dept_code,
        count(*) 부서코드별사원수,
        to_char(trunc(avg(salary),1),'fmL9,999,999,999') 급여평균,
        to_char(sum(salary),'fmL9,999,999,999') 급여합계
from employee
group by dept_code
order by dept_code;

--문자형은 왼쪽으로 정렬, 숫자형은 오른쪽으로 정렬됨

--성별 인원수 ,평균급여 조회
select decode(substr(emp_no,8,1),'1','남','3','남','여')  gender,
        count(*),
        to_char(trunc(avg(salary),1),'fmL9,999,999,999') 급여평균
from employee
group by decode(substr(emp_no,8,1),'1','남','3','남','여'); 

--직급코드 J1을 제외하고, 입사년도별 인원수를 조회
select  extract(year from hire_date) 입사년도,
        count(*)
from employee
where job_code != 'J1'
group by extract(year from hire_date); 

--두개이상의 컬럼으로 그룹핑 가능
select nvl(dept_code,'인턴') dept_code,
        job_code,
        count(*)
from employee
group by dept_code, job_code
order by 1,2;

--부서별 성별 인원수 조회
select     dept_code 부서코드,
            decode(substr(emp_no,8,1),'1','남','3','남','여') 성별,
            count(*)
from employee
group by dept_code,decode(substr(emp_no,8,1),'1','남','3','남','여')
order by 1,2;




---------------------------------------------------------------------------------------------------------------------------------------------
--HAVING
---------------------------------------------------------------------------------------------------------------------------------------------
--group by 이후 조건절

--부서별 평균 급여가 3,000,000원 이상인 부서만 조회

select dept_code,
        trunc(avg(salary)) avg
from employee
--where avg(salary) >= 3000000 그룹함수는 where절에 사용불가
group by dept_code
having avg(salary) >= 3000000
order by 1;

--직급별 인원수가 3명이상인 직급과 인원수 조회
select job_code,
        count(*)
from employee
group by job_code
having count(*) >= 3
order  by 1;

--관리하는 사원이 2명이상인 manager의 아이디와 관리하는 사원수 조회
select manager_id,
        count(*)
from employee
where manager_id is not null
group by manager_id
having count(*) >= 2 --count(manager_id) >= 2로 해도 상관없다
order by 1;


--rollup | cube(col1, col2...)
--group by절에 사용하는 함수
--그룹핑 결과에 대해 소계를 제공
--rollup 지정컬럼에 대해 단방향 소계 제공
--cube 지정컬럼에 대해 양방향 소계 제공
--지정컬럼이 하나인 경우, rollup/cube의 결과는 같다
select dept_code,
        count(*)
from employee
group by rollup(dept_code); --부서코드별로 그룹한 행의 총 합을 계산한 행을 추가한다

select dept_code,
        count(*)
from employee
group by cube(dept_code); 


--grouping()
--실제데이터(0을 리턴) | 집계데이터(1을 리턴) 컬럼을 구분하는 함수
--실제데이터 : D1,D2,null,.....
--집계데이터 : rollup | cube 로 나온 null

select decode(grouping(dept_code),0,nvl(dept_code,'인턴'),1,'합계') dept_code,
--        grouping(dept_code),
        count(*)
from employee
group by rollup(dept_code); 

--두개이상의 컬럼을 rollup | cube에 전달하는 경우
select decode(grouping(dept_code),0,nvl(dept_code,'인턴'),'합계') dept_code,
        decode(grouping(job_code),0,job_code,1,'소계') job_code,
        count(*)
from employee
group by rollup(dept_code, job_code)
order by 1,2;


select decode(grouping(dept_code),0,nvl(dept_code,'intern'),'소계') dept_code,
        decode(grouping(job_code),0,job_code,'소계') job_code,
        count(*)
from employee
group by cube(dept_code, job_code) --직급별 소계도 계산해준다
order by 1,2;


/*
select 5
from 1
where 2
group by 3
having 4
order by 6
*/

--relation 만들기
--가로방향 합치기 JOIN(행 + 행) 
--세로방향 합치기 UNION(열 + 열)


--==========================================================================
--JOIN(DQL안의 내용)
--==========================================================================
--두개이상의 테이블을 연결해서 하나의 가상테이블(relation)을 생성
--기준컬럼을 가지고 행을 연결

--송종기 사원의 부서명을 조회
select * --dept_code = D9
from employee
where emp_name = '송종기';

select dept_title --총무부 
from department
where dept_id = 'D9';

--두 테이블을 연결
select *
from employee E join department D    --테이블 별칭에는 as나 "" 를 사용하지않는다
    on E.dept_code = D.dept_id; --employee테이블의 dept_code가 department테이블의 dept_id와 같으면 두 테이블을 연결

--송종기사원의 부서명 조회
select D.dept_title
from employee E join department D
    on E.dept_code = D.dept_id
where E.emp_name = '송종기';

--join 종류
--1. EQUI-JOIN 동등비교조건(=)에 의한 조인
--2. NON-EQUI JOIN 동등비교조건이 아닌(between and, in, not in, like, != 등) 조인

--join 문법
--1. ANSI 표준문법 : 모든 DBMS 공통문법
--2. Vendor별 문법 : DBMS별로 지원하는 문법. 오라클전용문법

--테이블 별칭
select emp_name,
--       job_code, --employee 테이블의 job_code인지 job테이블의 job_code인지 모호해서 에러
        employee.job_code,
        job_name
from employee join job
    on employee.job_code = job.job_code;

--별칭사용하면 간략화된다(대소문자 구분x)    
select E.emp_name,
        J.job_code,
        J.job_name
from employee  E join job J
    on E.job_code = J.job_code;
    
-- 기준컬럼명이 좌우테이블에서 동일하다면, on 대신 using 사용가능 -> job_code 컬럼이 맨앞으로 끄집어낸다
-- using을 사용한 경우는 해당컬럼에 별칭을 사용할 수 없다
-- E.job_code를 하면 오류 발생(ORA-25154: column part of USING clause cannot have qualifier )
select E.emp_name,
        job_code, --별칭을 사용할수없다
        J.job_name
from employee E join job J
    using(job_code);
    


--EQUI-JOIN 종류
/*
1. inner join : 교집합

2. outer join : 합집합
    - left outer join 왼쪽테이블 기준 합집합
    - right outer join 오른쪽테이블 기준 합집합
    - full outer join 양쪽테이블 기준 합집합

3. cross join : 두 테이블간의 조인할수있는 최대경우의 수를 표현
    
4. self join : 같은 테이블의 조인
    
5. multiple join : 3개이상의 테이블을 조인(다중조인)


*/

---------------------------------------------------------------------------------------------------------------------
--INNER JOIN
---------------------------------------------------------------------------------------------------------------------
-- A (inner) join B
-- 교집합
-- 1. 기준컬럼값이 null인 경우 결과집합에서 제외
-- 2. 기준컬럼값이 상대테이블 존재하지 않는 경우 결과집합에서 제외

--1. employee에서 dept_code가 null인 행 제외 : 인턴사원2행 제외 
--2. department에서 dept_id가 D3,D4,D7인 행은 제외 
select * --총 22행
from employee E join department D
    on E.dept_code = D.dept_id;


--(oracle 전용문법)
select *
from employee E , department D --,로 구분
where E.dept_code = D.dept_id; --where절에서 조인조건 제시, 컬럼조건을 추가하고싶으면 and로 연결

--제외된 행이 없는 경우
select *
from employee E join job J
    on E.job_code = J.job_code;

--(oracle 전용문법)
select *
from employee E , job J
where E.job_code = J.job_code; --oracle문법에서는 using사용불가


-----------------------------------------------------------------------------------------------------------------
--OUTER JOIN
-----------------------------------------------------------------------------------------------------------------
--1. left (outer) join : outer생략가능
--왼쪽 테이블 기준
--왼쪽 테이블 모든 행이 포함, 오른쪽 테이블에는 on조건절에 만족하는 행만 포함

-- 24행 = 22행 + 2행(employee의 dept_code가 null인행)
select *
from employee E left outer join department D
    on E.dept_code = D.dept_id;
    
--(oracle문법)
--기준테이블의 반대편 컬럼에 (+)를 추가
select *
from employee E, department D
where E.dept_code = D.dept_id(+);
    
    
--2. right (outer) join 
--오른쪽 테이블 기준
--오른쪽 테이블 모든 행이 포함, 왼쪽 테이블에는 on조건절에 만족하는 행만 포함

--25행 = 22행 + 3행(department의 D3,D4,D7행)
select *
from employee E right join department D
    on E.dept_code = D.dept_id;

--(oracle문법)
--기준테이블의 반대편 컬럼에 (+)를 추가
select *
from employee E, department D
where E.dept_code(+) = D.dept_id;


--3. full (outer) join
--완전조인
--좌우 테이블 모두 포함

--27행 = 22행 + 2행(left) + 3행(right)
select *
from employee E full join department D
    on E.dept_code = D.dept_id;

--(oracle문법)에서는 full outer join을 지원하지않는다


--사원명/부서명 조회시
--부서지정이 안된 사원은 제외 : inner join
--부서지정이 안된 사원도 포함 : left join
--사원배정이 안된 부서도 포함 : right join



-----------------------------------------------------------------------------------------------------------------
--CROSS JOIN
-----------------------------------------------------------------------------------------------------------------
--상호조인
--on조건없이 왼쪽 테이블 행과 오른쪽 테이블 행이 연결될수있는 모든 경우의 수를 포함한 결과집합
--Cartensian's Product

--216 = 24(employee) * 9(department)
select *
from employee E cross join department D;

--(oracle문법)
select *
from employee E, department D;


--일반 컬럼, 그룹함수결과를 함께 조회할때 사용(원래는 안됐었음)
select trunc(avg(salary))
from employee;

select emp_name,salary,avg
from employee E cross join (select trunc(avg(salary)) avg
                                            from employee) A;            --1행1열짜리 가상테이블이라 치고 모든 행에 붙인다



-----------------------------------------------------------------------------------------------------------------
--SELF JOIN
-----------------------------------------------------------------------------------------------------------------
--같은 테이블을 좌/우측 테이블로 사용

--사번,사원명,관리자사번,관리자명 조회

select E1.emp_id,
        E1.emp_name,
        E1.manager_id, --E2.emp_id와 동일
        E2.emp_name
from employee E1 join employee E2
    on E1.manager_id = E2.emp_id;

--(oracle 문법)
select E1.emp_id,
        E1.emp_name,
        E1.manager_id,
        E2.emp_name
from employee E1, employee E2
where E1.manager_id = E2.emp_id;

-----------------------------------------------------------------------------------------------------------------
--MULTIPLE JOIN
-----------------------------------------------------------------------------------------------------------------
--한번에 좌우 두 테이블씩 조인하여 3개 이상의 테이블을 연결함

--사원명,부서명,지역명,직급명
select * from employee; --E.dept_code
select * from department; --D.dept_id, D.location_id
select * from location; --L.local_code

select E.emp_name,
        D.dept_title,
        L.local_name,
        J.job_name        
from employee E
    join job J --누락되는 데이터가 없으므로 job 테이블의 join 순서는 상관없다
        on E.job_code = J.job_code
    join department D    --조인하는 순서를 잘 고려해야한다(공통된컬럼이 없는 테이블을 먼저조인하면 안된다) 
        on E.dept_code = D.dept_id
    join location L
        on D.location_id = L.local_code
where E.emp_name = '송종기';


select E.emp_name,
        D.dept_title,
        L.local_name
from employee E                --인턴사원도 포함하려면 left join을 해야하는데 끝까지 유지해야 데이터가 누락되지않는 경우가 있다(join을 두번사용하므로 두번다 left join으로)
    left join department D
        on E.dept_code = D.dept_id
    left join location L
        on D.location_id = L.local_code;

        
--(oracle 문법)
select *
from employee E, department D, location L, job J     --테이블 순서가 상관없다
where E.dept_code = D.dept_id(+)
    and D.location_id = L.local_code(+)
    and E.job_code = J.job_code;


         


--직급이 대리,과장이면서 ASIA 지역에 근무하는 사원조회
--사번,이름,직급명(job),부서명(dept_title),급여,근무지역(local_name),국가(national_name)
--employee,department,location,nation,job
select E.emp_id 사번,
        E.emp_name 이름,
        J.job_name 직급명,
        D.dept_title 부서명,
        E.salary 급여,
        L.local_name 근무지역,
        N.national_name 국가
from employee E 
    join department D    
        on E.dept_code = D.dept_id
    join location L
        on D.location_id = L.local_code
    join nation N
        on L.national_code = N.national_code
    join job J
         on E.job_code = J.job_code
where J.job_name in ('대리','과장') and L.local_name like 'ASIA%';



--=====================================================================

---------------------------------------------------------------------------------------------------------------------
--NON-EQUI JOIN
---------------------------------------------------------------------------------------------------------------------
--동등비교조건이 없다
--employee, sal_grade 테이블을 조인
--employee 테이블의 sal_level컬럼이 없다고 가정
--employee.salary 컬럼과 sal_grade.min_sal | sal.grade.max_sal을 비교해서 join

select * from employee;
select * from sal_grade;

select *
from employee E
    join sal_grade S
        on E.salary between S.min_sal and S.max_sal;

--조인조건절에 따라 1행에 여러행이 연결된 결과를 얻을수있다
select *
from employee E
    join department D
        on E.dept_code != D.dept_id;
        
        
        


--==============================================================
--SET OPERATOR
--==============================================================
--집합연산자, entitiy를 컬럼수가 동일하다는 조건하에 상하로 연결한것
--select절의 컬럼수가 동일해야함
--컬럼별 자료형이 상호호환 가능해야한다. 문자형(char, varchar2)끼리는 ok, 날짜형 + 문자열은 ERROR
--컬럼명이 다른경우, 첫번째 entity의 컬럼명을 결과집합에 반영
--order by는 마지막 entity에서 딱 한번만 사용가능



--union 합집합
--union all 합집합
--intersect 교집합
--minus 차집합

/*
A = {1,3,2,5}
B = {2,4,6}

A union B       => {1,2,3,4,5,6} 중복제거,첫번째컬럼 기준 오름차순 정렬
A union all B   => {1,3,2,5,2,4,6} 중복제거x,정렬x
A intersect B   => {2}
A minus B       => {1,3,5}
*/

-----------------------------------------------------------------------------
--UNION | UNION ALL
-----------------------------------------------------------------------------
-- A : D5부서원의 사번, 사원명, 부서코드, 급여
select emp_id, emp_name, dept_code, salary
from employee
where dept_code = 'D5';

-- B : 급여가 300만원이 넘는 사원조회(사번, 사원명, 부서코드, 급여)
select emp_id, emp_name, dept_code, salary
from employee
where salary > 3000000;

-- A UNION B
select emp_id, emp_name, dept_code, salary
from employee
where dept_code = 'D5'
--order by salary 마지막 entity에서만 사용가능
union
select emp_id, emp_name, dept_code, salary --컬럼수 또는 위치가 동일하지않아도 오류
from employee
where salary > 3000000;


-- A UNION ALL B
select emp_id, emp_name, dept_code, salary
from employee
where dept_code = 'D5'
union all
select emp_id, emp_name, dept_code, salary --컬럼수 또는 위치가 동일하지않아도 오류
from employee
where salary > 3000000;


-----------------------------------------------------------------------------
--INTERSECT | MINUS
-----------------------------------------------------------------------------
-- A INTERSECT B
select emp_id, emp_name, dept_code, salary
from employee
where dept_code = 'D5'
intersect
select emp_id, emp_name, dept_code, salary 
from employee
where salary > 3000000;


-- A MINUS B
select emp_id, emp_name, dept_code, salary
from employee
where dept_code = 'D5'
minus
select emp_id, emp_name, dept_code, salary 
from employee
where salary > 3000000;

-- B MINUS A
select emp_id, emp_name, dept_code, salary 
from employee
where salary > 3000000
minus
select emp_id, emp_name, dept_code, salary
from employee
where dept_code = 'D5';




--==============================================================
--SUB QUERY
--==============================================================
--하나의 sql문(main-query)안에 종속된 또다른 sql(sub-query)
--존재하지않는 값, 조건에 근거한 검색등을 실행할때

--반드시 소괄호로 묶어서 처리할것
--sub-query내에는 order by 문법이 지원안함
--연산자 오른쪽에서 사용할것


--노옹철사원의 관리자 이름 조회
--1. 노옹철 사원행의 manager_id 조회
--2. emp_id가 조회한 manager_id와 동일한 행의 emp_name을 조회

select E2.emp_name
from employee E1 
    join employee E2
        on E1.manager_id = E2.emp_id
where E1.emp_name = '노옹철';


--sub-query(괄호안 query) 먼저 실행후 main-query 실행
select emp_name
from employee
where emp_id = (select manager_id
                        from employee
                        where emp_name = '노옹철'); --단일행 단일컬럼 서브쿼리

--SUB-QUERY 종류
/*
(일반서브쿼리)
리턴값의 개수에 따른 분류
1. 단일행 단일컬럼 서브쿼리
2. 다중행 단일컬럼 서브쿼리
3. 다중열 서브쿼리(단일행/다중행)
(상관서브쿼리)
4. 상관 서브쿼리 <-------------->일반서브쿼리
5. 스칼라 서브쿼리(select절 사용)

6. inline-view(from절 사용)
*/

-----------------------------------------------------------------------------------------------------------
--단일행 단일컬럼 서브쿼리
-----------------------------------------------------------------------------------------------------------
--서브쿼리 조회결과가 1행1열인 경우

--전체 평균 급여보다 많은 급여를 받는 사원 조회
select emp_name,
        salary,
        (select avg(salary)
        from employee) avg --독립적으로 사용가능
from employee
where salary > (select avg(salary)
                            from employee);

--윤은혜 사원과 같은 급여를 받는 사원 조회(사번,이름,급여)
select emp_id,
        emp_name,
        salary
from employee
where salary = (select salary
                     from employee
                     where emp_name = '윤은해')
        and emp_name != '윤은해';

--D1, D2 부서원 중에 D5부서의 평균급여보다 많은 급여를 받는 사원 조회(부서코드,사번,사원명,급여)
select dept_code,
        emp_id,
        emp_name,
        salary
from employee
where salary > (select avg(salary)
                    from employee
                    where dept_code = 'D5')
        and dept_code in ('D1','D2');
        
                    
-----------------------------------------------------------------------------------------------------------
--다중행 단일컬럼 서브쿼리
-----------------------------------------------------------------------------------------------------------
--연산자 in | not in | any | all | exists 와 함께 사용가능한 서브쿼리

--송종기, 하이유 사원이 속한 부서원 조회
select emp_name, dept_code
from employee
where dept_code in ( select dept_code
                            from employee
                            where emp_name in ('송종기','하이유')
                             );


--차태연, 전지연 사원의 급여등급(sal_level)과 같은 사원 조회(사원명,직급명,급여등급 조회)
select emp_name,
        job_name,
        sal_level
from employee E
    join job J
        using(job_code)
where sal_level in (select sal_level
                        from employee
                        where emp_name in ('차태연','전지연')
                        )
        and emp_name not in ('차태연','전지연');

--직급(job.job_name)이 대표, 부사장이 아닌 사원 조회(사번,사원명,직급코드)
select emp_id,
        emp_name,
        job_code
from employee
where job_code not in (
                                select job_code
                                from job
                                where job_name in ('대표','부사장')
                                );

--ASIA1 지역에 근무하는 사원 조회(사원명,부서코드)
select emp_name,
        dept_code
from employee
where dept_code in (
                            select dept_id
                            from department
                            where location_id = (
                                                        select local_code
                                                        from location
                                                        where local_name = 'ASIA1'
                                                        )
                            );


-----------------------------------------------------------------------------------------------------------
--다중열 서브쿼리
-----------------------------------------------------------------------------------------------------------
--서브쿼리의 리턴된 컬럼이 여러개인 경우

--퇴사한 사원과 같은 부서, 같은 직급의 사원 조회(사원명,부서코드,직급코드)
select dept_code, job_code
from employee
where quit_yn = 'Y';


select emp_name,
        dept_code,
        job_code
from employee
where (dept_code, job_code) = (
                                            select dept_code, job_code
                                            from employee
                                            where quit_yn = 'Y'
                                        );
/*
where dept_code = (
                            select dept_code
                            from employee
                            where quit_yn = 'Y'
                           )
    and job_code = (
                            select job_code
                            from employee
                            where quit_yn = 'Y'
                        );
*/

--manager가 존재하지 않는 사원과 같은 부서코드,직급코드를 가진 사원 조회
select emp_name,
        dept_code,
        job_code
from employee
where (nvl(dept_code, 'D0'), job_code) in ( --null도 포함시키키 : nvl함수 이용(여기서 D0는 임의의 수로 다른것을 써서 치환해도 상관없다)
                                            select nvl(dept_code, 'D0'), job_code
                                            from employee
                                            where manager_id is null
                                        );
                                        
                                        
--부서별 최대급여를 받는 사원 조회(사원명, 부서코드, 급여)
select emp_name,
        dept_code,
        salary
from employee
where (nvl(dept_code, 'D0'), salary) in (select nvl(dept_code, 'D0'), max(salary)
                    from employee
                    group by dept_code);



-----------------------------------------------------------------------------------------------------------
--상관 서브쿼리
-----------------------------------------------------------------------------------------------------------
--상호연관 서브쿼리
--메인쿼리의 값을 서브쿼리에 전달하고, 서브쿼리 수행후 결과를 다시 메인쿼리에 반환

--직급별 평균급여보다 많은 급여를 받는 사원 조회
--join으로 처리
select emp_name,job_code,salary
from employee E
    join (
            select job_code, avg(salary) avg
            from employee
            group by job_code
            ) EA
        using(job_code)
where E.salary > EA.avg
order by job_code; 


--상관서브쿼리로 처리
/*
select *
from employee E
where salary > (직급별 평균급여); --각행별로 비교해야하는 값이 다르다(직급이 다르므로)
*/

select emp_name, job_code, salary
from employee E --메인쿼리 테이블별칭이 반드시 필요
where salary > (
                     select avg(salary)
                     from employee
                     where job_code = E.job_code
                     );


--부서별 평균급여보다 적은 급여를 받는 사원 조회
select emp_name, dept_code, salary
from employee E 
where salary < (
                     select avg(salary)
                     from employee
                     where nvl(dept_code,'D0') = nvl(E.dept_code,'D0')
                     );


--exists 연산자
--exists(sub-query) sub-query에 행이 존재하면 참, 행이 존재하지않으면 거짓

select *
from employee
where 1 = 1; --무조건 true -> 모든행이 결과집합에 포함O, 결과행이 존재한다

select *
from employee
where 1 = 0; --무조건 false -> 아무행도 결과집합에 포함되지X, 결과행이 존재하지않는다


--행이 존재하는 sub-query : exists true
select *
from employee
where exists(
                select *
                from employee
                where 1 = 1);
--행이 존재하지않는 sub-query : exists false
select *
from employee
where exists(
                select *
                from employee
                where 1 = 0);

--관리하는 직원이 한명이라도 존재하는 관리자사원 조회
--내 emp_id값이 누군가의 manager_id로 사용된다면 관리자
--내 emp_id값이 누군가의 manager_id로 사용되지 않는다면 관리자가 아님
select emp_id, emp_name
from employee E
where exists(
                select * --보통 1로 사용(행이 존재하냐 존재하지않느냐 가 중요해서)
                from employee
                where manager_id = E.emp_id
                );


--부서테이블에서 실제 사원이 존재하는 부서만 조회(부서코드, 부서명)
select dept_id,
        dept_title
from department D
where exists(
                select 1
                from employee
                where dept_code = D.dept_id
                );
--부서테이블에서 실제 사원이 존재하지않는 부서만 조회
--not exists(sub-query) : sub-query행이 존재하지않으면 true, 존재하면 false
select dept_id,
        dept_title
from department D
where not exists(
                select 1
                from employee
                where dept_code = D.dept_id
                );

-- 최대/최소값 구하기(not-exist)
--가장 많은 급여를 받는 사원을 조회
--가장 많은 급여를 받는다 - > 본인보다 많은 급여를 받는 사원이 존재하지않는다
select *
from employee E1
where not exists (
                        select 1
                        from employee
                        where E1.salary < salary
                        );



-----------------------------------------------------------------------------------------------------------
--SCALA SUBQUERY
-----------------------------------------------------------------------------------------------------------
--서브쿼리의 실행결과가 1(단일행 단일컬럼)인 select절에 사용된 상관서브쿼리

--관리자이름 조회
select emp_name,
        nvl( (
         select emp_name
         from employee
         where emp_id = E.manager_id
        ), ' ') manager_name
from employee E;

--사원명, 부서명, 직급명 조회
select emp_name 사원명,
        (
        select dept_title
        from department
        where E.dept_code = dept_id
        ) 부서명,
        (
        select job_name
        from job
        where E.job_code = job_code
        ) 직급명
from employee E;



-----------------------------------------------------------------------------------------------------------
--INLINE VIEW
-----------------------------------------------------------------------------------------------------------
--from절에 사용된 subquery(cross join에서 사용한것). 가상테이블

--여사원의 사번, 사원명, 성별 조회

select emp_id, emp_name, gender --가상테이블에서 뽑아낸 컬럼만 조회가능
from (
            --가상테이블
            select emp_id,
                    emp_name,
                    decode(substr(emp_no,8,1) , '1', '남', '3','남','여') gender
            from employee
        )
where gender = '여';


--30 ~ 50살 사이의 여사원 조회
select *
from (
        select emp_id,
                emp_name,
                dept_code,
                decode(substr(emp_no,8,1) , '1', '남', '3','남','여') gender,
                extract(year from sysdate) - (decode(substr(emp_no,8,1), '1', 1900, '2', 1900, 2000) + substr(emp_no,1,2)) + 1 age
        from employee
        )
where gender = '여' and age between 30 and 50;





--======================================================================
--고급쿼리
--======================================================================

-------------------------------------------------------------------------------------------------------------------
--TOP-N 분석
-------------------------------------------------------------------------------------------------------------------
--급여를 많이 받는 Top-5, 입사일이 가장 최근인 Top-10조회등


--rownum | rowid
--rownum : 테이블에 레코드 추가시 1부터 1씩 증가하면서 부여된 일련번호. 부여된 번호는 변경불가
--             INLINE VIEW 생성시, where절 사용시 rownum은 새로 부여된다
--rowid : 테이블 특정 레코드에 접근하기 위한 논리적 주소값(hashcode같은것)
select rownum,
        rowid,
        E.*
from employee E;

--where절 사용시 rownum 새로부여(206번이 1번을 부여받음)
select rownum,
        E.*
from employee E
where dept_code = 'D5';


--급여를 많이 받는 Top-5
select rownum, 
        E.*
from (select 
                --rownum old,
                emp_name, 
                salary
        from employee   
        order by salary desc
        ) E
where rownum between 1 and 5;


--입사일이 빠른 10명 조회
select *
from (
        select 
                emp_name,
                hire_date
        from employee
        order by 2 
        ) E
where rownum between 1 and 10;

--입사일이 빠른 순서로 6번째에서 10번째 사원 조회
--rownum은 where절이 시작하면서 부여되고 where절이 끝나면 모든 행에 대해 부여가 끝난다
--offset이 있다면(건너뛴 숫자가 있다면) 정상적으로 가져올수없다
--INLINE VIEW를 한계층 더 사용해야한다
select E.*
from(
        select rownum rnum,
                E.*
        from (
                select 
                        emp_name,
                        hire_date
                from employee
                order by 2 
                ) E
        )E
where rnum between 6 and 10;


--직급이 대리인 사원중에 연봉 Top-3 조회(순위,이름,연봉)
--1위부터3위면 한계층더 필요없을듯
select E.*
from
        (
                select rownum rnum,E.*
                from (
                        select 
                                emp_name,
                                (salary + (salary * nvl(bonus,0))) * 12 연봉
                        from employee
                        where job_code = (select job_code
                                                 from job
                                                 where job_name = '대리')
                        order by 2 desc
                        ) E
        )E
where rnum between 1 and 3;


--부서별 평균급여 Top-3 조회(순위,부서명,평균급여)

select *
from (
            select rownum rnum,
                    E.*
            from (
                    select (
                                select dept_title
                                from department
                                where dept_id = E1.dept_code
                            ) 부서명,
                            trunc(avg(salary)) 평균급여
                    from employee E1        
                    group by dept_code
                    order by 2 desc
                    ) E
        )
where rnum between 1 and 3;



/*
select E.*
from (
            select rownum, E.*
            from (
                    정렬된 resultset
                    ) E
        )E
where rnum between 시작 and 끝;
*/


--with 구문
--INLINE VIEW 서브쿼리에 별칭을 지정해서 재사용하게 함
--입사일이 빠른 순서로 6번째에서 10번째 사원 조회
with emp_hire_date_asc
as
(
select emp_name,
        hire_date
from employee
order by hire_date asc
)

select E.*
from(
        select rownum rnum,
                E.*
        from emp_hire_date_asc E
        )E
where rnum between 6 and 10;


-------------------------------------------------------------------------------------------------------------------
--WINDOW FUNCTION
-------------------------------------------------------------------------------------------------------------------
--행과 행간의 관계를 쉽게 정의하기 위한 표준함수
--1.순위함수
--2.집계함수
--3.분석함수

/*
window_function(args) over([partition by 절][order by 절][windowing절])
1. args 윈도우함수 인자 0 ~ n개 지정
2. partition by 절 : 그룹핑 기준 컬럼
3. order by 절 : 정렬기준 컬럼
4. windowing 절 : 처리할 행의 범위를 지정
*/


--rank() over() : 순위를 지정
--dense_rank() over() : 빠진 숫자없이 순위를 지정
select emp_name,
        salary,
        rank() over(order by salary desc) rank, --순위동률시 공동순위지정 및 다음 순위 계산해서 지정
        dense_rank() over(order by salary desc) rank --순위동률이 있을때 다음 순위 지정시 빠진숫자없이 지정
from employee;

--그룹핑에 따른 순위지정
--dept_code별 급여순위 조회
select emp_name,
        dept_code,
        salary,
        rank() over(partition by dept_code order by salary desc) rank_by_dept
from employee;

--3위까지만 출력
select E.*
from (
        select emp_name,
                dept_code,
                salary,
                rank() over(partition by dept_code order by salary desc) rank_by_dept
        from employee
        ) E
where rank_by_dept between 1 and 3;

--sum() over()
--일반 컬럼과 같이 사용할수있다
select emp_name,
        salary,
        dept_code,
--      (select sum(salary) from employee) sum
        sum(salary) over() "전체사원급여합계",
        sum(salary) over(partition by dept_code) "부서별급여합계",
        sum(salary) over(partition by dept_code order by salary) "부서별 급여누계 급여" --급여오름차순으로 누계 
from employee;


--avg() over()
--부서별 평균급여
select emp_name,
        dept_code,
        salary,
        trunc(avg(salary) over(partition by dept_code)) "부서별 평균급여"
from employee;


--count() over()
select emp_name,
        dept_code,
        count(*) over(partition by dept_code) cnt_by_dept
from employee;



--========================================================================
--DML
--========================================================================
--Data Manaipulation Lanaguage 데이터 조작어
--CRUD : Create Retrieve(Read) Update Delete 테이블 행에 대한 명령어
--insert 행추가
--update 행수정
--delete 행삭제
--select(DQL)

-------------------------------------------------------------------------------------------------------------------
--INSERT
-------------------------------------------------------------------------------------------------------------------
--1. insert into 테이블 values(컬럼1값, 컬럼2값,....); 
--  모든 컬럼은 빠짐없이 순서대로 작성해야 함

--2. insert into 테이블 (컬럼1, 컬럼2, .....) values (컬럼1값, 컬럼2값,......)
--  컬럼을 생략가능, 컬럼 순서도 자유롭다
--  not null컬럼이면서, 기본값이 없다면 생략이 불가능하다

create table dml_sample(
    id number,
    nick_name varchar2(100) default '홍길동',
    name varchar2(100) not null,
    enroll_date date default sysdate not null
);

select *
from dml_sample;

--타입1
insert into dml_sample
values(100, default, '신사임당', default);

insert into dml_sample
values(200, 'lee', '이황', to_date('99/12/25'));


--타입2
insert into dml_sample (id, nick_name, name, enroll_date)
values (200, '제임스', '이이', sysdate);

insert into dml_sample (name, enroll_date)
values ('세종', sysdate); --nullable한 컬럼은 생략가능하다. 기본값이 있다면 기본값이 적용된다

--ORA-01400: cannot insert NULL into ("KH"."DML_SAMPLE"."NAME")
insert into dml_sample(id, enroll_date)
values(300, sysdate); --not null이면서 기본값이 지정안된경우 생략할수있다

insert into dml_sample (name)
values('윤봉길');


--서브쿼리를 이용한 insert
create table emp_copy
as
select * 
from employee
where 1 = 2; -- false이므로 테이블 구조(컬럼)만 복사해서 테이블을 생성(데이터는 한 행도 추가되지않는다) 

--emp_copy 테이블 확인
select *
from emp_copy;

--employee 테이블 복사
insert into emp_copy (
    select *
    from employee
);

rollback;

--not null인 컬럼은 비워둘수없다
insert into emp_copy(emp_id, emp_name,emp_no,job_code, sal_level)(
    select emp_id,emp_name,emp_no,job_code, sal_level
    from employee
);


--기본값 확인 data_default
--nullable 컬럼에서 null여부 확인가능
select *
from user_tab_cols
where table_name = 'EMP_COPY';

--기본값 추가
alter table emp_copy
modify quit_yn  default 'N'
modify hire_date default sysdate;

--emp_copy 테이블 데이터 추가
insert into emp_copy(emp_id, emp_name, emp_no, email, job_code,sal_level)
values('400', '이재성', '931026-1167515', 'suver72@naver.com', 'J1', 'S1');

--insert all을 이용한 여러테이블에 동시에 데이터 추가
--서브쿼리를 이용해서 2개이상 테이블에 데이터를 추가, 조건부 추가도 가능

--입사일을 관리 테이블
create table emp_hire_date
as
select emp_id, emp_name, hire_date
from employee
where 1 = 2;


--매니저 관리 테이블
create table emp_manager
as
select emp_id,
        emp_name, 
        manager_id, 
        emp_name manager_name --별칭이 컬럼명으로 사용된다
from employee
where 1 = 2 ;

select * from emp_hire_date;
select * from emp_manager;

--manager_name(emp_name)을 null로 변경
alter table emp_manager
modify manager_name null;

--from 테이블과 to테이블의 컬럼명이 같아야한다
insert all
into emp_hire_date values(emp_id, emp_name, hire_date)
into emp_manager values(emp_id, emp_name, manager_id, manager_name)
select E.*,
        (select emp_name from employee where emp_id = E.manager_id) manager_name
from employee E;

--insert all을 이용한 여러행 한번에 추가하기

--오라클은 다음 문법을 지원하지않는다
--insert into dml_sample 
--values(1, '치킨', '홍길동'), (2, '고구마', '장발장'), (3, '베베', '유관순')

insert all
into dml_sample values(1, '치킨', '홍길동', default)
into dml_sample values(2, '고구마', '장발장', default)
into dml_sample values(2, '베베', '유관순', default)
select * from dual; --더미 쿼리(문법상 생략할수없기에 그냥 써논것. 의미없다)

select *
from dml_sample;

-----------------------------------------------------------------------------------------------------
--UPDATE
-----------------------------------------------------------------------------------------------------
--update실행후에 행의 수에는 변화가 없다
--0행, 1행 이상을 동시에 수정한다
--dml 처리된 행의 수를 반환



select * from emp_copy;

update emp_copy
set dept_code = 'D7', job_code = 'J3'
where emp_id = '202'; --where절에 없는 조건을 설정하면 오류가 아니라 0행 업데이트

update emp_copy
set salary = salary + 500000 -- += 복합대입연산자 사용불가
where dept_code = 'D5';

--서브쿼리를 이용한 update
--방명수 사원의 급여를 유재식사원과 동일하게 수정
update emp_copy
set salary = (select salary from emp_copy where emp_name = '유재식')
where emp_name = '방명수';

--임시환 사원의 직급을 과장, 부서를 해외영업3부로 수정하세요 
update emp_copy
set job_code = (
                     select job_code
                     from job
                     where job_name = '과장'
                     ),
    dept_code = (
                        select dept_id
                        from department
                        where dept_title = '해외영업3부'
                      )
where emp_name = '임시환';



------------------------------------------------------------------------------------------------------------
--DELETE
------------------------------------------------------------------------------------------------------------
select * from emp_copy;

--혹시모를 실행을 위해 평소 주석처리해둔다
delete from emp_copy
where emp_id = '211';



----------------------------------------------------------------------------------------
--TRUNCATE
----------------------------------------------------------------------------------------
--테이블의 행을 자르는 명령
--DDL명령어(create, alter, drop, truncate), 자동커밋이 되므로 롤백해도 돌아오지않는다
--before image생성 작업이 없으므로 실행속도가 빠름

truncate table emp_copy;

select * from emp_copy;



--===========================================================================
--DDL
--===========================================================================
--Data Definition Lanaguage 데이터 정의어
--데이터베이스 객체를 생성/수정/삭제할 수 있는 명령어
--create
--alter
--drop
--truncate

--객체 종류
--table, view, sequence, index, package, procedure, function, trigger, synonym, scheduler, user.........

--주석 comment
--테이블, 컬럼에 대한 주석을 달수있다(필수)
select *
from user_tab_comments;

select *
from user_col_comments
where table_name = 'TBL_FILES';

--테이블 주석
comment on table tbl_files is '파일경로테이블';

--컬럼주석
comment on column tbl_files.fileno is '파일 고유번호';
comment on column tbl_files.filepath is '';

-- 수정/삭제 명령은 없다
-- 수정은 덮어쓰기로 수정
-- ...is ''; 로 삭제


--======================================================================
--제약조건 CONSTRAINT
--======================================================================
--테이블 생성/수정시 컬럼값에 대한 제약조건 설정할수있다
--데이터에 대한 무결성을 보장하기 위한것
--무결성 : 데이터를 정확하고 일관되게 유지하는것

/*
1. not null : null을 허용하지 않음. 필수값
2. unique : 중복값을 허용하지않음
3. primary key : not null + unique 테이블 식별자로써 테이블당 1개 허용
4. foreign key : 데이터 참조 무결성 보장. 부모테이블의 데이터만 허용
5. check : 저장가능한 값의 범위/조건을 제한

foreign key를 행사하는 방법은 일절 추가하지 않음.
추가해놓고 수정할수없다. 일절 허용하지않음
*/

--제약 조건 확인
--user_constraints(컬럼명column_name이 없음)
--user_cons_columns(컬럼명 column_name이 있음)

select *
from user_constraints
where table_name = 'EMPLOYEE';

--Constraint_type C : check제약조건 | not null 제약조건
--Constraint_type U : unique
--Constraint_type P : primary key
--Constraint_type R :  foreign key

select *
from user_cons_columns
where table_name = 'EMPLOYEE';

-- 2개를 합쳐서 사용
--제약조건 검색
select constraint_name,
        uc.table_name,
        ucc.column_name,
        uc.constraint_type,
        uc.search_condition
from user_constraints uc
    join user_cons_columns ucc
        using(constraint_name)
where uc.table_name = 'EMPLOYEE';


-------------------------------------------------------------------------------------------------
--NOT NULL
-------------------------------------------------------------------------------------------------
--필수입력 컬럼에 not null 제약조건을 지정한다
--default값 다음에 컬럼레벨에 작성한다.
--보통 제약조건명을 지정하지않는다

create table tb_cons_nn (
    id varchar2(20) not null, --컬럼레벨에 작성
    name varchar2(100)
    --테이블레벨
);

insert into tb_cons_nn
values(null,'홍길동'); --null값 대입불가 오류발생


insert into tb_cons_nn values ('hoggd','홍길동');
select * from tb_cons_nn;


update tb_cons_nn
set id =''
where id = 'hoggd'; -- null로 수정도 불가





