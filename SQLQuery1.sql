--select * from coviddeaths
--where continent is not null
--order by 3


--select * from covidvaccination
--where continent is not null
--order by 3,4


--shows chances of death due to covid in india
--select location,date,population,total_cases,new_cases,total_deaths,(convert(float,total_deaths)/convert(float,total_cases))*100 as deathpercent
--from coviddeaths
--where location like 'india'and total_cases is not null and continent is not null
--order by 2,3


--total cases vs population   ho got covid
--select location,date,population,total_cases,new_cases,total_deaths,(convert(float,total_cases)/population)*100 as deathrate
--from coviddeaths
--where location like 'india'and total_cases is not null and continent is not null
--order by 2,3


----highest infection rate countries
--select location,population,max(convert(int,total_cases)) as maxcases,max((convert(int,total_cases)/population))*100 as highinfecrate
--from coviddeaths
--where total_cases is not null and continent is not null
--group by location,population
--order by 4 desc

--who many dies due to covid
--select continent,location,population,max(convert(int,total_deaths)) as maxdeaths,max((convert(int,total_deaths)/population))*100 as highdeathrate
--from coviddeaths
--where continent is not null
--group by location,population,continent
--order by 3 desc

--as per continent
--select continent,max(convert(int,total_deaths)) as maxdeaths
--from coviddeaths
--where continent is not null 
--group by continent
--order by 1 desc

--view for totaldeaths per continent
--create view totaldeaths as
--select continent,max(convert(int,total_deaths)) as maxdeaths
--from coviddeaths
--where continent is not null 
--group by continent

--select date,sum(new_deaths) as totaldeaths
--from coviddeaths
--where continent is not null
--group by date


--population vs vaccination
--select location from covidvaccination

--VACINATION TABLE
--select *from coviddeaths de
--join covidvaccination va
--on de.location=va.location and de.date=va.date
--set ansi_warnings off

--total ne vaccination in locations
--select de.continent,de.location,--de.date,de.population,va.new_vaccinations,
--sum(convert(bigint,va.new_vaccinations)) from project1..coviddeaths de
--join project1..covidvaccination va
--on de.location=va.location and de.date=va.date
--where de.continent is not null  and population is not null
--group by de.continent,de.location
--order by 1


select de.continent,de.location,de.date,de.population,va.new_vaccinations,
sum(convert(bigint,va.new_vaccinations)) over (partition by de.location order by de.date) as totalvac --,max(totalvac)/population 
from project1..coviddeaths de
join project1..covidvaccination va
on de.location=va.location and de.date=va.date
where de.continent is not null  and population is not null

order by 1

--we cannot use the column name we created to peform operations so we go for cte(common table expression) or temp
--using CTE/////////////////////
--vaccination percentage per location day wise
with cte(continent,location,date,population,ne_vaccinations,totalvac)
as
(select de.continent,de.location,de.date,de.population,va.new_vaccinations,
sum(convert(bigint,va.new_vaccinations)) over (partition by de.location order by de.date) as totalvac --,(max(totalvac)/population )*100
from project1..coviddeaths de
join project1..covidvaccination va
on de.location=va.location and de.date=va.date
where de.continent is not null  and population is not null
--order by 2  views cannot have order by
)
select *,((convert(bigint,totalvac))/population) from cte
--group by continent,location,date,population,ne_vaccinations,totalvac
)
--vaccination percntage per location
with cte(continent,location,population,new_vaccinations,totalvac)
as
(select de.continent,de.location,de.population,va.new_vaccinations,
sum(convert(bigint,va.new_vaccinations)) over (partition by de.location) as totalvac --,(max(totalvac)/population )*100
from project1..coviddeaths de
join project1..covidvaccination va
on de.location=va.location and de.date=va.date
where de.continent is not null  and population is not null
--order by 2  views cannot have order by
)
select *,(max(totalvac)/population) from cte
group by continent,location,population,new_vaccinations,totalvac
order by 1


--TEMP TABLE
drop table if exists popuvac
create table popuvac
(continent nvarchar(255),location nvarchar(255),date datetime, population numeric,new_vaccinations numeric,totalvac numeric)
insert into popuvac
select de.continent,de.location,de.date,de.population,va.new_vaccinations,
sum(convert(bigint,va.new_vaccinations)) over (partition by de.location order by de.date) as totalvac --,(max(totalvac)/population )*100
from project1..coviddeaths de
join project1..covidvaccination va
on de.location=va.location and de.date=va.date
where de.continent is not null  and population is not null

select *,totalvac/population from popuvac

--creating view to store data for later

create view popvac as
select de.continent,de.location,de.date,de.population,va.new_vaccinations,
sum(convert(bigint,va.new_vaccinations)) over (partition by de.location order by de.date) as totalvac --,(max(totalvac)/population )*100
from project1..coviddeaths de
join project1..covidvaccination va
on de.location=va.location and de.date=va.date
where de.continent is not null  and population is not null
