/*

Queries used for Tableau Project

*/


-- 1. Global Numbers

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths*1.0)/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2
-- *Note below:
	-- Multiplying by 1.0 converts total_deaths to float, preventing integer division
	-- This ensures the DeathPercentage shows accurate decimal values instead of truncating to 0



-- 2. Total Deaths by Continent

-- European Union is part of Europe
Select location, SUM(new_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null And location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

	

-- 3. Percentage of Population Infected by Country

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

	

-- 4. Percentage of Population Infected

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
