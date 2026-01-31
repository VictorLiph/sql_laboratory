-- Creating a new table to remove duplicates

CREATE TABLE layoffs_staging (LIKE layoffs INCLUDING ALL);

insert into layoffs_staging select * from layoffs;


-- Finding duplicate datas  

with duplicates_cte as 
(
select *,
	   ROW_NUMBER() over (Partition by company,
	        	 				       location, 
									   industry, 
									   total_laid_off, 
									   percentage_laid_off, 
									   'date', 
									   stage, 
									   country, 
									   funds_raised_millions) as rownum 
									   
									   from layoffs_staging
)

select *  from duplicates_cte

where rownum > 1;

-- Removing duplicates with subqueries

DELETE FROM layoffs_staging 
WHERE (company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) 
IN (
  SELECT company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
  FROM (
    SELECT *, ROW_NUMBER() OVER (
      PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
    ) AS rownum
    FROM layoffs_staging
  ) t
  WHERE t.rownum > 1
);

-- Fiding null and blank values

select t1.company, 
       t1.industry, 
	   t2.company, 
	   t2.industry 
	   
from layoffs_staging as t1
join layoffs_staging as t2
	on t1.company = t2.company
	and t1.location = t2.location

where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

-- Standardizing to nulls

update layoffs_staging 
set industry = null
where industry = '';

-- Populating missing industries values 

UPDATE layoffs_staging AS t1
SET industry = t2.industry
FROM layoffs_staging AS t2
WHERE t1.company = t2.company
  AND t1.industry IS NULL
  AND t2.industry IS NOT NULL;

select * from layoffs_staging
where industry = null or industry = '';



