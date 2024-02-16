select *
from portfoilio_project..CovidDeaths

select *
from portfoilio_project..CovidVaccinations

select location, date, total_cases, new_cases,total_deaths, population
from portfoilio_project..CovidDeaths
order by 1,2

-- We're looking at total cases VS total deaths in India.

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from portfoilio_project..CovidDeaths
where location like '%india%'
order by 1,2

-- Now we're looking at total cases vs population in India.

select location, date, total_cases,population, (total_cases/population)*100 as affected_percentage
from portfoilio_project..CovidDeaths
where location like '%india%'
order by 1,2

--  Now we're looking at countries with highest infection rates compared to population.

select location, population , max(total_cases) as highest_infectioncount , max((total_cases/population))*100 as affected_percentage
from portfoilio_project..CovidDeaths
-- where location like '%india%'
group by location, population
order by affected_percentage desc

-- Countries with highest no. of deaths per their population .

select location, population , max(cast(total_deaths as int)) as TotalDEAD
from portfoilio_project..CovidDeaths
where continent is not null
group by location, population
order by TotalDEAD desc

-- Now Data is grouped by continenets and the Continenets with highest death counts.

select continent, max(cast(total_deaths as int)) as TotalDEAD
from portfoilio_project..CovidDeaths
where continent is not null
group by continent
order by TotalDEAD desc

-- Change in global numbers at each day.

select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Deat_percentage
from portfoilio_project..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Global numbers

select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Deat_percentage
from portfoilio_project..CovidDeaths
where continent is not null
order by 1,2

-- Total population VS total vaccinations

select da.continent, da.location, da.date, da.population, vacc.new_vaccinations,
      SUM(CONVERT(int,vacc.new_vaccinations)) over (partition by da.location order by da.location, da.date) as Total_vaccinated
from portfoilio_project..CovidDeaths as da
join portfoilio_project..CovidVaccinations as vacc
on da.location = vacc.location 
and da.date = vacc.date
where da.continent is not null 
and da.location like '%india%'
order by 2,3

-- Now we look at how many people(%) are vaccinated compared to the popelation using CTE.

with VaccPercentage (continent,location,date, population, new_vaccinations,Total_vaccinated)
as
(
select da.continent, da.location, da.date, da.population, vacc.new_vaccinations,
      SUM(CONVERT(int,vacc.new_vaccinations)) over (partition by da.location order by da.location, da.date) as Total_vaccinated
from portfoilio_project..CovidDeaths as da
join portfoilio_project..CovidVaccinations as vacc
on da.location = vacc.location 
and da.date = vacc.date
where da.continent is not null 
and da.location like '%india%'
-- order by 2,3 -- cannot use order by in a CTE.
)
select *,(Total_vaccinated/population)*100 as vacc_percent
from VaccPercentage

-- Doing the same queery but now with the help of a temp table.

drop table if exists #vaccpercentage
create table #vaccpercentage
(
continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric, 
new_vaccinations numeric,
Total_vaccinated numeric
)

Insert into #vaccpercentage
select da.continent, da.location, da.date, da.population, vacc.new_vaccinations,
      SUM(CONVERT(int,vacc.new_vaccinations)) over (partition by da.location order by da.location, da.date) as Total_vaccinated
from portfoilio_project..CovidDeaths as da
join portfoilio_project..CovidVaccinations as vacc
on da.location = vacc.location 
and da.date = vacc.date
where da.continent is not null 
and da.location like '%india%'
order by 2,3 

select *,(Total_vaccinated/population)*100 as vacc_percent
from #vaccpercentage

-- create viewing for future purposes(tableu).

create view vacc_death as 
select location, population , max(cast(total_deaths as int)) as TotalDEAD
from portfoilio_project..CovidDeaths
where continent is not null
group by location, population
--order by TotalDEAD desc

select *
from vacc_death





























