--------DATA EXPLORATION USING SQL---------


--select * from  [dbo].[covid-deaths] order by 3,4

--select * from  [dbo].[covid-vaccinations] order by 3,4

SELECT location, date, total_cases_per_million, new_cases, total_deaths, population
FROM [dbo].[covid-deaths]
ORDER BY 1, 2;

--Total deaths compared to total cases
SELECT location, date, total_cases, total_deaths, 
    CASE
        WHEN TRY_CAST(total_cases AS float) = 0 OR TRY_CAST(total_cases AS float) IS NULL THEN NULL
        ELSE CAST(total_deaths AS float) / CAST(total_cases AS float) * 100
    END AS 'death percentage'
FROM [dbo].[covid-deaths]
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Total cases vs population
SELECT location, date, total_cases, population, 
    CASE
        WHEN TRY_CAST(population AS float) = 0 OR TRY_CAST(total_cases AS float) IS NULL THEN NULL
        ELSE CAST(total_cases AS float) / CAST(population AS float) * 100
    END AS 'cases percentage'
FROM [dbo].[covid-deaths]
--WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
    CASE
        WHEN TRY_CAST(population AS float) = 0 OR TRY_CAST(MAX(total_cases) AS float) IS NULL THEN NULL
        ELSE CAST(MAX(total_cases) AS float) / CAST(population AS float) * 100
    END AS 'Percentage of Pop Infected'
FROM [dbo].[covid-deaths]
GROUP BY location, population
ORDER BY 4 DESC;

-- Countries with the highest death count
SELECT location, MAX(CAST((total_deaths) AS INT)) AS HighestDeathCount
FROM [dbo].[covid-deaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- Now, by continent
-- Continents with the highest death counts:
SELECT location, MAX(CAST((total_deaths) AS INT)) AS HighestDeathCount
FROM [dbo].[covid-deaths]
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC;

-- Initial method (for convenience and later visualization use)
SELECT continent, MAX(CAST((total_deaths) AS INT)) AS HighestDeathCount
FROM [dbo].[covid-deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

-- Global numbers
SELECT date, SUM(new_cases) AS totalnewcases, SUM(CAST(new_deaths AS INT)) AS totalnewdeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100
    END AS '%deaths_from_cases'
FROM [dbo].[covid-deaths]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

-- Following are the numbers overall
SELECT SUM(new_cases) AS totalnewcases, SUM(CAST(new_deaths AS INT)) AS totalnewdeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100
    END AS '%deaths_from_cases'
FROM [dbo].[covid-deaths]
WHERE continent IS NOT NULL;

-- --------- Now, we're working with the vaccination table ----------

-- Looking at total population vs vaccination
SELECT DISTINCT d.continent, d.location, d.date, d.population, v.new_vaccinations,
    SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rollingpeoplevaccinated
FROM [dbo].[covid-deaths] d
JOIN [dbo].[covid-vaccinations] v ON v.location = d.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTE for percentage: (using SELECT DISTINCT because there are duplicates in the vaccination table)

-- the query:
WITH popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) AS
(
    SELECT DISTINCT d.continent, d.location, d.date, d.population, v.new_vaccinations,
        SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.date) AS rollingpeoplevaccinated
    FROM [dbo].[covid-deaths] d
    INNER JOIN [dbo].[covid-vaccinations] v ON v.location = d.location AND d.date = v.date
    WHERE d.continent IS NOT NULL
)
SELECT *, (rollingpeoplevaccinated / population) * 100 FROM popvsvac ORDER BY 2, 3;

-- Same but using a temp table
DROP TABLE IF EXISTS #percentpopulationvaccinated;
CREATE TABLE #percentpopulationvaccinated
(
    continent NVARCHAR(255), location NVARCHAR(255), date DATETIME, population NUMERIC, new_vaccinations NUMERIC, 
    rollingpeoplevaccinated BIGINT
);

INSERT INTO #percentpopulationvaccinated
SELECT DISTINCT d.continent, d.location, d.date, d.population, v.new_vaccinations,
    SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.date) AS rollingpeoplevaccinated
FROM [dbo].[covid-deaths] d
INNER JOIN [dbo].[covid-vaccinations] v ON v.location = d.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT *, (rollingpeoplevaccinated / population) * 100 FROM #percentpopulationvaccinated ORDER BY 2, 3;

-- Again but creating a view to store data for later visualizations
CREATE VIEW percentpopulationvaccinated AS
SELECT DISTINCT d.continent, d.location, d.date, d.population, v.new_vaccinations,
    SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.date) AS rollingpeoplevaccinated
FROM [dbo].[covid-deaths] d
INNER JOIN [dbo].[covid-vaccinations] v ON v.location = d.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT *, (rollingpeoplevaccinated / population) * 100 FROM percentpopulationvaccinated ORDER BY 2, 3;










