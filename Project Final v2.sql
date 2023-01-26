Select *
From dbo.CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From dbo.CovidVaccinations
--Order by 3,4

--Shortlisted Coloumns to perform analysis

Select location, date,	total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Total cases VS Total deaths
-- Shows chances of dying if you get infected by COVID
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From dbo.CovidDeaths
Where location like '%india%'
Order by 1,2

-- Total cases VS population
Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercent
From dbo.CovidDeaths
Where location like '%states%'
and continent is not null
Order by InfectedPercent

-- countries which got most affected
Select location, population, max(total_cases) as max_cases, max((total_cases/population))*100 as CountryInfectedPercent
From dbo.CovidDeaths
Where continent is not null
Group by location, population
Order by CountryInfectedPercent desc

-- Countries with highest death count
Select location, max(cast(total_deaths as int)) as max_death
From dbo.CovidDeaths
Where continent is not null
Group by location
Order by max_death desc

-- Continents with highest death count
Select location, max(cast(total_deaths as int)) as max_death
From dbo.CovidDeaths
Where continent is null
Group by location
Order by max_death desc

--Showing the continents with highest death counts per population
Select location, max(cast(total_deaths as int)) as max_death, population, (max(cast(total_deaths as int))/population)*100 as death_percentage
From dbo.CovidDeaths
Where continent is null
Group by location, population
Order by max_death desc

--GLOBAL NUMBERS
Select SUM(new_cases) as Global_cases,SUM(cast(new_deaths as int)) as Global_deaths, (SUM(new_cases)/SUM(cast(new_deaths as int)))*100 as GlobalDeathPercentage
From dbo.CovidDeaths
Where continent is not null
--Group by date
Order by 1

--USING THE OTHER TABLE

Select *
FROM dbo.CovidVaccinations

--JOINING TABLE
--Total population vs Total Vaccination

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null
Order by 2,3

--USING CTE (A common table expression, or CTE, is a temporary named result set created from a simple SELECT statement that can be used in a subsequent SELECT statement. Each SQL CTE is like a named query, whose result is stored in a virtual table (a CTE) to be referenced later in the main query)

With PopVsVac (continent, location, date, population, new_vaccinated, RollingPeopleVaccinated )
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100 as VaccinationPercentage
From PopVsVac


--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinated numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated
Where Continent is not null
Order by location, date


Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
--Where dea.continent is not null

--Opening View
Select *
From PercentPopulationVaccinated