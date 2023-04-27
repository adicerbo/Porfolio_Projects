SELECT *
FROM PortfolioProject..coviddeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..covidvaccinations
ORDER BY 3,4

--SELECT DATA
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeaths
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS
--LIKELIHOOD OF DYING IF CONTRACTING COVID PER COUNTRY
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..coviddeaths
WHERE location LIKE '%STATES%'
ORDER BY 1,2 

--TOTAL CASES VS POPULATION
SELECT location, date, total_cases, population, (total_cases/population)*100 AS contraction_percentage
FROM PortfolioProject..coviddeaths
WHERE location LIKE '%STATES%'
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) AS max_cases, MAX((total_cases/population))*100 AS contraction_percentage
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY contraction_percentage DESC

--COUNTRIES WITH HIGHEST DEATH TOLL PER POPULATION
SELECT location, MAX(CAST(total_deaths AS INT)) AS max_death_count
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_death_count DESC

--DEATH TOLL BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS INT)) AS max_death_count
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY max_death_count DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--USING CTE
WITH PopVsVacc (continent, location, date, population, new_vaccinations, Rolling_Vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(CAST(VACC.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (Rolling_Vaccinations/population)*100 AS rolling_vaccinations
FROM PopVsVacc

--TEMP TABLE
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric, 
rolling_vaccinations numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(CAST(VACC.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date

SELECT *, (Rolling_Vaccinations/population)*100 AS rolling_vaccinations
FROM #percent_population_vaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUAL
CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(CAST(VACC.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM percent_population_vaccinated