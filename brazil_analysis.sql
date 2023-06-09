/*

Covid Data Exploration in Brazil

*/

-- Gerando a tabela covid.deaths

create table covid.deaths as (

  select
    iso_code,
    continent,
    location,
    date(date) as date,
    total_cases,
    new_cases,
    total_deaths,
    new_deaths,
    population
  from covid.brazil
  order by date

)

-- Gerando a tabela covid.vaccination

create table covid.vaccination as (

  select
    iso_code,
    continent,
    location,
    date(date) as date,
    total_tests,
    new_tests,
    total_vaccinations,
    new_vaccinations
  from covid.brazil
  order by date

)

-- Analisando os Dados

-- Total de Casos x Total de Mortes
-- Mostra probabilidade de morrer se contrair covid no Brasil

select 
  Location,
  date,
  format_timestamp("%Y", date) as year,
  total_cases,
  total_deaths,
  (total_deaths/total_cases) * 100 as DeathPercentage
from covid.deaths
where total_cases is not null
order by date, year

-- Total Casos x População
-- Mostra qual a porcentagem da população infectada com Covid

select
  Location,
  date,
  format_timestamp("%Y", date) as year,
  Population,
  total_cases,  
  (total_cases/population) * 100 as PercentPopulationInfected
from covid.deaths
where total_cases is not null
order by date, year

-- Taxa de infecção geral
-- Mostra qual a taxa de infecção em comparação com a população

select 
  Location, 
  Population, 
  max(total_cases) as HighestInfectionCount,  
  max( (total_cases/population ) ) * 100 as PercentPopulationInfected
from covid.deaths
group by Location, Population
order by PercentPopulationInfected desc

-- Total de Mortes

select 
  Location,
  max( cast( Total_deaths as int ) ) as TotalDeathCount
from covid.deaths
group by Location

-- Total População vs Vacinação
-- Mostra a porcentagem da população que recebeu pelo menos uma vacina contra a Covid

with PopxVac as (
  select
    d.location,
    d.date,
    format_timestamp("%Y", d.date) as year,
    d.population,
    cast(v.new_vaccinations as int64) as new_vaccinations
  from covid.deaths d
  join covid.vaccination v on d.date = v.date
  where new_vaccinations is not null
  order by d.date, year

)

select 
  *, 
  (new_vaccinations / population) * 100 as PeopleVaccinated
from PopxVac

-- Criando view para armazenar dados

create view covid.PercentPopulationVaccinated as

select
  d.location,
  d.date,
  format_timestamp("%Y", d.date) as year,
  d.population,
  d.total_cases,
  d.total_deaths,
  v.total_vaccinations,
  (v.total_vaccinations / d.population) * 100 as PeopleVaccinated
from covid.deaths d
join covid.vaccination v on d.date = v.date
where new_vaccinations is not null
order by d.date, year