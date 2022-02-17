--Covid-19 Data Exploration
--Project was done during the Data Analysis Project Course From AlexTheAnalyst


SELECT * 
from dbo.CovidDeaths
where continent is not null
order by 3, 4

-- Selecting Data to be Processed and analized further

SELECT location, date, total_cases, new_cases, total_deaths, population 
from dbo.CovidDeaths
where continent is not null
order by 1, 2


-- Total deaths per total cases to show the likelihood of dying from getting infected
-- Sorted from the highest death percentage


SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	round((total_deaths/total_cases)*100, 2) as death_percentage
from dbo.CovidDeaths
where continent is not null
and location like 'indonesia'
order by 5 desc



-- Total cases per population to show infected population percentage

SELECT location, date, total_cases, population, (total_cases/population)*100 as infected_percent
from dbo.CovidDeaths
where continent is not null
order by 1, 2



-- Countries with Highest Infection Rate compared to Population

SELECT 
	location, 
	population, 
	max(total_cases) as highest_infection_count, 
	max((total_cases/population)*100) as population_infected_percent
from dbo.CovidDeaths
where continent is not null
group by location, population
order by population_infected_percent desc


-- Countries with Highest Death Count

SELECT 
	location, 
	max(cast(total_deaths as int)) as total_death_count
from dbo.CovidDeaths
where continent is not null
group by location
order by 2 desc


-- Breaking down by continents

-- Continent with highest death

Select 
	continent, 
	max(cast(total_deaths as int)) as total_death_count
from dbo.CovidDeaths
where continent is not null
group by continent
order by 2 desc


-- Global Numbers

select 
	sum(new_cases) as total_cases, 
	sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from dbo.CovidDeaths
where continent is not null


-- Percentage of Pupolation that has been vaccinated at least once

select 
	dea.continent, dea.location, 
	dea.date, dea.population, 
	vax.new_vaccinations,
	sum(cast(vax.new_vaccinations as bigint)) 
	over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaxxed
from dbo.CovidDeaths dea
join dbo.CovidVaccines vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform calculations on Partition by in previous query

with vaxxed_percentage as
( 
select 
	dea.continent, dea.location, 
	dea.date, dea.population, 
	vax.new_vaccinations,
	sum(cast(vax.new_vaccinations as bigint)) 
	over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaxxed
from dbo.CovidDeaths dea
join dbo.CovidVaccines vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3
)

select *, (rolling_people_vaxxed/population)*100 as vaxxed_per_pop
from vaxxed_percentage


-- Creating View for visualizations

create view percent_vaccinated_population as
select 
	dea.continent, dea.location, 
	dea.date, dea.population, 
	vax.new_vaccinations,
	sum(cast(vax.new_vaccinations as bigint)) 
	over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaxxed
from dbo.CovidDeaths dea
join dbo.CovidVaccines vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
