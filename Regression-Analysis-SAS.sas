/***************************************************************************/
/*  LOAD NHANES DATA */
/***************************************************************************/

FILENAME REFFILE 'C:/Users/lub11/OneDrive/Documents/NHANES.csv';

PROC IMPORT DATAFILE=REFFILE
    DBMS=CSV
    OUT=work.df
    REPLACE;
    GETNAMES=YES;
RUN;

/***************************************************************************/
/*  EXPLORATORY DATA ANALYSIS (EDA) */
/***************************************************************************/

/* 2.1 Histograms */

/* In SAS, you can use PROC UNIVARIATE or PROC SGPLOT to create histograms. */

/* (i) Histogram for SexAge */
PROC SGPLOT DATA=work.df;
  HISTOGRAM SexAge;
  TITLE "First Age at which Sexual Activity Occurred";
RUN;

/* (ii) Histogram for SexNumPartYear */
PROC SGPLOT DATA=work.df;
  HISTOGRAM SexNumPartYear;
  TITLE "Number of Sexual Partners per Year";
RUN;

/* (iii) Histogram for SexNumPartnLife */
PROC SGPLOT DATA=work.df;
  HISTOGRAM SexNumPartnLife;
  TITLE "Lifetime Number of Sexual Partners";
RUN;


/* Identify potential data issues/outliers */

/* Show observations where SexAge > Age */
DATA check_AgeIssue;
    SET work.df;
    IF SexAge > Age THEN OUTPUT;
RUN;

TITLE "Observations where SexAge exceeds current Age";
PROC PRINT DATA=check_AgeIssue; 
RUN;

/* Boxplot to detect outliers in SexNumPartnLife */
PROC SGPLOT DATA=work.df;
  VBOX SexNumPartnLife;
  TITLE "Number of Sexual Partners Distribution Before Outlier Removal";
RUN;

/* Identify observations with more than 40 partners */
DATA check_Outliers;
    SET work.df;
    IF SexNumPartnLife > 40 THEN OUTPUT;
    KEEP Age SexAge SexNumPartnLife;
RUN;

TITLE "Observations with SexNumPartnLife > 40";
PROC PRINT DATA=check_Outliers; 
RUN;

/* Remove outliers (SexNumPartnLife > 40) */
DATA work.df_clean;
    SET work.df;
    IF SexNumPartnLife <= 40;
RUN;

/* Boxplot after removal */
PROC SGPLOT DATA=work.df_clean;
  VBOX SexNumPartnLife;
  TITLE "Number of Sexual Partners Distribution After Outlier Removal";
RUN;


/***************************************************************************/
/* CREATE NEW VARIABLES & TRANSFORMATIONS */
/***************************************************************************/

/* 3.1 AvgSexFreq = SexNumPartnLife / (Age - SexAge), log-transformed */
DATA work.df_clean;
    SET work.df_clean;
    IF (Age - SexAge) > 0 THEN do;
        AvgSexFreq_raw = SexNumPartnLife / (Age - SexAge);
        /* Log-transform */
        AvgSexFreq = LOG(AvgSexFreq_raw);
    end;
    ELSE do;
        AvgSexFreq_raw = .;
        AvgSexFreq      = .;
    end;
RUN;

/* Histogram of AvgSexFreq before/after log transform */

PROC SGPLOT DATA=work.df_clean;
  HISTOGRAM AvgSexFreq_raw;
  TITLE "AvgSexFreq Before Log Transformation";
RUN;

PROC SGPLOT DATA=work.df_clean;
  HISTOGRAM AvgSexFreq;
  TITLE "AvgSexFreq After Log Transformation";
RUN;


/***************************************************************************/
/*  LINEAR MODELING */
/***************************************************************************/

/* Model 1: SexAge ~ SmokeNow */
TITLE "Model 1: SexAge ~ SmokeNow";
PROC REG DATA=work.df_clean;
    MODEL SexAge = SmokeNow;
RUN;
QUIT;

/* Model 2: SexAge ~ AlcoholYear */
TITLE "Model 2: SexAge ~ AlcoholYear";
PROC REG DATA=work.df_clean;
    MODEL SexAge = AlcoholYear;
RUN;
QUIT;

/* Model 3: SexAge ~ RegularMarij + HardDrugs + Interaction */
TITLE "Model 3: SexAge ~ RegularMarij + HardDrugs + RegularMarij*HardDrugs";
PROC REG DATA=work.df_clean;
    MODEL SexAge = RegularMarij HardDrugs RegularMarij*HardDrugs;
RUN;
QUIT;

/* Model 4: SexNumPartnLife ~ RegularMarij + HardDrugs + Interaction */
TITLE "Model 4: SexNumPartnLife ~ RegularMarij + HardDrugs + RegularMarij*HardDrugs";
PROC REG DATA=work.df_clean;
    MODEL SexNumPartnLife = RegularMarij HardDrugs RegularMarij*HardDrugs;
RUN;
QUIT;

/***************************************************************************/
/* DESCRIPTIVE STATISTICS */
/***************************************************************************/

/* Table Grouped by Hard Drugs */

TITLE "Summary by HardDrugs (Continuous Variables)";
PROC MEANS DATA=work.df_clean N MEAN STD;
    CLASS HardDrugs;
    VAR SexAge SexNumPartnLife AvgSexFreq;  /* continuous variables */
RUN;

/* For categorical breakdown, you can use PROC FREQ */
TITLE "Frequency by HardDrugs (Categorical Variables)";
PROC FREQ DATA=work.df_clean;
    TABLES Gender*HardDrugs / NOROW NOCOL NOPERCENT;
RUN;

/***************************************************************************/
/* MISSING DATA */
/***************************************************************************/

/* Number of complete records */

DATA temp_missing;
    SET work.df_clean;
    /* 1 = no missing, 0 = missing at least one var*/
    IF NMISS(AvgSexFreq, SmokeNow, AlcoholYear, RegularMarij, HardDrugs, Age, Gender, HHIncome, Education)=0 
       THEN missingness="Not Missing";
    ELSE missingness="Missing";
RUN;

/* Counts of commplete and missing */
PROC FREQ DATA=temp_missing;
    TABLES missingness / LIST;
RUN;

/* Table by missingness status */
TITLE "Demographics by Missingness Status";
PROC MEANS DATA=temp_missing N MEAN STD;
   CLASS missingness;
   VAR Age;
RUN;

PROC FREQ DATA=temp_missing;
   TABLES missingness*(Gender HHIncome Education MaritalStatus) / NOROW NOCOL NOPERCENT;
RUN;

/* Logistic regression to predict missingness */
TITLE "Logistic Regression Predicting Missingness";
PROC LOGISTIC DATA=temp_missing;
    CLASS Gender MaritalStatus Education HHIncome / PARAM=REF;
    MODEL missingness (EVENT='Missing') = Age Gender HHIncome Education MaritalStatus;
RUN;

/***************************************************************************/
/* FULL MODEL */
/***************************************************************************/

/* lm(AvgSexFreq ~ SmokeNow + AlcoholYear + RegularMarij + HardDrugs + RegularMarij*HardDrugs + Age + Gender + HHIncome + 
Education + BMI + DiabetesAge + Depressed + LittleInterest + PhysActive + SameSex) */

TITLE "Full Model for AvgSexFreq";
PROC REG DATA=work.df_clean;
    MODEL AvgSexFreq = SmokeNow AlcoholYear RegularMarij HardDrugs 
                       RegularMarij*HardDrugs Age Gender HHIncome Education 
                       BMI DiabetesAge Depressed LittleInterest PhysActive SameSex;
RUN;
QUIT;

/***************************************************************************/
/*  CHECKING LINEARITY ASSUMPTIONS & MODEL DIAGNOSTICS */
/***************************************************************************/

/* 8.1 Refit a simpler model (m1 in R code) */
TITLE "Initial M1 for AvgSexFreq";
PROC REG DATA=work.df_clean;
    MODEL AvgSexFreq = SmokeNow AlcoholYear RegularMarij HardDrugs 
                       RegularMarij*HardDrugs Age Gender HHIncome Education
    / INFLUENCE R STB VIF; 
    OUTPUT OUT=m1_out R=resid COOKD=cookd DFFITS=dffits; 
RUN;
QUIT;

/* Checking outliers/influential points */

PROC SORT DATA=m1_out OUT=m1_sorted;
    BY DESCENDING cookd;
RUN;

PROC PRINT DATA=m1_sorted (OBS=10);  /* Check top 10 influential obs by Cook's D */
    VAR Age Gender HHIncome Education resid cookd dffits;
    TITLE "Top 10 Observations by Cook's Distance";
RUN;

/* Refit model */

DATA df2;
    SET m1_out;
    IF _N_ = 7919 THEN DELETE;  
RUN;

PROC REG DATA=df2;
    MODEL AvgSexFreq = SmokeNow AlcoholYear RegularMarij HardDrugs 
                       RegularMarij*HardDrugs Age Gender HHIncome Education 
    / R VIF; 
    TITLE "Model M2 Without Influential Observation";
RUN;
QUIT;
