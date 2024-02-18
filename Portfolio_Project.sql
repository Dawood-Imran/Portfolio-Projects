select * from Portfolio_Project..CovidDeaths$
where continent is not null
order by 3,4

select * from Portfolio_Project..CovidVacinations$
order by 3,4

-- Selecting the data that we have to work on
select location,date,total_cases,new_cases,total_deaths,population from Portfolio_Project..CovidDeaths$
order by 1,2


-- Looking at total_deaths vs total_cases
-- Taking a glimpse at the data of Pakistan
select location,date,total_cases,total_deaths,
(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS Death_Percentage
from Portfolio_Project..CovidDeaths$
where location like '%pakistan%'


-- Looking at total_cases vs population
select location,date,total_cases,population,
(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS Victam_Per
from Portfolio_Project..CovidDeaths$
where location like '%pakistan%'

-- Looking at countries with highest infection rate 
select location,population,Max(total_cases) as Max_Cases,
Max((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT))) * 100 AS Victam_Per
from Portfolio_Project..CovidDeaths$
group by location,population
order by Victam_Per desc


-- Looking at the countries with highest deaths
-- This is showing the entire continents data like Asia, Africa so we have to add another query 'Continent'
-- is not null

select location,Max(cast(total_cases as int)) as Max_Deaths
from Portfolio_Project..CovidDeaths$
where continent is not null
group by location
order by Max_Deaths desc


-- Doing the same thing with continents
select continent,Max(cast(total_cases as int)) as Max_Cases
from Portfolio_Project..CovidDeaths$
where continent is not null
group by continent
order by Max_Cases desc


-- Showing maximum deaths according to continents
select continent,Max(cast(total_deaths as int)) as Max_Deaths
from Portfolio_Project..CovidDeaths$
where continent is not null
group by continent
order by Max_Deaths desc


-- Showing the Global Results
select  sum(new_cases) as New_Cases, sum(cast(new_deaths as int)) as New_Deaths,
sum(cast(new_deaths as int))/sum(new_cases) as Death_Perc 
from Portfolio_Project..CovidDeaths$ 
where continent is not null
--group by date
order by 1,2


-- Joining the two tables
select * from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVacinations$ vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
order by 1,2


-- Checking the total people vaccinated
select dea.continent,dea.location,dea.date,vac.new_vaccinations from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVacinations$ vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
order by 2,3


-- Total Vaccinations done in Pakistan
select location, max(cast(new_vaccinations as int)) as Vac from Portfolio_Project..CovidVacinations$ 
where location like '%Pakistan'
group by location


-- Total tests per continents
select continent, max(cast(total_tests as float)) as Total_tests from Portfolio_Project..CovidVacinations$ 
where continent is not null
group by continent


-- Taking sum of all new vaccinations per day

select continent,location,date,new_vaccinations,sum(convert(int,new_vaccinations)) over (Partition by location order
by location,date) as Rolling_People_Vaccinated 
from Portfolio_Project..CovidVacinations$ 


-- Using CTE
With PopvsVac (continent,Location,date,new_vaccinations,Rolling_People_Vaccinated)
as
(
select continent,location,date,new_vaccinations,sum(convert(int,new_vaccinations)) over (Partition by location order
by location,date) as Rolling_People_Vaccinated 
from Portfolio_Project..CovidVacinations$ 
)


-- Creating a new Table
drop table Percentage_Population_Vaccinated
create table Percentage_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into Percentage_Population_Vaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(numeric,new_vaccinations)) over (Partition by dea.location order
by dea.location,dea.date) as Rolling_People_Vaccinated 
from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVacinations$ vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null


select * , (Rolling_People_Vaccinated/population) * 100 
from Percentage_Population_Vaccinated



-- Creating a view 
create view Population_Vaccinated_Percentage as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(numeric,new_vaccinations)) over (Partition by dea.location order
by dea.location,dea.date) as Rolling_People_Vaccinated 
from Portfolio_Project..CovidDeaths$ dea
join Portfolio_Project..CovidVacinations$ vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null


select * from Population_Vaccinated_Percentage

























































