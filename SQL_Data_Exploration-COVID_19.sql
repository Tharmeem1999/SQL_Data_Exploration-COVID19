SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is Not Null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--Select Data that going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is Not Null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contracted COVID in your country
Select location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%lanka' And continent is Not Null
ORDER BY 1,2
-- *Note below:
	-- Multiplying by 1.0 converts total_deaths to float, preventing integer division
	-- This ensures the DeathPercentage shows accurate decimal values instead of truncating to 0


-- Total Cases vs Population 
-- Shows the percentage of the population infected with COVID
Select location, date, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%lanka'
ORDER BY 1,2


-- Identifies countries with the highest infection rates compared to their population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%lanka'
Group By location, population
ORDER BY PercentPopulationInfected desc


-- Identifying countries with Highest Death Count per Population
Select location, MAX(total_deaths) As TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%lanka'
Where continent is Not Null
Group By location
ORDER BY TotalDeathCount desc

-- Identifying continent with Highest Death Count per Population
Select continent, MAX(total_deaths) As TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%lanka'
Where continent is Not Null
Group By continent
ORDER BY TotalDeathCount desc


-- Global Numbers (Group by Date)
Select date, SUM(new_cases) As TotalCases, SUM(new_deaths) As TotalDeaths, SUM(new_deaths*1.0)/SUM(new_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%lanka' 
Where continent is Not Null
Group By date
ORDER BY 1,2

	--Total (Without Group by Date)
Select SUM(new_cases) As TotalCases, SUM(new_deaths) As TotalDeaths, SUM(new_deaths*1.0)/SUM(new_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%lanka' 
Where continent is Not Null
--Group By date
ORDER BY 1,2


-- Comparing total population to vaccination numbers
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) As CumulativePeopleVaccinated
From PortfolioProject..CovidDeaths As dea
Join PortfolioProject..CovidVaccinations As vac
	On dea.location = vac.location And dea.date = vac.date
Where dea.continent is not Null
ORDER BY 2,3


-- Using CTE
With PopVsVac (Continent, location, date, population, new_vaccinations, CumulativePeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) As CumulativePeopleVaccinated
From PortfolioProject..CovidDeaths As dea
Join PortfolioProject..CovidVaccinations As vac
	On dea.location = vac.location And dea.date = vac.date
Where dea.continent is not Null
)
Select *, (CumulativePeopleVaccinated/population)*100 
From PopVsVac


-- Using Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) As CumulativePeopleVaccinated
From PortfolioProject..CovidDeaths As dea
Join PortfolioProject..CovidVaccinations As vac
	On dea.location = vac.location And dea.date = vac.date
--Where dea.continent is not Null

Select *, (CumulativePeopleVaccinated/population)*100 
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) As CumulativePeopleVaccinated
From PortfolioProject..CovidDeaths As dea
Join PortfolioProject..CovidVaccinations As vac
	On dea.location = vac.location And dea.date = vac.date
Where dea.continent is not Null
