select * from CovidDeaths


Select * from CovidVaccinations;

-- ====================================
-- Select data that we are going to use
-- =====================================

select Location, datecovid,new_cases, total_cases, total_deaths, population
from covidDeaths
order by 3,4


-- ============================
-- Looking at death percentage
-- ==============================
Select Location, datecovid, Total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_Percentage
from covidDeaths
order by 1,2

-- =================================
-- Looking at total death percentage
-- =================================
select sum(total_cases) as Total_Cases, sum(total_deaths) as Total_Deaths,round(sum(total_deaths)/sum(total_cases),3)*100 as Deaths_Percentage
from covidDeaths
where continent is not null 
order by 1,2


-- ====================================
-- Looking at death percentage in india
-- ====================================

Select Location, datecovid, Total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_Percentage
from covidDeaths
where location = 'India' 
order by 1,2

-- =====================================================
-- Looking at Maximum Death Percentage in the contries
-- =====================================================

select location, round(max(total_deaths/total_cases),3)*100 as death_percentage
from CovidDeaths
--where location = 'India'
group by Location
order by 1,2

-- ========================================
-- Looking at population effected in India
-- =========================================
Select Location, datecovid, Population, Total_cases, round((total_cases/population),5)*100 as population_infected
from covidDeaths
where location = 'India' and total_cases is not Null
order by 1,2

-- ======================================================================
-- Looking at countries with highest infection rate compare to population
-- ======================================================================

Select Location, Population, max(total_cases) as highest_count, round(max(total_cases/population),4)*100 as percent_population_infected
from covidDeaths
where continent is not null
group by Location, Population
order by percent_population_infected 

-- =========================================================
-- showing countries with highest death count per population
-- =========================================================

Select Location, Population, max(total_deaths) as highest_death_count, round(max(total_deaths/population),4)*100 as death_percentage
from covidDeaths
where continent is not null
group by Location, Population
order by highest_death_count desc

-- ============================================
-- Looking with highest death count Continents
-- ============================================

select Continent, max(total_deaths) as highest_death_count
from covidDeaths
where continent is not null
group by Continent
order by highest_death_count desc

-- ======================================================================
-- Looking with Continents(some of the null continents includes countires)
-- ======================================================================
select location, max(total_deaths) as highest_death_count
from covidDeaths
where continent is null
group by location
order by highest_death_count desc

-- ===============================
-- Looking each day how many cases
-- ===============================
Select datecovid, sum(new_cases)
from covidDeaths
group by datecovid
order by datecovid


-- ======================================
-- looking at population and vaccinations
-- ======================================
select d.continent, d.location, d.datecovid, d.population, 
v.new_vaccinations-- over(partition by d.location) as new_vaccinations
from covidDeaths d
join CovidVaccinations v
    on d.location = v.location
    and d.datecovid = v.dateVaccination
where d.continent is not null
order by 1,2 

-- ============================
-- total vaccinations
-- ============================
select d.continent, d.location, d.datecovid, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location, d.datecovid) as total_vaccinations
--(total_vaccinations/population)*100
from covidDeaths d
join CovidVaccinations v
    on d.location = v.location
    and d.datecovid = v.dateVaccination
where d.continent is not null
order by 1,2 

-- ============================
-- total vaccination percentage
--=============================
with pop_total_vaccination as
(
select d.continent, d.location, d.datecovid, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location, d.datecovid) as total_vaccinations
--(total_vaccinations/population)*100
from covidDeaths d
join CovidVaccinations v
    on d.location = v.location
    and d.datecovid = v.dateVaccination
where d.continent is not null
order by 1,2
)

Select continent, location, datecovid, population, new_vaccinations, total_vaccinations, round((total_vaccinations/population),3)*100 as Vaccination_percentage
from pop_total_vaccination

-- ====================================
-- creating temp table for Vaccinations
-- ====================================

create table percent_population_vaccinations
(
continent varchar2(100),
location varchar2(100),
datecovid date,
population number(30),
new_vaccinations number(30),
total_vaccinations number(30)
)

insert into percent_population_vaccinations

select d.continent, d.location, d.datecovid, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location, d.datecovid) as total_vaccinations
--(total_vaccinations/population)*100
from covidDeaths d
join CovidVaccinations v
    on d.location = v.location
    and d.datecovid = v.dateVaccination
--where d.continent is not null
order by 1,2 

-- ============================================
-- finding total Vaccinations using temp table
-- ===========================================
select continent, location, population, total_vaccinations, round((total_vaccinations/population),3)*100
from percent_population_vaccinations

-- ============================
-- creating views
-- ============================
create view percent_pop_vaccinations as
select d.continent, d.location, d.datecovid, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location, d.datecovid) as total_vaccinations
--(total_vaccinations/population)*100
from covidDeaths d
join CovidVaccinations v
    on d.location = v.location
    and d.datecovid = v.dateVaccination
--where d.continent is not null
order by 1,2 
