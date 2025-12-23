--SELECT * FROM DbCovid..CovidDeaths 
--ORDER BY 3,4 --3. VE DÖRDÜNCÜ KOLONA GÖRE ASC ÞEKÝLDE SIRALADIK

--SELECT * FROM DbCovid..CovidVaccinations
--ORDER BY 3,4

--kullanacaðýmýz datalarý çekelim
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM DbCovid..CovidDeaths
ORDER BY 1,2

--total_cases VS total_deaths ( Death Percentage)
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths / total_cases)*100 as 'Death Percentage'
FROM DbCovid..CovidDeaths
WHERE location LIKE '%TURKEY%'
ORDER BY 1,2

--Totatl cases vs populatýon
--shows what percentage of populatýon got covid
SELECT location, date, total_cases, population, (total_deaths / population)*100 as 'Population Percentage'
FROM DbCovid..CovidDeaths
WHERE location LIKE '%TURKEY%'
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount , MAX((total_cases / population))*100 as PercentPopulationInfected
FROM DbCovid..CovidDeaths
--WHERE location LIKE '%TURKEY%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM DbCovid..CovidDeaths
--WHERE location LIKE '%TURKEY%'
WHERE continent IS NOT NULL --location'da kýta isimleri görünmesin diye
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM DbCovid..CovidDeaths
--WHERE location LIKE '%TURKEY%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers
SELECT date,  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM DbCovid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2

-----------------
--joýned two table
SELECT * 
FROM DbCovid..CovidDeaths dea
JOIN DbCovid..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--Looking at total population vs vaccinaciton
--Her bir satýrda, o ülkenin toplam aþý sayýsýný gösterir
--USE CTE
--**Her ülke için tarihe baðlý olarak, yapýlan aþýlarýn birikimli toplamýný ve bunun nüfusa oranýný (%) hesaplýyor.
WITH PopvsVac 
(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations )) OVER(PARTITION BY dea.location ORDER BY dea.location,  dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM DbCovid..CovidDeaths dea
JOIN DbCovid..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
--Bir ülkede nüfusun yüzde kaçý aþýlanmýþ?
SELECT *, (RollingPeopleVaccinated*100.0/Population)
FROM PopvsVac

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations )) OVER(PARTITION BY dea.location ORDER BY dea.location,  dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM DbCovid..CovidDeaths dea
JOIN DbCovid..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated*100.0/Population)
FROM #PercentPopulationVaccinated
----------------
USE DbCovid                                          
--Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations )) OVER(PARTITION BY dea.location ORDER BY dea.location,  dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM DbCovid..CovidDeaths dea
JOIN DbCovid..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3





