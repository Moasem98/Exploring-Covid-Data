 select *
from CovidDeaths
order by location, date;



--Select Data that we are going to be using it.
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2;



--Looking at Total cases Vs Total deaths.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathCasesPercentage
from CovidDeaths
where location like'egypt%'
and continent is not null
order by 1,2;




--Looking at the Total Cases Vs Population.
--Shows what percentage of population got covid.
select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from CovidDeaths
where location like'egypt%'
and continent is not null
order by 1,2;






--Looking at Countries with Highest Infection Rate Compared to Population.
select location, population, max(total_cases) as HighestInfectedCount, max((total_cases/population)*100) as InfectedPopulationPercentage
from CovidDeaths
where continent is not null
group by location, population
order by 4 desc;




--Showing Countries With Highest Death Count Per Population
select location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by location
order by 2 desc;






--Let's Group Things By Continent
select location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is null
group by location
order by 2 desc;



--Showing Continents With the Highest Death Count Per Population
select location, population, max(cast(total_deaths as int)) as HighestDeathCount, max((total_deaths/population)*100 )as HighestDeathPercentage
from CovidDeaths
where continent is null
group by location, population
order by 4 desc;



--Global Numbers
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/ sum(new_cases)*100) as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2



--Looking at Total Population VS Vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
       sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
     on d.location = v.location
	 and d.date = v.date
 where d.continent is not null
 order by 2,3




 --Use CTE
 with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
 select d.continent, d.location, d.date, d.population, v.new_vaccinations,
       sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
     on d.location = v.location
	 and d.date = v.date
 where d.continent is not null
 )
 select *, (RollingPeopleVaccinated/population)*100
 from PopvsVac




 --Temp Table
 drop table if exists PercentPopulationVaccinated
 create table PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 insert into PercentPopulationVaccinated
  select d.continent, d.location, d.date, d.population, v.new_vaccinations,
       sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
     on d.location = v.location
	 and d.date = v.date

 select *, (RollingPeopleVaccinated/population)*100
 from PercentPopulationVaccinated



--Creating Views to store data for later visulaizations

create view PercentagePopulationVaccinated as
  select d.continent, d.location, d.date, d.population, v.new_vaccinations,
       sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
     on d.location = v.location
	 and d.date = v.date
where d.continent is not null