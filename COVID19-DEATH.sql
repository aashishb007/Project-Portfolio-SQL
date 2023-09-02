select *
from PortfolioProject..CovidDeaths$
where continent is not NULL
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not NULL
order by 1,2

-----Looking at Total Cases Vs Total Deaths
----Liklihood of dying if you contact covid in your country

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

---Looking at the total_cases vs Population
--- Show what percentage of population got covid



Select Location, date, total_cases, population,(total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2




------Looking at countries with highest infection rate compare to population

Select Location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not NULL
group by population,location
Order by PercentPopulationInfected desc

----Showing with the highest death count per population 



Select Location, Max(cast(Total_deaths as int)) as TotalDeathCOunt
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not NULL
group by location
Order by TotalDeathCOunt desc


-----Break things down by continent



Select continent, Max(cast(Total_deaths as int)) as TotalDeathCOunt
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is  not NULL
group by continent
Order by TotalDeathCOunt desc




----Showing continent with the highest deathcounts

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCOunt
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is  not NULL
group by continent
Order by TotalDeathCOunt desc



---Global Numbers

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
---where location like '%states%'
where continent is not Null
--Group by date
order by 1,2


-----Looking at Total Population vs Vaccinations

----USE CTE

with PopVsVac(continent,Location,Date,population, new_vaccinations,RollingPeopleVaccinated) 
as 
(
select dea.continent ,dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join
PortfolioProject..CovidVaccinations$ vac
on
dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by  2,3
)
select*,(RollingPeopleVaccinated/population)*100
from PopVsVac



 
 ---TEMP TABLE

 Drop Table if exists #PercentagePopulationVaccinated
 Create Table #PercentagePopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


 Insert into #PercentagePopulationVaccinated
 select dea.continent ,dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join
PortfolioProject..CovidVaccinations$ vac
on
dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by  2,3
 
 
 select*,(RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated



----Creating View to store data for later visualization

create view PercentagePopulationVaccinated as 
select dea.continent ,dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join
PortfolioProject..CovidVaccinations$ vac
on
dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by  2,3


select* from 
PercentagePopulationVaccinated