select * from layoffs;


select count(Company) from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank alues
-- 4. Remove any Columns




create table layoffs_staging
like layoffs;

insert layoffs_staging 
select * from layoffs;

select * from layoffs_staging;


select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off,'date') as row_num
 from layoffs_staging;
 
 
 with duplicates_cte as
 (
 select *,
row_number() over(
partition by company,location, industry, total_laid_off, percentage_laid_off,'date', stage, country, funds_raised_millions) as row_num
 from layoffs_staging
 )
select * 
from duplicates_cte
where row_num > 1;



select * from layoffs_staging
where company = 'Oyster';

-- cant delete in cte, ex:
 with duplicates_cte as
 (
 select *,
row_number() over(
partition by company,location, industry, total_laid_off, percentage_laid_off,'date', stage, country, funds_raised_millions) as row_num
 from layoffs_staging
 )
delete
from duplicates_cte
where row_num > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2 where row_num >1;

insert into layoffs_staging2
select *,
row_number() over(
partition by company,location, industry, total_laid_off, percentage_laid_off,'date', stage, country, funds_raised_millions) as row_num
 from layoffs_staging;

delete from layoffs_staging2 where row_num >1;

SELECT * FROM layoffs LIMIT 10;



-- standardizing data 

select distinct company from layoffs_staging2;
select company, trim(company) from layoffs_staging2;



update layoffs_staging2
set company = trim(company);


-- checking each column is standadizing data..

select distinct industry from layoffs_staging2
order by 1;

select * from layoffs_staging2
where industry like 'sales';

-- as crypto and cryptocurrency is same industry we need to make it update to same name

update layoffs_staging2
set industry = 'crypto'
where industry like 'crypto%';


select distinct location from layoffs_staging2
order by 1;

select distinct country from layoffs_staging2
order by 1;

update layoffs_staging2
set country = 'United States'
where country like 'United States.';
-- or trailing

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;


select * from layoffs_staging2;

select `date` ,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;


update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');


alter table layoffs_staging2

modify column `date` date;


select * from layoffs_staging2
where industry is null
or industry = ' ';

select * from layoffs_staging2
where company = "Bally's Interactive"
;
-- if anything with empty rows and check the data of same copany and 
-- tally the industry type and join the rows
-- update and set then into null

update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    where(
    t1.industry is null 
    or t1.industry = ' ')
    and
    t2.industry is not null
    ;
update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    set t1.company = t2.company
 where(
    t1.industry is null 
    or t1.industry = ' ')
    and
    t2.industry is not null;


select * from layoffs_staging2;
-- deleting the null rows of below query bcz its the totals numbers
select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;
;
select * from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;









