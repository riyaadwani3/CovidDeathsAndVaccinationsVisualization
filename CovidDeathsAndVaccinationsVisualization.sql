Select * 
from CovidVaccination
order by 4,3

Select * 
from CovidDeaths
order by 4,3

-- Selecting data that we are going to use

Select location, date, population, total_cases, new_cases,total_deaths
from CovidDeaths
order by 1,2

-- Calculating total cases vs total deaths

Select location, date, total_deaths, total_cases, (total_deaths/ total_cases)*100 
as DeathPercentage from CovidDeaths
order by 1,2

-- Calculating total cases vs population

Select location, date, total_deaths, total_cases, population, (total_cases/ population)*100 as CovidCasesPercentage 
from CovidDeaths
order by 1,2

--Calculating highest infection rate by countries compared to population

Select location, population, max(total_cases) HighestInfectionCount, (max(total_cases/population))*100 
PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- Showing countries by highest death count per population

Select location, max(cast(total_deaths as int)) HighestDeathCount
from CovidDeaths
where continent is not null
group by location, population
order by HighestDeathCount desc

Select continent, max(cast(total_deaths as int)) HighestDeathCount
from CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc


Select location, max(cast(total_deaths as int)) HighestDeathCount
from CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc


-- Showing continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Join, CTE, Windows

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac

-- Temp table

Drop table if exists #PercentPopulationVaccination
Create table #PercentPopulationVaccination(
Continent varchar(255), 
Location varchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * from #PercentPopulationVaccination


-- Global Numbers
--1.
Select SUM(new_cases) total_cases, Sum(cast(new_deaths as int)) total_deaths, Sum(cast(new_deaths as int))/
Sum(new_cases)*100 DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2 desc

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
--2.
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--3. 

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 
as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--4.


Select Location, Population,convert(datetime,date) as date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc