-- 1. Showing Total Death Percentage (deaths / cases)
SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths,
    (SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT))) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- 2. Showing Total Death Count by location(not by countries, rather like continent)
-- Because the dataset has some calculation errors in total_deaths, we add new_deaths to get the total deaths count
-- Continent is formed based on geographical location, we see the data by location where continent is NULL
SELECT location, SUM(new_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE 
    continent IS NULL AND
    location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- 3. Extract the max of total_deaths to get the total deaths count because it is cumulative
-- Continent is formed based on geographical location, we see the data by location where continent is NULL
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE 
    continent IS NULL AND
    location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- 4. Showing Percent population infected rate by location in descending order
SELECT
    location,
    population, 
    date,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC