#  COVID-19 Global Data Exploration & Visualization

##  Project Overview
This project provides a comprehensive analysis of global COVID-19 data, transitioning from raw data cleaning and exploration in **SQL** to an interactive visual story in **Tableau**. 

The goal was to uncover mortality trends, infection rates relative to population, and the global progression of vaccination rollouts.

---

##  Project Links
*   **Interactive Dashboard:** [View Tableau Dashboard Here](https://public.tableau.com/views/CovidDashboardProject1_17699804346020/Dashboard1?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
*   **SQL Script:** [View SQL Analysis Code](Covid_exploration.sql)
*   **Data Source:** [Our World in Data (COVID-19)](https://ourworldindata.org)

---

##  Tech Stack & Skills
*   **SQL:** Data Cleaning, Joins, CTEs, Temp Tables, Window Functions, Aggregate Functions, Creating Views.
*   **Tableau:** Dashboard Design, Geographic Mapping, KPI Big Numbers (BANs), Interactive Filtering.
*   **Data Engineering:** Sanitizing data types and handling null values for mathematical accuracy.

---

##  Key Questions Addressed
1. **The Likelihood of Dying:** What is the death percentage if you contract COVID-19 in a specific country?
2. **Infection Density:** What percentage of the population has been infected per country?
3. **Regional Impact:** Which continents are suffering the highest total death counts?
4. **Vaccination Progress:** How is the rolling sum of vaccinations progressing relative to a country's population?

---

##  SQL Highlights
I leveraged advanced SQL techniques to transform the data for analysis. One of the primary challenges was calculating a **Rolling Total of Vaccinations** using partitioned data:

```sql
-- Using CTE to calculate vaccination percentage over time
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM ProjectPortfolio.coviddeaths dea
JOIN ProjectPortfolio.covidvaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopVsVac;

---

## Dashboard Preview
Below is a snapshot of the final interactive dashboard. It features global KPI tiles, a geographic infection heatmap, and continental mortality breakdowns.

---

![Tableau Dashboard Preview](https://raw.githubusercontent.com/KaoneData/COVID-19-Data-Analysis/refs/heads/main/preview.png)

---

## How to Use
1. **SQL:** Run the provided `.sql` script in your preferred environment (MySQL, MS SQL Server, etc.) to recreate the views.
2. **Tableau:** Access the interactive dashboard via the link in the "Project Links" section to filter by region and date.

---

## 👤 Author
**Kaone Edward**
*   [LinkedIn](https://www.linkedin.com/in/kaone-edward-bbb820197/)
*   [GitHub](https://github.com/KaoneData)

