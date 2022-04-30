SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you get covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Kong%' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at the Total cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Kong%' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY CasePercentage desc

--Looking at Countries with Highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--Show continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global numbers - per day
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Global numbers - total
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Look at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Use CTE
With PopvsVac (Continent, location, date, population,new_vaccinations,RollingPeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)
INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated


--Creating View to store data for later visualization
CREATE VIEW PercentagePopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


