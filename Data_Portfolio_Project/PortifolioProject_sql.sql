/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From Portfolio..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where continent is not null 
order by 1,2

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where location like 'ind_a'
and continent is not null 
order by 1,2


Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
order by 1,2


select * from Portfolio..CovidVaccination
Select Location, continent,date,people_vaccinated,people_fully_vaccinated_per_hundred, total_vaccinations,total_vaccinations_per_hundred as PercentPopulationVaccinated
From Portfolio..CovidVaccination where continent is not null and people_vaccinated is not null and people_fully_vaccinated_per_hundred is not null and total_vaccinations is not null
order by 1,2

Select distinct vac.Location,vac.continent, dea.Population, total_vaccinations,  (total_vaccinations/population)*100 as PercentPopulationVaccinated
From Portfolio..CovidDeaths dea join Portfolio..CovidVaccination vac on vac.continent = dea.continent 
where dea.continent is not null and total_vaccinations is not null

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Countries with Highest Vaccination count per population
select * from portfolio..CovidVaccination

-- including total_vaccinations null values
Select Location, MAX(total_vaccinations ) as TotalVaccination
From Portfolio..CovidVaccination
Where continent is not null 
Group by Location
order by TotalVaccination 

-- not including total_vaccinations null values
Select Location, MAX(total_vaccinations ) as TotalVaccination
From Portfolio..CovidVaccination
Where continent is not null and total_vaccinations  is not null
Group by Location
order by TotalVaccination 



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--showing continents with highest vaccination percentage
Select continent, MAX(cast(total_vaccinations as int)) as TotalVaccinationCount
From Portfolio..CovidVaccination
Where continent is not null 
Group by continent
order by TotalVaccinationCount desc


-- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where continent is not null 
order by 1,2

--FULL JOIN,INNER JOIN,LEFT JOIN,RIGHT JOIN
select * from Portfolio..CovidDeaths
select * from Portfolio..CovidVaccination

Select   *
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select   *
From Portfolio..CovidDeaths dea
inner join Portfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select   *
From Portfolio..CovidDeaths dea
left join Portfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select   *
From Portfolio..CovidDeaths dea
right join Portfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

drop View PercentPopulationVaccinated 

/********script for select topnrows command from SSMS*********/
select top (1000) [continent]
,[location],[date],[population],[new_vaccinations],[RollingPeopleVaccinated] 
from
Portfolio..PercentPopulationVaccinated

select * from PercentPopulationVaccinated
