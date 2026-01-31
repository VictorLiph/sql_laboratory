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



