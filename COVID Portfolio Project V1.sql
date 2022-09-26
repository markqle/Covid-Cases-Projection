
SELECT *
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
ORDER BY 3,4
--SELECT *
--FROM PortfolioProject..Covid_Vaccinations
--ORDER BY 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_Deaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths 
-- Show likelihood of dying if you contract the covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 As ContractedPercentage
FROM PortfolioProject..Covid_Deaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compasred to Population
SELECT location,population, Max (total_cases) as HighestInfectionCountry, Max((total_cases/population))*100 As PercentPopulationInfected
FROM PortfolioProject..Covid_Deaths
--WHERE location like '%states%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

-- Showing country with highest death count per population
SELECT location, MAX (cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Covid_Deaths
--WHERE location like '%states%'
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Let's break things down by continent


-- showing continent with the highest death count per population
SELECT continent, MAX (cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Covid_Deaths
--WHERE location like '%states%'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC




-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/ SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..Covid_Deaths
--WHERE location like '%states%'
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as

(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3)
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3)
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3)

Select * 
from PercentPopulationVaccinated