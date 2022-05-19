--DARABASE NAME PortfolioProjects
USE PortfolioProjects
SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4;

--SELECT Data that we are going ti be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


--Liking at Total cases vs Population
--Shows what Percentage of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%Bangladesh%' AND continent IS NOT NULL
ORDER BY 1, 2;



--Looking at Total Cases vs Total Deaths
--Shows likelihood of population got Covid
SELECT Location, date,population , total_cases, (total_cases / population) * 100 AS TotalPercentageGotCovid
FROM CovidDeaths
WHERE location LIKE '%Bangladesh%'
ORDER BY 1, 2;

--Looking at Countries with Highest Infection Rate compared to population
--Shows likelihood of population got Covid
SELECT Location,population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases / population)) * 100 AS TotalPercentageGotCovid
FROM CovidDeaths
GROUP BY Location,population
ORDER BY TotalPercentageGotCovid DESC;

--Showing Countries with Highest death count per population

SELECT Location, MAX(CONVERT( INT, total_deaths)) AS HighestTotalDeath
FROM CovidDeaths
WHERE  continent IS NOT NULL
GROUP BY Location
ORDER BY HighestTotalDeath DESC;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CONVERT( INT, total_deaths)) AS HighestTotalDeath
FROM CovidDeaths
WHERE  continent IS NOT NULL
GROUP BY continent
ORDER BY HighestTotalDeath DESC;

-- GLOBAL NUMBERS
SELECT SUM(new_cases) total_cases,SUM(CONVERT(INT,new_deaths)) total_deaths,SUM(CONVERT(INT, new_deaths))/SUM(New_Cases)*100 DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT cde.continent,cde.location,cde.date, SUM(CONVERT(BIGINT,cde.population)) TotalPopulationPerCountry, SUM(CONVERT(BIGINT, cva.new_vaccinations)) TotalNewVaccinationsPerCountry
,SUM(CONVERT(int,cva.new_vaccinations)) OVER (Partition by cde.Location Order by cde.location, cde.Date) as RollingPeopleVaccinated
FROM CovidDeaths cde JOIN CovidVaccinations cva
ON cde.location = cva.location AND cde.date = cva.date
WHERE cde.continent IS NOT NULL
GROUP BY cde.location,cde.continent, cde.date,cva.new_vaccinations
ORDER BY 1 DESC;


---- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac  (continent,location,date,TotalPopulationPerCountry,TotalNewVaccinationsPerCountry,RollingPeopleVaccinated)
AS
(SELECT cde.continent,cde.location,cde.date, SUM(CONVERT(BIGINT,cde.population)) TotalPopulationPerCountry, SUM(CONVERT(BIGINT, cva.new_vaccinations)) TotalNewVaccinationsPerCountry
,SUM(CONVERT(int,cva.new_vaccinations)) OVER (Partition by cde.Location Order by cde.location, cde.Date) as RollingPeopleVaccinated
FROM CovidDeaths cde JOIN CovidVaccinations cva
ON cde.location = cva.location AND cde.date = cva.date
WHERE cde.continent IS NOT NULL
GROUP BY cde.location,cde.continent, cde.date,cva.new_vaccinations
)

SELECT *, (RollingPeopleVaccinated / TotalPopulationPerCountry)*100 PercentagePerCountry
FROM PopvsVac

