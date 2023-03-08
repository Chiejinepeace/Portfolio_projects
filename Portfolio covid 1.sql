--View data
Select *
From portfolio.dbo.CovidDeaths
where continent is not null
order by 3,4

Select *
From portfolio.dbo.CovidVaccinations
where continent is not null
order by 3,4


-- Select data
Select location, population, date, total_cases,new_cases, total_deaths
From portfolio.dbo.CovidDeaths
order by 1,3

--Select location, date, population, total_cases, total_deaths, round( (total_deaths/total_cases)*100 , 2) as death_percent
--From portfolio.dbo.CovidDeaths
--Where location = 'Nigeria'
--order by 1, 2

--Total cases vs Population in Nigeria
Select location, date, population, total_cases, total_deaths, round( (total_cases/population)*100 , 2) as percent_population_infected
From portfolio.dbo.CovidDeaths
Where location = 'Nigeria'
order by 1, 2

--Countries with highest infection rates compared to popuation
Select location, population, MAX(total_cases) as max_total_cases, round( MAX((total_cases/population))*100 , 2) as percent_population_infected
From portfolio.dbo.CovidDeaths
group by location, population
order by 4 desc

--Countries with highest death count per population

Select location, MAX(cast (total_deaths as int)) as max_total_deaths, MAX(total_cases) as max_total_cases,  MAX((total_deaths/total_cases))*100 as death_percent
From portfolio.dbo.CovidDeaths
Where continent is not null
group by location
order by 4 desc

--FILTER by continent
Select continent, MAX(cast (total_deaths as int)) as max_total_deaths_continent
From portfolio.dbo.CovidDeaths
Where continent is not null
group by continent
order by 2 desc

--GLOBAL NUMBERS (group global deaths by date)
Select date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as daily_death_percent
From portfolio.dbo.CovidDeaths
Where continent is not null
group by date
order by 1, 2

--Global Numbers(Total)
Select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as death_percent
From portfolio.dbo.CovidDeaths
Where continent is not null



--JOIN AND VIEW TABLES
Select *
From portfolio.dbo.CovidDeaths dea
Join portfolio.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null 

--Create column for rolling count of new vaccinations by location
Select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccination_count
From portfolio.dbo.CovidDeaths dea
Join portfolio.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null 
order by 2, 3 

----USE CTE to store data temporarily

--With population_vaccine(continent, location, date, population, new_vaccination, rolling_vaccination_count)
--as 
--(
--	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--		SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccination_count
--	From portfolio.dbo.CovidDeaths dea
--	Join portfolio.dbo.CovidVaccinations vac
--		on dea.location = vac.location
--		and dea.date = vac.date
--	Where dea.continent is not null 
--) 
--Select *, (rolling_vaccination_count / population)* 100  as percent_population_vaccinated
--from population_vaccine

--CREATE temp table
Drop Table if exists #population_vaccinated
Create Table #population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccination numeric,
rolling_vaccination_count numeric
)
Insert into #population_vaccinated  
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccination_count
	From portfolio.dbo.CovidDeaths dea
	Join portfolio.dbo.CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null 

Select *, (rolling_vaccination_count / population)* 100  as percentage_vaccinated
from #population_vaccinated

--Create Views for data viz

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccination_count
	From portfolio.dbo.CovidDeaths dea
	Join portfolio.dbo.CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null 

select *
From PercentPopulationVaccinated

Create View GlobalDailyDeaths as
Select date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as daily_death_percent
From portfolio.dbo.CovidDeaths
Where continent is not null
group by date

select *
From GlobalDailyDeaths