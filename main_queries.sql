create database project;
use project;
show tables;

-- SHEET 1

select * from country_state limit 10;
select * from customer_det limit 20;
select * from customer_income limit 10;
select * from loan_det limit 10;
select * from region_info;

ALTER TABLE region_info ADD PRIMARY KEY (Region_Id);



-- creating a new table 
create table customer_income_status as
select loan_id, customer_id, applicantincome, coapplicantincome,
property_area, loan_status,
case
	when applicantincome > 15000 then 'grade a'
	when applicantincome > 9000 then 'grade b'
	when applicantincome > 5000 then 'middle class customer'
    else 'low class'
end as income_grade
from customer_income;
select * from customer_income_status;

create table customer_interest_analysis as
select c.*, l.loanamount,
    case
        when applicantincome < 5000 and property_area = 'rural' then 3
        when applicantincome < 5000 and property_area = 'semi rural' then 3.5
        when applicantincome < 5000 and property_area = 'urban' then 5
        when applicantincome < 5000 and property_area = 'semi urban' then 2.5
        else 7
    end as monthly_interest_perc, (l.loanamount * (
        case
            when applicantincome < 5000 and property_area = 'rural' then 3
            when applicantincome < 5000 and property_area = 'semi rural' then 3.5
            when applicantincome < 5000 and property_area = 'urban' then 5
            when applicantincome < 5000 and property_area = 'semi urban' then 2.5
            else 7
        end) / 100) as monthly_interest_amt, round((l.loanamount * (
        case
            when applicantincome < 5000 and property_area = 'rural' then 3
            when applicantincome < 5000 and property_area = 'semi rural' then 3.5
            when applicantincome < 5000 and property_area = 'urban' then 5
            when applicantincome < 5000 and property_area = 'semi urban' then 2.5
            else 7
        end
    ) / 100) * 12,2) as annual_interest_amt
from customer_income_status c
join loan_det l on c.loan_id = l.loan_id;
select * from customer_interest_analysis;

-- SHEET 2


alter table loan_det
add column  loan_status varchar(50);

create table loan_cibil_score_status_details (
    loan_id varchar(20) primary key,
    customer_id varchar(20),
    loanamount varchar(50),
    loan_amount_term int,
    cibil_score int,
    cibil_status varchar(50)
);
-- row level
drop trigger if exists trg_loan_amt_check;


delimiter //

create trigger trg_cibil_status before insert on loan_cibil_score_status_details
for each row
begin
    if new.loanamount is null then set new.loanamount = 'loan still processing';
    end if;

    -- check cibil_score
    if new.cibil_score is null or new.cibil_score <= 0 then
        set new.cibil_status = 'loan rejected';
    elseif new.cibil_score > 900 then
        set new.cibil_status = 'high cibil score';
    elseif new.cibil_score > 750 then
        set new.cibil_status = 'no penalty';
    else
        set new.cibil_status = 'penalty customers';
    end if;
end;
//

delimiter ;



-- statement level

delimiter //

create trigger trg_cibil_classify
before insert on loan_det
for each row
begin
    if new.cibil_score is null or new.cibil_score <= 0 then
        set new.loan_status = 'loan rejected';
    elseif new.cibil_score > 900 then
        set new.loan_status = 'high cibil score';
    elseif new.cibil_score > 750 then
        set new.loan_status = 'no penalty';
    else
        set new.loan_status = 'penalty customers';
    end if;
end;
//

delimiter ;

insert into loan_cibil_score_status_details
(loan_id, customer_id, loanamount, loan_amount_term, cibil_score)
select loan_id, customer_id, loanamount, loan_amount_term, cibil_score
from loan_det;
show tables;

delete from loan_cibil_score_status_details
where cibil_status = 'loan rejected'
   or loanamount = 'loan still processing';
   
update loan_cibil_score_status_details
set loanamount = null
where loanamount = 'loan still processing';

alter table loan_cibil_score_status_details
modify column loanamount int,
modify column cibil_score int;


select * from loan_det;
select * from loan_cibil_score_status_details;

-- sheet 3

select count(*) from customer_det;
select * from customer_det;
describe customer_det;
select customer_id, gender, age from customer_det limit 20;

create table if not exists customer_det_backup as
select * from customer_det;

create table if not exists customer_gender_update (
  id int auto_increment primary key,
  customer_id varchar(50),
  old_gender varchar(20),
  new_gender varchar(20),
  changed_at datetime default current_timestamp
);

create table if not exists customer_age_update (
  id int auto_increment primary key,
  customer_id varchar(50),
  old_age int,
  new_age int,
  changed_at datetime default current_timestamp
);

start transaction;

insert into customer_gender_update (customer_id, old_gender, new_gender)
select customer_id,
       gender as old_gender,
	case lower(customer_id)
         when 'ip43018' then 'male'
         when 'ip43038' then 'male'
         when 'ip43006' then 'female'
         when 'ip43016' then 'female'
         when 'ip43508' then 'female'
         when 'ip43577' then 'female'
         when 'ip43589' then 'female'
         when 'ip43593' then 'female'
         else gender
       end as new_gender
from customer_det
where lower(customer_id) in (
  'ip43018','ip43038','ip43006','ip43016','ip43508','ip43577','ip43589','ip43593'
);

update customer_det
set gender = case lower(customer_id)
  when 'ip43018' then 'male'  
  when 'ip43038' then 'male'
  when 'ip43006' then 'female'
  when 'ip43016' then 'female'
  when 'ip43508' then 'female'
  when 'ip43577' then 'female'
  when 'ip43589' then 'female'
  when 'ip43593' then 'female'
  else gender
end
where lower(customer_id) in (
  'ip43018','ip43038','ip43006','ip43016','ip43508','ip43577','ip43589','ip43593'
);

-- verify changes
select customer_id, gender from customer_det
where lower(customer_id) in (
  'ip43018','ip43038','ip43006','ip43016','ip43508','ip43577','ip43589','ip43593'
);

select * from customer_gender_update
order by changed_at desc
limit 20;

select customer_id, gender
from customer_det
where lower(customer_id) in (
  'ip43006','ip43016','ip43018','ip43038','ip43508','ip43577','ip43589','ip43593'
);

select * 
from customer_gender_update
order by changed_at desc
limit 20;
commit;

start transaction;

insert into customer_age_update (customer_id, old_age, new_age)
select customer_id,
       age as old_age,
       case lower(customer_id)
         when 'ip43007' then 45
         when 'ip43009' then 32
         else age
       end as new_age
from customer_det
where lower(customer_id) in ('ip43007','ip43009');

update customer_det set age = case lower(customer_id)
  when 'ip43007' then 45
  when 'ip43009' then 32
  else age
end
where lower(customer_id) in ('ip43007','ip43009');

select customer_id, age from customer_det
where lower(customer_id) in ('ip43007','ip43009');

select * from customer_age_update
order by changed_at desc
limit 20;

select * from customer_det;

-- sheet 4


create table jointable1 as
select c.customer_id, c.customer_name, c.gender, c.age, c.married,
       c.education, c.self_employed, c.region_id,
       l.loan_id, l.loanamount, l.loan_amount_term, l.cibil_score, l.loan_status
from customer_det c
inner join loan_det l on c.customer_id = l.customer_id;

select * from jointable1 limit 10;


create table jointable2 as
select j.*, r.region
from jointable1 j
inner join region_info r on j.region_id = r.region_id;

select * from jointable2 limit 10;


create table jointable3 as
select j.*, ci.applicantincome, ci.coapplicantincome, ci.property_area
from jointable2 j
inner join customer_income ci on j.customer_id = ci.customer_id;

select * from jointable3 limit 10;


create table final_output as
select j.*, cs.postal_code, cs.segment, cs.state
from jointable3 j
inner join country_state cs on j.customer_id = cs.customer_id;

select * from final_output limit 10;


create table mismatched as
select f.customer_id, f.customer_name, f.gender, f.married, f.self_employed, f.loanamount
from final_output f
where f.loanamount is null
   or f.gender is null
   or f.married is null
   or f.self_employed is null;

select * from mismatched;

-- sheet 5

delimiter //

create procedure filter_high_cibil()
begin
    select loan_id, customer_id, loanamount, loan_amount_term, cibil_score, cibil_status
    from loan_cibil_score_status_details
    where lower(cibil_status) = 'high cibil score';
end;
//

create procedure filter_home_corp()
begin
    select customer_id, customer_name, segment, state, region, loanamount, loan_status
    from final_output
    where lower(segment) in ('home office', 'corporate');
end;
//

create procedure sheet5_output()
begin
    call filter_high_cibil();
    call filter_home_corp();
end;
//

delimiter ;

call filter_high_cibil();   -- output 3
call filter_home_corp();    -- output 4
call sheet5_output();       -- runs both

