
SELECT * FROM Project_portfolio_covid..[Covid Deaths]
-- Likelihood of dying if infected with COVID in your country. Filter country by location = 'country name'
SELECT location, last_updated_date, total_cases, total_deaths ,(total_deaths/ NULLIF(total_cases, 0) ) * 100 AS DeathPercent
FROM dbo.[Covid Deaths]
ORDER BY 1, 2;

-- Percent of popuation infected with COVID in country
SELECT location, last_updated_date, total_cases, population ,(total_cases/ population) * 100 AS InfectedPercent
FROM dbo.[Covid Deaths]
ORDER BY 1, 2;

-- Countries with high to low infection rate
SELECT location, last_updated_date, total_cases, population ,(total_cases/ population) * 100 AS InfectedPercent
FROM dbo.[Covid Deaths]
ORDER BY InfectedPercent DESC;

-- Countries with High to Low Death rate
SELECT location, last_updated_date, total_deaths, population ,(total_deaths/ population) * 100 AS DeathPercent
FROM dbo.[Covid Deaths]
WHERE continent IS NOT NULL
ORDER BY DeathPercent DESC;


-- JOINING Tables
SELECT d.location, d.last_updated_date, d.population, v.total_vaccinations
FROM Project_portfolio_covid..[Covid Deaths] d
JOIN Project_portfolio_covid..CovidVaccinations v
ON d.location = v.location AND d.last_updated_date = v.last_updated_date
WHERE d.continent IS NOT NULL
ORDER BY v.total_vaccinations DESC;

-- Using CTE for PopVsVac Percent vaccinated by population
WITH PopVsVac (continent, location, last_updated_date, population, total_vaccinations, Vaccinated_percent)
AS 
(SELECT d.continent, d.location, d.last_updated_date, d.population, v.total_vaccinations, (CAST(v.total_vaccinations AS float)/CAST(d.population AS float)) *100 AS Vaccinated_percent
FROM Project_portfolio_covid..[Covid Deaths] d
JOIN Project_portfolio_covid..CovidVaccinations v
	ON d.location = v.location 
	AND d.last_updated_date = v.last_updated_date
WHERE d.continent IS NOT NULL)
SELECT *  -- Or specify the columns you need from the CTE
FROM PopVsVac
ORDER BY continent;

-- Ranking continents based on death percent 
SELECT DISTINCT continent, total_deaths, population ,(total_deaths/ population) * 100 AS DeathPercent, RANK() OVER (PARTITION BY  continent ORDER BY (total_deaths/ population) * 100) AS DeathRank
FROM Project_portfolio_covid..[Covid Deaths]
WHERE continent IS NOT NULL
GROUP BY continent, population, total_deaths
ORDER BY DeathPercent DESC;