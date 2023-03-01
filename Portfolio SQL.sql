--Covid 19 Data Exploration
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select *From Covid_Deaths;
-- Select Data that we are going to be starting with
SELECT location,dates,total_cases,new_cases,total_deaths,population FROM covid_deaths;
SELECT location,dates,total_cases,new_cases,total_deaths,population FROM covid_deaths Where continent is not null;
-- Total Cases vs Total Deaths
SELECT total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Rate FROM covid_deaths;
SELECT location,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Rate FROM covid_deaths order by 1,2;
SELECT location,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Rate FROM covid_deaths where location = 'India' order by 1,2;

-- Total Cases vs Total Deaths
--Shows likelihod of dying in your country if you are infected with covid-19
SELECT location,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Rate FROM covid_deaths where location like '%Indi%' order by 1,2;

--Looking at Total cases vs Population
--Shows what percentage of people got covid
SELECT location,dates,total_cases,Population,(total_cases/Population)*100 as Infected_Rate FROM covid_deaths where location = 'India' order by 1,2;
SELECT location,dates,total_cases,Population,(total_cases/Population)*100 as Infected_Rate FROM covid_deaths order by 1,2;

--Looking at countries with high infection rates compared to population
SELECT location,  max(total_cases) as High_Infection_Rate, Population, max((total_cases/Population)*100) as Infected_Rate 
FROM covid_deaths group by  location, Population order by Infected_Rate desc;

--Showing countries with Highest Death Count Per Population
SELECT location,  max(total_deaths) as Total_Death_Count FROM covid_deaths WHERE continent is not null
group by location order by Total_Death_Count desc;

SELECT location,  max(cast(total_deaths as int)) as Total_Death_Count FROM covid_deaths WHERE continent is not null
group by location order by Total_Death_Count desc;

-- Let's Break things down by continent(We use location with continent is null because in this colimns the continent data is stored)
SELECT location,  max(cast(total_deaths as int)) as Total_Death_Count FROM covid_deaths WHERE continent is null
group by location order by Total_Death_Count desc;

--Showing continent with highest death count(It is showing the highest deaths of country in continent)
--(SELECT continent,  max(cast(total_deaths as int)) as Total_Death_Count FROM covid_deaths WHERE continent is not null group by continent order by Total_Death_Count desc;)

SELECT continent,  max(total_deaths) as Total_Death_Count FROM covid_deaths WHERE continent is not null
group by continent order by Total_Death_Count desc;
-- It won't show the death rate by continent beacause of dataset arrangement

--GLOBAL NUMBERS
Select dates, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM covid_deaths WHERE continent is not null
Group by dates order by dates;

Select dates, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM covid_deaths WHERE continent is not null
Group by dates order by deathpercentage desc;

-- Total Global Cases
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
FROM covid_deaths WHERE continent is not null
order by 1,2;

-- Covid_Vaccinations
SELECT * FROM COVID_DEATHS CD JOIN COVID_VACCINATIONS CV on CD.location = CV.location AND CD.dates = CV.dates;

--Looking at Total Population vs Vaccinations
SELECT cd.continent,cd.location, CD.dates, CD.population, cv.new_vaccinations FROM COVID_DEATHS CD JOIN COVID_VACCINATIONS CV
on CD.location = CV.location AND CD.dates = CV.dates;

SELECT cd.continent,cd.location, CD.dates, CD.population, cv.new_vaccinations FROM COVID_DEATHS CD JOIN COVID_VACCINATIONS CV
on CD.location = CV.location AND CD.dates = CV.dates where CD.continent is not null;

SELECT cd.continent,cd.location, CD.dates, CD.population, cv.new_vaccinations FROM COVID_DEATHS CD JOIN COVID_VACCINATIONS CV
on CD.location = CV.location AND CD.dates = CV.dates where CD.continent is not null order by 1,2,3 ;

SELECT cd.continent,cd.location, CD.dates, CD.population, cv.new_vaccinations,SUM(cv.new_vaccinations) OVER (PARTITION BY CD.location)
FROM COVID_DEATHS CD JOIN COVID_VACCINATIONS CV on CD.location = CV.location AND CD.dates = CV.dates
where CD.continent is not null order by 1,2,3 ;

SELECT cd.continent,cd.location, CD.dates, CD.population, cv.new_vaccinations,SUM(cv.new_vaccinations) OVER (PARTITION BY CD.location order by CD.location,CD.dates) as Total_Vaccinations
FROM COVID_DEATHS CD JOIN COVID_VACCINATIONS CV on CD.location = CV.location AND CD.dates = CV.dates
where CD.continent is not null order by 1,2,3 ;

SELECT cd.continent,cd.location, CD.dates, CD.population, cv.new_vaccinations,SUM(cv.new_vaccinations) OVER (PARTITION BY CD.location order by CD.location,CD.dates) as Total_Vaccinations
FROM COVID_DEATHS CD JOIN COVID_VACCINATIONS CV on CD.location = CV.location AND CD.dates = CV.dates
where CD.continent is not null order by 1,2,3 ;

-- USE CTE(COMMON TABLE EXTENSION)
WITH PopVsVac (continent,location,dates,population,new_vaccinations,Total_Vaccinations)
as
(
SELECT cd.continent,cd.location, CD.dates, CD.population, cv.new_vaccinations,SUM(cv.new_vaccinations) OVER (PARTITION BY CD.location order by CD.location,CD.dates) as Total_Vaccinations FROM COVID_DEATHS CD JOIN COVID_VACCINATIONS CV on CD.location = CV.location AND CD.dates = CV.dates
where CD.continent is not NULL
)
SELECT continent,location,dates,population,new_vaccinations,total_vaccinations,(total_vaccinations/population)*100 FROM PopVsVac;

--Temporary Table
DROP TABLE PercentPeopleVaccinated IF EXISTS;
CREATE TABLE PercentPeopleVaccinated
(
continent varchar2(255),
location varchar2(255),
dates date,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)

INSERT INTO PercentPeopleVaccinated
SELECT cd.continent,cd.location, CD.dates, CD.population, cv.new_vaccinations,SUM(cv.new_vaccinations) OVER (PARTITION BY CD.location order by CD.location,CD.dates) as Total_Vaccinations FROM COVID_DEATHS CD JOIN COVID_VACCINATIONS CV on CD.location = CV.location AND CD.dates = CV.dates
where CD.continent is not NULL;
SELECT * FROM PercentPeopleVaccinated;
SELECT continent,location,dates,population,new_vaccinations,total_vaccinations,(total_vaccinations/population)*100 FROM PercentPeopleVaccinated;

--Creating View to store visualizations for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT cd.continent,cd.location, CD.dates, CD.population, cv.new_vaccinations,SUM(cv.new_vaccinations) OVER (PARTITION BY CD.location order by CD.location,CD.dates) as Total_Vaccinations FROM COVID_DEATHS CD JOIN COVID_VACCINATIONS CV on CD.location = CV.location AND CD.dates = CV.dates
where CD.continent is not NULL;

-- Looking at the View
Select * from PercentPopulationVaccinated; 
SELECT continent,location,dates,population,new_vaccinations,total_vaccinations,(total_vaccinations/population)*100 FROM PercentPopulationVaccinated;
SELECT continent,location,dates,population,new_vaccinations,total_vaccinations,(total_vaccinations/population)*100 FROM PercentPopulationVaccinated where location = 'India';

-- For BI Visualizations
--1
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
FROM covid_deaths WHERE continent is not null order by 1,2,3;

--2
SELECT location,sum(new_deaths)as TotalDeathCount FROM covid_deaths Where continent is null 
and location not in ('World', 'High income','Upper middle income','Lower middle income','European Union', 'Low income','International') Group by location
order by TotalDeathCount desc;

--3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_Deaths Group by Location, Population order by PercentPopulationInfected desc;

--4
Select Location, Population,dates, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_Deaths Group by Location, Population, dates order by PercentPopulationInfected desc;
