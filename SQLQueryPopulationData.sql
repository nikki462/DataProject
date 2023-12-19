select * from dbo.CovidDeaths$
where continent is not null
order by 3,4

--Select data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths$
where continent is not null
ORder by 1,2

-- Looking at total cases vs total deaths 
-- Shows the likelihood of dying if you contract covid in your country
Select Location, Date, total_cases,  total_deaths, (Total_deaths / total_cases) *100 as DeathPercentage
From dbo.CovidDeaths$
where Location like '%states%' and continent is not null
ORDER BY 1,2

-- Looking at the total cases vs the population 
-- Shows what percentage of the population got covid.

Select Location, Date, Population, total_cases,  (total_cases / Population) *100 as CasePercentage
From dbo.CovidDeaths$
--where Location like '%states%'
where continent is not null
ORDER BY 1,2

-- What countries have the highest infection rates.
Select Location,  Population, MAX(total_cases) as HighestInfectionCount,  max((total_cases / Population)) *100 as CasePercentage
From dbo.CovidDeaths$
where continent is not null
--where Location like '%states%'
Group by Location, Population
ORDER BY CasePercentage DESC

-- show the countries with the highest DeathCount per population 
Select Location, Max(cast (total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths$
where continent is  null
--where Location like '%states%'
Group By Location
ORDER BY TotalDeathCount DESC

-- broken down by continent  


-- Showing the continent with the highest death count 
Select Continent, Max(cast (total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths$
where continent is not null
--where Location like '%states%'
Group By Continent
ORDER BY TotalDeathCount DESC


-- Global numbers 
--date,
Select  sum(new_cases) as TotalCases ,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int)) / sum(new_cases)*100 as deathPercentage	
From dbo.CovidDeaths$
--Location like '%states%' and
where  continent is not null
--Group by date
ORDER BY 1,2


select * from PortfolioProject..CovidVaccinations$

-- Looking for Total Population vs vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
	sum(cast(new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.date ) as rollingPeopleVaccinated
	--,(rollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.Location = vac.Location 
		and dea.date = vac.date	
	where dea.continent is not null
	order by 2,3

	--USE CTE 
	with PopvsVac (Continent, Location, Date, Population , new_vaccinations, rollingPeopleVaccinated)
	as 
	(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
	sum(cast(new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.date ) as rollingPeopleVaccinated
	--,(rollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths$ dea
	join PortfolioProject..CovidVaccinations$ vac
		ON dea.Location = vac.Location 
			and dea.date = vac.date	
		where dea.continent is not null
	--	order by 2,3
		)
		Select *, (rollingPeopleVaccinated/Population)*100
		from PopvsVac


		--temp table 
		--Drop Table if exists #percentPopulationVaccinated
		--if OBJECT_ID(#percentPopulationVaccinated,'U') is not null
		IF EXISTS(SELECT 1 FROM sys.objects where name = 'PortfolioProject.dbo.#percentPopulationVaccinated' AND type = 'U')
		Drop Table #percentPopulationVaccinated

		Create table #percentPopulationVaccinated
		(Continent nvarchar(255), Location nvarchar(255), date datetime, 
		population numeric, 
		new_vaccinations numeric, 
		RollingPeopleVaccinated numeric
		)

		insert into #percentPopulationVaccinated
		select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
		sum(cast(new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.date ) as rollingPeopleVaccinated
		--,(rollingPeopleVaccinated/population)*100
		From PortfolioProject..CovidDeaths$ dea
		join PortfolioProject..CovidVaccinations$ vac
			ON dea.Location = vac.Location 
				and dea.date = vac.date	
		where dea.continent is not null
	--	order by 2,3
		select *, (RollingPeopleVaccinated/Population) *100
		From #percentPopulationVaccinated
		

 --select @@version

 --Create Views 

 CREATE view PercentPopulationVaccinated as		
 	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
	sum(cast(new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.date ) as rollingPeopleVaccinated
	--,(rollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths$ dea
	join PortfolioProject..CovidVaccinations$ vac
		ON dea.Location = vac.Location 
			and dea.date = vac.date	
	where dea.continent is not null
	--order by 2,3
