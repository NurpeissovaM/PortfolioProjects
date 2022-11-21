SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [owid-covid-data]
ORDER BY 1,2 

-- looking at total cases vs total deaths 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
FROM [owid-covid-data]
WHERE location like '%Kazakhstan%'
ORDER BY 1,2

-- looking at total cases vs population (what percentage of population got covid)
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM [owid-covid-data]
ORDER BY 1,2

--looking at countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) as highestInfectionCount , 
MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM [owid-covid-data]
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- showing countries with the highest death count per population
SELECT location,  MAX(CAST(total_deaths as int)) as TotalDeathCount 
FROM [owid-covid-data]
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- showing continents with the highest death count per population 
SELECT continent,  MAX(CAST(total_deaths as int)) as TotalDeathCount 
FROM [owid-covid-data]
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- looking at global numbers
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int) )  as total_deaths, 
       sum(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentage 
FROM [owid-covid-data]
WHERE continent is NOT NULL
ORDER BY 1,2

--looking at total population vs vaccinations
WITH popvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated) AS
    (Select continent, location, date, population, new_vaccinations , SUM( new_vaccinations) OVER (PARTITION BY location order BY location, date) as RollingPeopleVaccinated
    FROM [owid-covid-data] 
    WHERE continent is NOT NULL)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM popvsVac 

--creating a temp table
DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
    (Continent NVARCHAR(255),
    location NVARCHAR (255),
    date DATETIME,
    population NUMERIC, 
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC)

insert into #PercentPopulationVaccinated 
    Select continent, location, date, population, new_vaccinations , 
        SUM(new_vaccinations) OVER (PARTITION BY location order BY location, date) as RollingPeopleVaccinated
    FROM [owid-covid-data] 

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated

--creating view for visualizations
CREATE  VIEW PercentPopulationVaccinated AS 
    Select continent, location, date, population, new_vaccinations, 
        SUM( new_vaccinations) OVER (PARTITION BY location order BY location, date) as RollingPeopleVaccinated
    FROM [owid-covid-data] 
    WHERE continent is NOT NULL

select * FROM PercentPopulationVaccinated