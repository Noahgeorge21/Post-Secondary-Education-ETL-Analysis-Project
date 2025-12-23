DROP TABLE IF EXISTS DW_Outcome;

CREATE TABLE DW_Outcome (

   -- From EarningsOutcome
    InstitutionID              VARCHAR(8),
    DegreeAwardCode            VARCHAR(2),
    DegreeAwardName            VARCHAR(100),
    CIPCode                    VARCHAR(2),
    Cohort                     VARCHAR(9),
    YearsPostgrad              INTEGER,
    Percentile                 INTEGER,
    Earnings                   INTEGER,
    Graduates                  INTEGER,
    Employed                   INTEGER,

   -- From Institution
    InstitutionName            VARCHAR(255),

   -- From CIP
    Description                VARCHAR(255),

   -- From FlowsOutcome
    IndustryID                 INTEGER,
    Instate                    BOOL,
    Flow                       INTEGER,
    IndustryName               VARCHAR(100),

   -- From CAINC5N (state-level earnings)
    StateCode                  VARCHAR(2),
    CountyCodeWithinStateCode  VARCHAR(3),
    County                     VARCHAR(100),
    State                      VARCHAR(100),
    TotalEarnings              INTEGER
);

INSERT INTO DW_Outcome (
    InstitutionID,
    DegreeAwardCode,
    DegreeAwardName,
    CIPCode,
    Cohort,
    YearsPostgrad,
    Percentile,
    Earnings,
    Graduates,
    Employed,
    InstitutionName,
    Description,
    IndustryID,
    Instate,
    Flow,
    IndustryName,
    StateCode,
    CountyCodeWithinStateCode,
    County,
    State,
    TotalEarnings
)
SELECT
    eo.InstitutionID,
    eo.DegreeAwardCode,
    eo.DegreeAwardName,
    eo.CIPCode,
    eo.Cohort,
    eo.YearsPostgrad,
    eo.Percentile,
    eo.Earnings,
    eo.Graduates,
    eo.Employed,
    i.InstitutionName,
    c.Description,
    fo.IndustryID,
    fo.Instate,
    fo.Flow,
    fo.IndustryName,
    t.StateCode,
    t.CountyCodeWithinStateCode,
    t.County,
    t.State,
    t.TotalEarnings
FROM EarningsOutcome eo
INNER JOIN Institution i
    ON eo.InstitutionID = i.InstitutionID
INNER JOIN CIP c
    ON eo.CIPCode = c.Code
LEFT JOIN FlowsOutcome fo
    ON eo.InstitutionID   = fo.InstitutionID
   AND eo.DegreeAwardCode = fo.DegreeAwardCode
   AND eo.CIPCode         = fo.CIPCode
   AND eo.YearsPostgrad   = fo.YearsPostgrad
   AND eo.Cohort          = fo.Cohort
LEFT JOIN (
    SELECT
        'All Cohorts'              AS Cohort,
        StateCode,
        CountyCodeWithinStateCode,
        County,
        IndustryID,
        State,
        SUM(TotalEarnings) AS TotalEarnings
    FROM CAINC5N
    WHERE Year BETWEEN 2001 AND 2022
      AND CountyCodeWithinStateCode = '000'
    GROUP BY
        StateCode,
        CountyCodeWithinStateCode,
        County,
        IndustryID,
        State
) t
   ON eo.Cohort    = t.Cohort
  AND fo.IndustryID = t.IndustryID;



