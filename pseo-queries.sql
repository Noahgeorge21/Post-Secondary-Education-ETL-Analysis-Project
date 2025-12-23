SELECT
    Description AS CIPName,
    AVG(CASE WHEN YearsPostgrad = 1 THEN Earnings END) AS OneYearPostgrad,
    AVG(CASE WHEN YearsPostgrad = 5 THEN Earnings END) AS FiveYearsPostgrad,
    AVG(CASE WHEN YearsPostgrad = 10 THEN Earnings END) AS TenYearsPostgrad
FROM DW_Outcome
WHERE
    Cohort = 'All Cohorts'
    AND Percentile = 50
	AND InstitutionID = '00283800'
GROUP BY
    Description
ORDER BY
    MIN(CIPCode);   -- ensures CIPCode ascending order
	
SELECT
    Description AS CIPName,
    AVG(CASE WHEN Percentile = 25 THEN Earnings END) AS TwentyFifthPercentile,
    AVG(CASE WHEN Percentile = 50 THEN Earnings END) AS FiftiethPercentile,
    AVG(CASE WHEN Percentile = 75 THEN Earnings END) AS SeventyFifthPercentile
FROM DW_Outcome
WHERE
    Cohort = 'All Cohorts'
    AND YearsPostgrad = 5
	AND InstitutionID = '00283800'
GROUP BY
    Description
ORDER BY
    MIN(CIPCode);

WITH FilteredFlows AS (
    -- 1. Apply the three required filters directly on FlowsOutcome
    SELECT
        printf('%02d', CIPCode) AS CIPCode,
        IndustryName,
        Flow
    FROM FlowsOutcome
    WHERE Cohort = 'All Cohorts'
      AND YearsPostgrad = 1
      AND Instate = 0
	  AND InstitutionID = '00283800'
),
FlowsWithCIP AS (
    -- 2. Attach CIPName from the CIP table
    SELECT
        c.Code        AS CIPCode,
        c.Description AS CIPName,
        f.IndustryName,
        f.Flow
    FROM FilteredFlows f
    JOIN CIP c
      ON c.Code = f.CIPCode
),
AggregatedFlows AS (
    -- 3. Ratio-of-sums setup: sum Flow by CIP + Industry,
    --    and total Flow by CIP across all industries.
    SELECT
        CIPCode,
        CIPName,
        IndustryName,
        SUM(Flow) AS IndustryFlow,
        SUM(SUM(Flow)) OVER (PARTITION BY CIPCode) AS TotalCIPFlow
    FROM FlowsWithCIP
    GROUP BY CIPCode, CIPName, IndustryName
)
SELECT
    CIPName,

    -- AgricultureEtc
    SUM(CASE WHEN IndustryName = 'Agriculture, Forestry,Fishing and Hunting'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS AgricultureEtc,

    -- MiningEtc
    SUM(CASE WHEN IndustryName = 'Mining, Quarrying, andOil and Gas Extraction'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS MiningEtc,

    -- Utilities
    SUM(CASE WHEN IndustryName = 'Utilities'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS Utilities,

    -- Construction
    SUM(CASE WHEN IndustryName = 'Construction'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS Construction,

    -- Manufacturing
    SUM(CASE WHEN IndustryName = 'Manufacturing'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS Manufacturing,

    -- WholesaleTrade
    SUM(CASE WHEN IndustryName = 'Wholesale Trade'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS WholesaleTrade,

    -- RetailTrade
    SUM(CASE WHEN IndustryName = 'Retail Trade'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS RetailTrade,

    -- TransportationAndWarehousing
    SUM(CASE WHEN IndustryName = 'Transportation andWarehousing'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS TransportationAndWarehousing,

    -- Information
    SUM(CASE WHEN IndustryName = 'Information'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS Information,

    -- FinanceAndInsurance
    SUM(CASE WHEN IndustryName = 'Finance and Insurance'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS FinanceAndInsurance,

    -- RealEstateEtc
    SUM(CASE WHEN IndustryName = 'Real Estate and Rentaland Leasing'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS RealEstateEtc,

    -- ProfessionalSvcsEtc
    SUM(CASE WHEN IndustryName = 'Professional, Scientific,and Technical Services'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS ProfessionalSvcsEtc,

    -- Management
    SUM(CASE WHEN IndustryName = 'Management ofCompanies andEnterprises'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS Management,

    -- AdministrativeEtc
    SUM(CASE WHEN IndustryName = 'Administrative andSupport and WasteManagement andRemediation Services'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS AdministrativeEtc,

    -- EducationalSvcs
    SUM(CASE WHEN IndustryName = 'Educational Services'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS EducationalSvcs,

    -- HealthCareEtc
    SUM(CASE WHEN IndustryName = 'Health Care and SocialAssistance'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS HealthCareEtc,

    -- ArtsEtc
    SUM(CASE WHEN IndustryName = 'Arts, Entertainment, andRecreation'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS ArtsEtc,

    -- AccommodationAndFoodSvcs
    SUM(CASE WHEN IndustryName = 'Accommodation andFood Services'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS AccommodationAndFoodSvcs,

    -- OtherSvcs
    SUM(CASE WHEN IndustryName = 'Other Services (exceptPublic Administration)'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS OtherSvcs,

    -- PublicAdministration
    SUM(CASE WHEN IndustryName = 'Public Administration'
             THEN IndustryFlow * 1.0 / TotalCIPFlow ELSE 0 END) AS PublicAdministration

FROM AggregatedFlows
GROUP BY CIPCode, CIPName
ORDER BY CIPCode;

-- Distribution of Total Earnings by State
-- Rows: State
-- Columns: Industry (as ratios of state total earnings)

WITH StateIndustryTotals AS (
    SELECT
        State,
        IndustryID,
        SUM(TotalEarnings) AS TotalEarnings
    FROM CAINC5N
    WHERE
        CountyCodeWithinStateCode = '000'       -- state-level rows
        AND Year BETWEEN 2001 AND 2022          -- years included in warehouse build
        AND TotalEarnings IS NOT NULL
    GROUP BY
        State,
        IndustryID
)

SELECT
    State,

    -- 11  Agriculture, Forestry,Fishing and Hunting
    SUM(CASE WHEN IndustryID = '11'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS AgricultureEtc,

    -- 21  Mining, Quarrying, andOil and Gas Extraction
    SUM(CASE WHEN IndustryID = '21'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS MiningEtc,

    -- 22  Utilities
    SUM(CASE WHEN IndustryID = '22'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS Utilities,

    -- 23  Construction
    SUM(CASE WHEN IndustryID = '23'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS Construction,

    -- 31-33 Manufacturing
    SUM(CASE WHEN IndustryID = '31-33'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS Manufacturing,

    -- 42  Wholesale Trade
    SUM(CASE WHEN IndustryID = '42'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS WholesaleTrade,

    -- 44-45 Retail Trade
    SUM(CASE WHEN IndustryID = '44-45'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS RetailTrade,

    -- 48-49 Transportation andWarehousing
    SUM(CASE WHEN IndustryID = '48-49'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS TransportationAndWarehousing,

    -- 51  Information
    SUM(CASE WHEN IndustryID = '51'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS Information,

    -- 52  Finance and Insurance
    SUM(CASE WHEN IndustryID = '52'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS FinanceAndInsurance,

    -- 53  Real Estate and Rentaland Leasing
    SUM(CASE WHEN IndustryID = '53'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS RealEstateEtc,

    -- 54  Professional, Scientific,and Technical Services
    SUM(CASE WHEN IndustryID = '54'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS ProfessionalSvcsEtc,

    -- 55  Management ofCompanies andEnterprises
    SUM(CASE WHEN IndustryID = '55'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS Management,

    -- 56  Administrative andSupport and WasteManagement andRemediation Services
    SUM(CASE WHEN IndustryID = '56'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS AdministrativeEtc,

    -- 61  Educational Services
    SUM(CASE WHEN IndustryID = '61'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS EducationalSvcs,

    -- 62  Health Care and SocialAssistance
    SUM(CASE WHEN IndustryID = '62'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS HealthCareEtc,

    -- 71  Arts, Entertainment, andRecreation
    SUM(CASE WHEN IndustryID = '71'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS ArtsEtc,

    -- 72  Accommodation andFood Services
    SUM(CASE WHEN IndustryID = '72'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS AccommodationAndFoodSvcs,

    -- 81  Other Services (exceptPublic Administration)
    SUM(CASE WHEN IndustryID = '81'
             THEN TotalEarnings ELSE 0 END) * 1.0 /
    SUM(TotalEarnings) AS OtherSvcs,

    -- 92  Public Administration – per your TA, keep this NULL
    NULL AS PublicAdministration

FROM StateIndustryTotals
GROUP BY
    State
ORDER BY
    State;

	
--“Flow into Industry by Institution & Degree Level”	
SELECT
    InstitutionName,
    IndustryName,
	DegreeAwardName, 
    SUM(Flow) AS TotalFlow
FROM DW_Outcome
WHERE
    Cohort = 'All Cohorts'
    AND Flow IS NOT NULL
    AND IndustryName IS NOT NULL
GROUP BY
    InstitutionName,
    IndustryName
ORDER BY
    InstitutionName,
    IndustryName;
	

	
	
--“Number of Employed by Master’s Degree (2016–2020) Bing vs. Baruch”
SELECT
    InstitutionName,
    Description as CIPName,
	DegreeAwardName,
    SUM(Employed) AS TotalEmployed,
    SUM(Graduates) AS TotalGraduates
FROM DW_Outcome
WHERE
    Cohort = '2016-2020'
    AND DegreeAwardCode = '07'
	AND InstitutionName IN ('Binghamton University', 'CUNY Bernard M Baruch College')
GROUP BY
    InstitutionName,
    CIPName
ORDER BY
    InstitutionName,
    CIPName;


















	
