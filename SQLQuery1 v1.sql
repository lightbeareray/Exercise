select*
from PortfolioDatabase..CovidDeaths
order by 3, 4

-- select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioDatabase..CovidDeaths
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioDatabase..CovidDeaths
order by 1,2

--looking at total cases vs. percentage

select location, date, total_cases, population, (total_cases/population)*100 as CasePert
from PortfolioDatabase..CovidDeaths
order by 1,2

-- looking at countries with highest infection rate vs population

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CasePercentage
from PortfolioDatabase..CovidDeaths
Group by location, population
order by CasePercentage desc

--showing countries with the highest death count per population
select continent, Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioDatabase..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--global numbers

select date, sum(new_cases) as Total_Cases , Sum(cast(new_deaths as int)) as Total_Deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioDatabase..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as Total_Cases , Sum(cast(new_deaths as int)) as Total_Deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioDatabase..CovidDeaths
where continent is not null
--group by date
order by 1,2

with PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioDatabase..CovidDeaths dea
join PortfolioDatabase..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--temp table

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioDatabase..CovidDeaths dea
join PortfolioDatabase..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
order by 2,3

--creating view to store data for visualization

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioDatabase..CovidDeaths dea
join PortfolioDatabase..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated