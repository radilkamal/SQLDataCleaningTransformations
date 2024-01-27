--------DATA EXPLORATION USING SQL---------



--select * from  [dbo].[covid-deaths] order by 3,4

--select * from  [dbo].[covid-vaccinations] order by 3,4

select location, date, total_cases_per_million, new_cases, total_deaths, population
from  [dbo].[covid-deaths] 
order by 1,2

--Total deaths compared to total cases
select location, date, total_cases, total_deaths,  CASE
        WHEN TRY_CAST(total_cases AS float) = 0 OR TRY_CAST(total_cases AS float) IS NULL THEN NULL
        ELSE CAST(total_deaths AS float) / CAST(total_cases AS float) * 100
    END AS 'death percentage'
from  [dbo].[covid-deaths] 
where location like'%states%'
order by 1,2

-- Total cases vs population
select location, date, total_cases, population,  CASE
        WHEN TRY_CAST(population AS float) = 0 OR TRY_CAST(total_cases AS float) IS NULL THEN NULL
        ELSE CAST(total_cases AS float) / CAST(population AS float) * 100
    END AS 'cases percentage'
from  [dbo].[covid-deaths] 
--where location like'%states%'
order by 1,2

-- Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount,  CASE
        WHEN TRY_CAST(population AS float) = 0 OR TRY_CAST(max(total_cases) AS float) IS NULL THEN NULL
        ELSE CAST(max(total_cases) AS float) / CAST(population AS float) * 100
    END AS 'Percentage of Pop Infected'
from  [dbo].[covid-deaths] 
group by location, population
order by 4 desc


-- Countries with highest death count
select location, max(Cast((total_deaths) AS int)) as HighestDeathCount
from  [dbo].[covid-deaths] 
where continent is not null
group by location
order by 2 desc



-- Now, by continent 
-- Continents with highest death counts:
select location, max(Cast((total_deaths) AS int)) as HighestDeathCount
from  [dbo].[covid-deaths] 
where continent is null
group by location
order by 2 desc


-- Inital method (for convinience and later visualization use
select continent, max(Cast((total_deaths) AS int)) as HighestDeathCount
from  [dbo].[covid-deaths] 
where continent is not null
group by continent
order by 2 desc


-- Global numbers
select date, sum(new_cases) AS totalnewcases,sum(cast(new_deaths as int)) AS totalnewdeaths,
case WHEN sum(new_cases) = 0 THEN NULL
        ELSE
		(sum(cast(new_deaths as int))/sum(new_cases))* 100 
		end AS '%deaths_from_cases'
from  [dbo].[covid-deaths] 
where continent is not null
group by date
order by 1


-- Following is the numbers overall
select sum(new_cases) AS totalnewcases,sum(cast(new_deaths as int)) AS totalnewdeaths,
case WHEN sum(new_cases) = 0 THEN NULL
        ELSE
		(sum(cast(new_deaths as int))/sum(new_cases))* 100 
		end AS '%deaths_from_cases'
from  [dbo].[covid-deaths] 
where continent is not null




-- --------- Now  we're working with the vaccination table ----------

--Looking at total population vs vaccination

select distinct d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as rollingpeoplevaccinated
from  [dbo].[covid-deaths] d
join [dbo].[covid-vaccinations] v
on v.location = d.location
and d.date = v.date
where d.continent is not null
order by 2,3

--Using cte for percentage: (using select distinct because there are duplicates in the vaccination table

-- the query:
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) as 
(
select distinct d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over (partition by d.location order by d.date) as rollingpeoplevaccinated
from  [dbo].[covid-deaths] d
inner join [dbo].[covid-vaccinations] v
on v.location = d.location
and d.date = v.date
where d.continent is not null
)
select *,(rollingpeoplevaccinated/population)*100 from popvsvac
order by 2,3




-- Same, but using temp table
drop table if exists #percentpopulationvaccinated    
create table #percentpopulationvaccinated    
( 
continent nvarchar(255), location nvarchar (255), date datetime, population numeric, new_vaccinations numeric, 
rollingpeoplevaccinated bigint
)

insert into  #percentpopulationvaccinated
select distinct d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over (partition by d.location order by d.date) as rollingpeoplevaccinated
from  [dbo].[covid-deaths] d
inner join [dbo].[covid-vaccinations] v
on v.location = d.location
and d.date = v.date
where d.continent is not null

select *,(rollingpeoplevaccinated/population)*100 from #percentpopulationvaccinated
order by 2,3

-- Again but creating view to store data for later visualizations    
create view percentpopulationvaccinated as
select distinct d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over (partition by d.location order by d.date) as rollingpeoplevaccinated
from  [dbo].[covid-deaths] d
inner join [dbo].[covid-vaccinations] v
on v.location = d.location
and d.date = v.date
where d.continent is not null

select *,(rollingpeoplevaccinated/population)*100 from percentpopulationvaccinated
order by 2,3


------------------------------ Queries for Tableau------------------------------------
--1 
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 asDaethPercentage
From [dbo].[covid-deaths]
where continent is not null 
order by 1,2
 
 --2 
 select location, sum(cast(new_deaths as int)) as TotalDeathCount
 from [dbo].[covid-deaths] 
 where continent is null
 and location not in ('World', 'European Union', 'International', 'Low income', 'High income', 'Lower middle income',
 'Upper middle income')
 group by location
 order by totaldeathcount desc

 
-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [dbo].[covid-deaths]
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [dbo].[covid-deaths]
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc










