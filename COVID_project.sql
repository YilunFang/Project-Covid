SELECT * 
FROM covid_deaths
ORDER BY location, date
Limit 40;

SELECT * 
FROM covid_vaccinations
ORDER BY location, date
Limit 40;

--There is no total_deaths in death file
SELECT 
	cd.location,
	cd.date,
	cv.total_cases,
	cv.new_cases,
	cv.total_deaths, 
	cv.population
FROM covid_vaccinations AS cv
LEFT JOIN covid_deaths AS cd ON cd.date = cv.date and cv.location = cd.location
ORDER BY location,date
Limit 40;

-- Total cases vs total deaths
SELECT 
	cd.location,
	cd.date,
	cv.total_cases,
	cv.total_deaths, 
    100*cv.total_deaths/cv.total_cases AS Deah_percen
FROM covid_vaccinations AS cv
LEFT JOIN covid_deaths AS cd ON cd.date = cv.date and cv.location = cd.location
WHERE cd.location like '%States%'
-- Shows likelihood of dying due to cvoid in your country
ORDER BY cd.location, date
Limit 200;

--Total cases vs total population
SELECT 
	cd.location,
	cd.date,
	cv.population,
	cv.total_cases,
	cv.total_deaths, 
    100*cv.total_cases/cv.population AS Covid_percent
FROM covid_vaccinations AS cv
LEFT JOIN covid_deaths AS cd ON cd.date = cv.date and cv.location = cd.location
-- Shows likelihood of dying due to cvoid in your country
ORDER BY cd.location, date
Limit 200;

--Looking at countries with highest infection rate relative to population
SELECT 
	cd.location,
	cv.population,
	MAX(cv.total_cases) AS highestinfectioncount,
    100*MAX(cv.total_cases)/cv.population AS MAXCovid_percent
FROM covid_vaccinations AS cv
LEFT JOIN covid_deaths AS cd ON cd.date = cv.date and cv.location = cd.location
-- Shows likelihood of dying due to cvoid in your country
WHERE cd.continent IS NOT NULL
GROUP BY cd.location, cv.population
HAVING MAX(cv.total_cases) IS NOT NULL 
	and cv.population IS NOT NULL
ORDER BY MAXCovid_percent DESC;

--showing countries with highest death count per population
SELECT 
	cd.location,
	MAX(cv.total_deaths) AS highestdeathcount,
    100*MAX(cv.total_deaths)/cv.population AS Highdeath_percent
FROM covid_vaccinations AS cv
LEFT JOIN covid_deaths AS cd ON cd.date = cv.date and cv.location = cd.location
-- Shows likelihood of dying due to cvoid in your country
WHERE cd.location != 'International' and cd.continent IS NOT NULL
GROUP BY cd.location, cv.population
HAVING MAX(cv.total_deaths) IS NOT NULL 
ORDER BY highestdeathcount DESC;
--ORDER BY Highdeath_percent DESC;

--Break down by continent 
SELECT cv.location, MAX(cv.total_deaths) AS highestdeathcount
FROM covid_vaccinations AS CV
LEFT JOIN covid_deaths AS cd ON cd.date = cv.date and cv.location = cd.location
WHERE cv.continent IS NULL
GROUP BY cv.location
ORDER BY highestdeathcount DESC;

--showing contintents with the highest death count per population
SELECT 
	cv.continent, 
	MAX(cv.total_deaths) AS highestdeathcount
FROM covid_vaccinations AS CV
LEFT JOIN covid_deaths AS cd ON cd.date = cv.date and cv.location = cd.location
WHERE cv.continent IS NOT NULL
GROUP BY cv.continent
ORDER BY highestdeathcount DESC;

-- GLOBAL NUMBERS
SELECT 
	cd.date,
	SUM(cv.total_cases,
	cv.total_deaths, 
    100*cv.total_deaths/cv.total_cases AS Deah_percen
FROM covid_vaccinations AS cv
LEFT JOIN covid_deaths AS cd ON cd.date = cv.date and cv.location = cd.location
WHERE cv.continent IS NOT NULL
ORDER BY cd.location, date
Limit 200;

--death count and death rate per day
SELECT
	cv.date,
	SUM(cv.new_cases) AS total_cases_daily,
	SUM(cv.new_deaths) AS total_deaths_dail,
	100*SUM(cv.new_deaths)/SUM(cv.new_cases) AS Deathpercent_daily
FROM covid_vaccinations AS cv
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

--looking at total population vs vaccinations
WITH CTE AS(
	SELECT 
		cd.continent,
		cd.location,
		cd.date,
		cv.population,
		cv.new_vaccinations,
		SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location,cd.date) AS rollingpeople_vaccinated
	FROM covid_vaccinations AS cv
	LEFT JOIN covid_deaths AS cd ON cd.date = cv.date and cv.location = cd.location
	WHERE cd.continent IS NOT NULL
)
SELECT *, 100*(rollingpeople_vaccinated/population) 
FROM CTE
ORDER BY location,date;

--TEM table
CREATE TEMP TABLE Percentpopulationvaccinated
( 
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingpeople_vaccinated NUMERIC
);

INSERT INTO Percentpopulationvaccinated
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cv.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (
        PARTITION BY cd.location 
        ORDER BY cd.date
    ) AS rollingpeople_vaccinated
FROM covid_vaccinations AS cv
LEFT JOIN covid_deaths AS cd 
    ON cd.date = cv.date 
    AND cv.location = cd.location
WHERE cd.continent IS NOT NULL;

SELECT *,(rollingpeople_vaccinated/Population)*100
FROM Percentpopulationvaccinated;



