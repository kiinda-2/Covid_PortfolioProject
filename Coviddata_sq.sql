SELECT * FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


SELECT * FROM CovidPortfolioProject..CovidVaccinations
ORDER BY 3,4;



SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths
order by 1,2;



--Total Deaths vs Total Cases (Likelihood of dying if you contract covid)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deaths_In_Percentage
FROM  CovidPortfolioProject..CovidDeaths
WHERE Location = 'Kenya'
order by 1,2;



--Total Cases vs Population (Percentage of population infected)
SELECT Location, date,population, total_cases, (total_cases/population)*100 AS percentageOfPopulationInfected
FROM  CovidPortfolioProject..CovidDeaths
WHERE Location = 'Kenya'
order by 1,2;



--Countries with highest infection rates compared to the population
SELECT Location, population, MAX(total_cases) as highestInfection,   MAX((total_cases/population))*100 AS percentage_Of_Population_Infected
FROM  CovidPortfolioProject..CovidDeaths
GROUP BY Location, population
order by percentage_Of_Population_Infected DESC



--Continent with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as Total_Deaths
FROM  CovidPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by Total_Deaths DESC



--Highest death count by continent
SELECT continent, MAX(cast(total_deaths as int)) as Total_DeathCount 
FROM  CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
order by Total_DeathCount DESC



--Countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as Total_DeathCount 
FROM  CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
order by Total_DeathCount DESC



--Global Numbers [date]
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS Deaths_In_Percentage
FROM  CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2




--USE CTE
WITH PopvsVaccs(Continent, Location, Date, Population, new_vaccinations, Total_Vaccinated)
as 
(

--Total Population vs Vaccinations
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
SUM(CAST(vaccs.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location order by deaths.location, deaths.date) AS Total_Vaccinated --Sum new_vacss in each location and order by...
FROM CovidPortfolioProject..CovidDeaths deaths JOIN
CovidPortfolioProject..CovidVaccinations vaccs
	ON deaths.location = vaccs.location 
	AND deaths.date = vaccs.date
where deaths.continent IS NOT NULL and deaths.location = 'Kenya'
--order by 2, 3
)

SELECT *, (Total_Vaccinated/Population) * 100 as Avg_Vaccinated FROM PopvsVaccs




--TEMP TABLE
DROP TABLE IF EXISTS Percentage_Vaccinated

CREATE TABLE Percentage_Vaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime
, Population numeric, new_vaccinations numeric, Total_Vaccinated numeric
)

INSERT INTO Percentage_Vaccinated
--Total Population vs Vaccinations
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
SUM(CAST(vaccs.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location order by deaths.location, deaths.date) AS Total_Vaccinated --Sum new_vacss in each location and order by...
FROM CovidPortfolioProject..CovidDeaths deaths JOIN
CovidPortfolioProject..CovidVaccinations vaccs
	ON deaths.location = vaccs.location 
	AND deaths.date = vaccs.date
where deaths.continent IS NOT NULL and deaths.location = 'Kenya'
--order by 2, 3

SELECT *, (Total_Vaccinated/Population) * 100 as Avg_Vaccinated FROM Percentage_Vaccinated


--Create view to store data for visualization
create view Percent_Vaccinated as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
SUM(CAST(vaccs.new_vaccinations as bigint)) 
OVER (PARTITION BY deaths.location order by deaths.location, deaths.date) AS Total_Vaccinated --Sum new_vacss in each location and order by...
FROM CovidPortfolioProject..CovidDeaths deaths JOIN
CovidPortfolioProject..CovidVaccinations vaccs
	ON deaths.location = vaccs.location 
	AND deaths.date = vaccs.date
where deaths.continent IS NOT NULL
--order by 2,3

SELECT * FROM Percent_Vaccinated