# gcam_sdg
This repository includes different scripts to automatically compute and report Sustainable development Goals (SDG)-related indicators for alternative GCAM scenarios.

## SDG description

### SDG 1:
TBA

### SDG 2: Zero hunger
Source: https://www.un.org/sustainabledevelopment/hunger/

Script: [SDG2_Food_Basket_Bill.R](https://github.com/bc3LC/gcam_sdg/blob/main/R/SDG2_Food_Basket_Bill.R)

Description: 

In this implementation, SDG 2 is represented as the (avoided) per capita food basket bill. The calculations estimate the annual regional expenditure by a median consumer. Specifically, for each period t and region r, all food items are aggregated into *Staples* and *Non-Staples*. Then, the total consumption of each group has been multiplied by its price, as described in the equation below:

$$FoodExpenditurePC_{t,r} = \sum_{fs\ in\ foodStapleItems} ConsumptionPC_{fs,t,r} \cdot PricePCStaples_{t,r} \ + $$

$$\sum_{fc\ in\ foodNonStapleItems} ConsumptionPC_{fn,t,r} \cdot PricePCNonStaples_{t,r}$$

### SDG 3: Ensure healthy lives and promote well-being for all at all ages
Source: https://www.un.org/sustainabledevelopment/health/

Script: [SDG3_Health.R](https://github.com/bc3LC/gcam_sdg/blob/main/R/SDG3_Health.R)

Description: 

In this implementation, SDG 3 is represented as the (avoided) premature mortalities attributable to long-term exposure to both fine particulate matter (PM2.5) and tropospheric ozone (O3). Calculations have been computed using rfasst, a tool designed to quantify adverse health and agricultural effects attributable to air pollution for alternative scenarios (Sampedro et al 2022). The tool mimics the well-stablished TM5-FASST model (Van Dingenen et al 2018). 
The calculation of premature mortalities is based on the population-attributable fraction approach, so premature mortality (Mort) for cause c, in period t, region r, associated with exposure to pollutant j, is calculated as the product between the baseline mortality rate, the change in the RR relative risk of death attributable to a change in population-weighted mean pollutant concentration, and the population exposed. This is described in the following equation:

$$Mort_{c,t,r,j}=mo_{c,r,j}\cdot\frac{RR_{c,j}-1}{RR_{c,j}}\cdot Pop_{t,r}$$

Mortalities are estimated for six causes, namely stroke, ischemic heart disease (IHD), chronic obstructive pulmonary disease (COPD), acute lower respiratory illness diseases (ALRI), lung cancer (LC), and diabetes Mellitus Type II (DM). IHD and STROKE are calculated for different age groups, using “age-group-specific” parameters (i.e., mortality rates and relative risks), while COPD, ALRI, LC and DM are estimated for the whole population exposed (pop > 25 years).
- Population exposed is cause-specific. Population fractions are calculated from the from the SSP database: https://tntcat.iiasa.ac.at/SspDb/dsd?Action=htmlpage&page=10

- Cause-specific baseline mortality rates are computed using absolute mortality from the Global Burden of Disease (GBD) (https://vizhub.healthdata.org/gbd-compare/) and population statistics (to get exposed population and fractions). The projected changes of these rates over time are taken from the World Health Organization projections.

- For PM2.5, relative risk is calculated based on Integrated Exposure-Response functions (ERFs) from the GBD 2017 (Stanaway et al 2018). Compared to previous assessments (e.g., Burnett et al 2014), this method includes age-group-specific parameters and the addition of diabetes mellitus type II.

- For O3, relative risk is based on the ERFs from Jerrett et al 2009. 

References SDG3

- Burnett R T, Pope C A III, Ezzati M, Olives C, Lim S S, Mehta S, Shin H H, Singh G, Hubbell B, Brauer M, Anderson H R, Smith K R, Balmes J R, Bruce N G, Kan H, Laden F, Prüss-Ustün A, Turner M C, Gapstur S M, Diver W R and Cohen A 2014 An Integrated Risk Function for Estimating the Global Burden of Disease Attributable to Ambient Fine Particulate Matter Exposure Environmental Health Perspectives Online: http://ehp.niehs.nih.gov/1307049/

- Jerrett M, Burnett R T, Pope III C A, Ito K, Thurston G, Krewski D, Shi Y, Calle E and Thun M 2009 Long-term ozone exposure and mortality New England Journal of Medicine 360 1085–95

- Sampedro J, Khan Z, Vernon C R, Smith S J, Waldhoff S and Dingenen R V 2022 rfasst: An R tool to estimate air pollution impacts on health and agriculture Journal of Open Source Software 7 3820

- Stanaway J D, Afshin A, Gakidou E, Lim S S, Abate D, Abate K H, Abbafati C, Abbasi N, Abbastabar H and Abd-Allah F 2018 Global, regional, and national comparative risk assessment of 84 behavioural, environmental and occupational, and metabolic risks or clusters of risks for 195 countries and territories, 1990–2017: a systematic analysis for the Global Burden of Disease Study 2017 The Lancet 392 1923–94

- Van Dingenen R, Dentener F, Crippa M, Leitao J, Marmer E, Rao S, Solazzo E and Valentini L 2018 TM5-FASST: a global atmospheric source–receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants Atmospheric Chemistry and Physics 18 16173–211

## SDG 6: Clean Water and Sanitation
Source: https://www.un.org/sustainabledevelopment/water-and-sanitation/

Script: [SDG6_Water_Scarcity.R](https://github.com/bc3LC/gcam_sdg/blob/main/R/SDG6_Water_Scarcity.R)

Description: 

The water module of GCAM is structured in 235 basins. The water withdrawals are defined as water diverted from a surface water or groundwater source. They are estimated for six major sectors: agriculture, electricity generation, industrial manufacturing, primary energy production, livestock and municipal uses. 

The water supply separates three distinct sources of fresh water: renewable water, non-renewable groundwater and desalinated water. Renewable water is water that is replenished naturally by surface runoff and subsurface infiltration and release. It is determined by the natural streamflow, baseflow, the total reservoir storage and the environmental flow requirement for each basins (Kim et al., 2016). 

We quantify physical water scarcity as the ratio of water withdrawals to renewable water supply for each basin (Birnbaum et al., 2022). The fraction of water demand relative to available renewable surface water supply has also been labelled ‘water stress index’ in previous studies (Byers et al., 2018). To derive a single estimate per scenario, we compute the average of the index weighted by the volume of renewable water withdrawal of each basin at baseline year (2015). The index is estimated with the following equations: 

$$I_{s,b}=W_{s,b}/S_{s,b}$$ 

and

$$I_{s} = sum_{b=1}^b (I_{s,b} * W_{s,b,2015}) / sum_{b=1}^b W_{s,b,2015}$$

Where I is the water scarcity index per basin (dimensionless), W is the water withdrawal in km3, S is the renewable water supply in km3, b are the basins, and s are the scenarios. 

References SDG6

- Birnbaum, A., Lamontagne, J., Wild, T., Dolan, F., & Yarlagadda, B. (2022). Drivers of Future Physical Water Scarcity and Its Economic Impacts in Latin America and the Caribbean. Earth’s Future, 10(8), e2022EF002764. https://doi.org/10.1029/2022EF002764
- Byers, E., Gidden, M., Leclère, D., Balkovic, J., Burek, P., Ebi, K., Greve, P., Grey, D., Havlik, P., Hillers, A., Johnson, N., Kahil, T., Krey, V., Langan, S., Nakicenovic, N., Novak, R., Obersteiner, M., Pachauri, S., Palazzo, A., … Riahi, K. (2018). Global exposure and vulnerability to multi-sector development and climate change hotspots. Environmental Research Letters, 13(5), 055012. https://doi.org/10.1088/1748-9326/aabf45
- Kim, S. H., Hejazi, M., Liu, L., Calvin, K., Clarke, L., Edmonds, J., Kyle, P., Patel, P., Wise, M., & Davies, E. (2016). Balancing global water availability and use at basin scale in an integrated assessment model. Climatic Change, 136(2), 217–231. https://doi.org/10.1007/s10584-016-1604-6

## SDG15: Life of Land
Source: https://www.un.org/sustainabledevelopment/biodiversity/

Description: 

The land module is structured around 384 distinct land-water regions, called LUTs, and provides outputs on land allocation for 43 land uses per LUT. It computes supply, demand, and land utilisation in various sectors, encompassing food, feed, fiber, forestry, and bioenergy production. The land uses can be categorized into two broad sets: managed and unmanaged land. The latter includes unmanaged forests, unmanaged pasture, shrubland, grassland, tundra and other land types (e.g. rock, ice and desert). 

The indicator reported for SDG15 is the proportion of unmanaged land on total land area, which is assumed to represent the impact of anthropic activities, such as deforestation and land degradation, on the biological integrity of the global land system. The average value per scenario is computed by weighting values of LUTs by their total respective areas,  through the following equations: 

$$P_{s,b}=100*UL_{s,b}/TL_{s,b}$$ 

and

$$P_{s} = sum_{i=1}^i (P_{s,i} * TL_{s,i}) / sum_{i=1}^i TL_{s,i}$$

Where P is the unmanaged land proportion in %, UL is the area of unmanaged land in Mha, TL is the total area (managed and unmanaged) in Mha, i are the LUTs, and s are the scenarios. 

## GCAM SDG studies

- Moreno, J., Campagnolo, L., Boitier, B., Nikas, A., Koasidis, K., Gambhir, A., Gonzalez-Eguino, M., Perdana, S., Van de Ven, D.J., Chiodi, A. and Delpiazzo, E., 2024. The impacts of decarbonization pathways on Sustainable Development Goals in the European Union. Communications Earth & Environment, 5(1), p.136.

- Moreno, J., Van de Ven, D.J., Sampedro, J., Gambhir, A., Woods, J. and Gonzalez-Eguino, M., 2023. Assessing synergies and trade-offs of diverging Paris-compliant mitigation strategies with long-term SDG objectives. Global Environmental Change, 78, p.102624.

- Iyer, G., Calvin, K., Clarke, L., Edmonds, J., Hultman, N., Hartin, C., McJeon, H., Aldy, J. and Pizer, W., 2018. Implications of sustainable development considerations for comparability across nationally determined contributions. Nature Climate Change, 8(2), pp.124-129.

