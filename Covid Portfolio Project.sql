/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select *
from coviddeaths
where continent is not null
order by 3,4;


-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
Where location like 'portugal' and continent is not null
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, population, total_cases, (total_cases/population)*100 as percente_population_infected
from coviddeaths
where continent is not null 
-- and location like 'portugal'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percente_population_infected
from coviddeaths
where continent is not null 
-- and location like 'portugal'
group by location, population
order by percente_population_infected desc;


-- Countries with Highest Death Count per Population

select location, max(cast(total_deaths as signed)) as total_death_count
from coviddeaths
where continent is not null
-- and location like 'portugal'
group by location
order by total_death_count desc;


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

select continent, max(cast(total_deaths as signed)) as total_death_count
from coviddeaths
where continent is not null
-- and location like 'portugal'
group by continent
order by total_death_count desc;


-- Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths, (sum(cast(new_deaths as signed))/sum(new_cases))*100 as death_percentage
from coviddeaths
Where continent is not null
-- and location like 'portugal'
group by date
order by 1,2;

select sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths, (sum(cast(new_deaths as signed))/sum(new_cases))*100 as death_percentage
from coviddeaths
Where continent is not null
-- and location like 'portugal'
order by 1,2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
sum(cast(dea.new_vaccinations as signed)) over (partition by location order by dea.location, dea.date) as rolling_people_vaccinated
-- ,(rolling_people_vaccinated/population)*100
FROM coviddeaths as dea
join covidvaccinations as vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(dea.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(dea.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(dea.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From CovidDeaths as dea
Join CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;




