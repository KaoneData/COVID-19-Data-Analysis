-- 1. Convert blanks/empty spaces to NULL so they don't break the ALTER command
UPDATE ProjectPortfolio.coviddeaths 
SET total_deaths = NULLIF(total_deaths, ''),
    total_cases = NULLIF(total_cases, ''),
    new_cases = NULLIF(new_cases, ''),
    continent = NULLIF(continent,'');
    
-- 1. Clean the vaccinations column
UPDATE ProjectPortfolio.covidvaccinations 
SET new_vaccinations = NULLIF(new_vaccinations, '');

-- 2. Change to BIGINT because vaccination numbers often exceed the 2-billion limit of standard INT
ALTER TABLE ProjectPortfolio.covidvaccinations 
MODIFY COLUMN new_vaccinations BIGINT;


-- 2. Permanently change columns to INT (use BIGINT for large population/cases data)
ALTER TABLE ProjectPortfolio.coviddeaths 
MODIFY COLUMN total_deaths INT,
MODIFY COLUMN total_cases INT,
MODIFY COLUMN new_cases INT,
MODIFY COLUMN population INT,
MODIFY COLUMN date date ;

-- INITIAL DATA EXPLORATION

-- Preview cleaned deaths data (excluding aggregate records where continent is null)
Select * 
FROM ProjectPortfolio.coviddeaths
Where continent is not null
order by 3,4;

-- Select * 
-- FROM ProjectPortfolio.covidvaccinations
-- order by 3,4;

-- Select key metrics for analysis
Select location ,date,total_cases,new_cases,total_deaths,population
FROM ProjectPortfolio.coviddeaths
Where continent is not null
order by 1,2;

-- DEATH RATE ANALYSIS

-- Calculate death percentage (likelihood of dying if infected with COVID-19)
-- Example filtered for South Africa

Select location ,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM ProjectPortfolio.coviddeaths
Where location like '%South Africa%'
and continent is not null
order by 1,2;

-- INFECTION RATE ANALYSIS

-- Calculate percentage of population infected with COVID-19
Select location ,date,population,total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM ProjectPortfolio.coviddeaths
-- Where location like '%South Africa%'
order by 1,2;

-- Identify countries with highest infection rates relative to population

Select location ,population,date,MAX(total_cases) AS HighestInfectionCout,Max((total_cases/population))*100 AS PercentPopulationInfected
FROM ProjectPortfolio.coviddeaths
-- Where location like '%South Africa%'
Group by location,population,date
Order by PercentPopulationInfected Desc
;

-- DEATH COUNT ANALYSIS

-- Show countries with highest death count per population
Select location , Max(total_deaths ) as TotalDeathCount
FROM ProjectPortfolio.coviddeaths
-- Where location like '%South Africa%'
Where continent is not null
Group by location 
Order by TotalDeathCount Desc
;


-- Break down death counts by continent
Select continent, Max(total_deaths ) as TotalDeathCount
FROM ProjectPortfolio.coviddeaths
-- Where location like '%South Africa%'
Where continent is not null
Group by continent
Order by TotalDeathCount Desc
;

-- GLOBAL STATISTICS

-- Calculate global COVID-19 numbers (total cases, deaths, and death percentage)
Select SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM ProjectPortfolio.coviddeaths
-- Where location like '%states%'
WHERE continent is not null
-- Group by date
order by 1,2;

-- VACCINATION ANALYSIS

-- Join deaths and vaccinations tables to analyze vaccination progress
-- Calculate rolling sum of vaccinations by location
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) over (Partition by  dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
    -- ,(RollingPeopleVaccinated/population)*100
    
from ProjectPortfolio.coviddeaths dea
JOIN ProjectPortfolio.covidvaccinations vac
	ON dea.location =vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3; 

-- USING CTE TO CALCULATE VACCINATION PERCENTAGE

-- Create CTE to calculate percentage of population vaccinated over time
with PopVsVac (Continent, location, date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) over (Partition by  dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
    -- ,(RollingPeopleVaccinated/population)*100
    
from ProjectPortfolio.coviddeaths dea
JOIN ProjectPortfolio.covidvaccinations vac
	ON dea.location =vac.location
    and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100 
From PopVsVac;

-- USING TEMP TABLE TO CALCULATE VACCINATION PERCENTAGE

-- Drop table if it already exists to avoid errors
Drop table if exists PercentPopulationVaccinated;

-- Create temporary table to store vaccination data
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    Continent VARCHAR(255),
    location VARCHAR(255),
    date DATETIME,
    Population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Insert vaccination data with rolling sum calculations
Insert into PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) over (Partition by  dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
    -- ,(RollingPeopleVaccinated/population)*100
    
from ProjectPortfolio.coviddeaths dea
JOIN ProjectPortfolio.covidvaccinations vac
	ON dea.location =vac.location
    and dea.date = vac.date;
-- where dea.continent is not null
-- order by 2,3

-- Query the temporary table to calculate vaccination percentage
select *,(RollingPeopleVaccinated/Population)*100 
From PercentPopulationVaccinated;

-- CREATE VIEW FOR DATA VISUALIZATION

-- Create view to store vaccination data for later use in visualization tools (Tableau, Power BI, etc.)
create view ViewPercentPopulationVaccinated as
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) over (Partition by  dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
    -- ,(RollingPeopleVaccinated/population)*100
    
from ProjectPortfolio.coviddeaths dea
JOIN ProjectPortfolio.covidvaccinations vac
	ON dea.location =vac.location
    and dea.date = vac.date
where dea.continent is not null;
-- order by 2,3

-- Query the view to verify data
select *
from ViewPercentPopulationVaccinated

-- END OF SCRIPT







