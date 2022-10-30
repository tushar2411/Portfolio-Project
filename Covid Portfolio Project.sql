SELECT * FROM Portfolio_Project..CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT * FROM Portfolio_Project..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- shows the likelihood of dying if you contract in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM Portfolio_Project..CovidDeaths
where location ='India'
ORDER BY 1,2

-- Looking at total cases vs population
-- shows that percentage of population got covid
SELECT Location, date, total_cases,population, (total_cases/population)*100 as PercentageOFPopualtion
FROM Portfolio_Project..CovidDeaths
--where location = 'India'
ORDER BY 1,2

--Looking at countries with Highest Infection Rate compared to population
SELECT Location,population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopualtionInfected 
FROM Portfolio_Project..CovidDeaths
--where location = 'India'
Group by location, population
ORDER BY PercentagePopualtionInfected desc
--ORDER BY Location desc

SELECT Location,population,date, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopualtionInfected 
FROM Portfolio_Project..CovidDeaths
--where location = 'India'
Group by location, population, date
ORDER BY PercentagePopualtionInfected desc

--Showing Countries with highest Death Count per Population
SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
--where location = 'India'
where continent is not null
Group by location
ORDER BY TotalDeathCount desc

-- Lets Break Things Down by Continent


-- Showing the continents with the highest death counts per population

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
--where location = 'India'
where continent is not null
Group by continent
ORDER BY TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


Select location, sum(cast(new_deaths as int)) as totalDeathCount
from Portfolio_Project..CovidDeaths
where continent is null
and location not in ('World','European Union','International')
Group By location
Order By totalDeathCount desc

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
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
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
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
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
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
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 