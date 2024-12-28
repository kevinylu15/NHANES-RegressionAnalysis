# Exploring the Relationship Between Substance Use and Sexual Behaviors: From NHANES Data

The primary goal was to investigate how substance use experience (e.g., marijuana, hard drugs) correlates with the age of first sexual activity and the number of sexual activities during one’s lifetime. 

**Key findings:**
1. Individuals with self-reported substance use history initiated sexual activity, on average, 1–2 years earlier.
2. Contrary to conventional assumptions, the *lifetime* number of sexual activities was significantly lower for individuals with a self-reported substance use history, once socioeconomic, demographic, and other confounding factors were controlled for.

## Background

- Previous studies on NHANES data often focus on adolescent populations, highlighting a positive association between early substance use and increased sexual risk behaviors.
- This project expands the focus across all age groups, leveraging publicly available NHANES data to paint a broader picture.
- I examined whether the observed relationship between earlier sexual initiation and substance use holds, and whether it translates into higher or lower total lifetime sexual activity.

## Methodology

1. **Data Collection**:  
   - I used NHANES survey data, focusing on variables capturing demographics, socioeconomic status, sexual behavior, and substance use. 
   
2. **Preprocessing & Cleaning**:  
   - Data was cleaned to remove incomplete responses and outliers. 
   - Relevant features (e.g., age of first sexual activity, reported substance use history, race, income) were selected and calculated for analysis.

3. **Analysis**:  
   - **Simple Linear Models**: Explored raw associations between substance use and sexual behavior (e.g., correlation between age of first sexual activity and substance use experience).  
   - **Multiple Linear Regression**: Controlled for demographic and socioeconomic confounders to refine insights on the relationship between substance use and sexual behaviors.  
   - **Interaction Terms**: Examined the interaction between marijuana use and hard drug use to measure combined or separate effects on sexual behavior outcomes.

4. **Statistical Software**:  
   - Analyses were conducted using R (with libraries such as `dplyr`, `ggplot2`, `car`, `tidyr`, `gtsummary`, and `olsrr`).

## Results

1. **Earlier Sexual Initiation**:  
   - Respondents with a self-reported history of substance use reported experiencing sexual debut 1–2 years earlier on average.
   
2. **Lower Overall Sexual Activity**:  
   - Adjusting for socioeconomic status, demographics, and other potential confounders:
     - Individuals reporting regular marijuana use (controlling for hard drug use) had an average of **53.72% fewer** sexual activities.
     - Individuals reporting hard drug use (controlling for regular marijuana use) had an average of **84.91% fewer** sexual activities.

3. **Interpretation**:  
   - Despite earlier onset of sexual activity, substance use does **not** necessarily predict a higher number of overall lifetime sexual activities.

## Contributing

If you'd like to improve the function or add features, please submit a pull request or send me an email.

## License

This study is released under the MIT License. See the **[LICENSE](https://www.blackbox.ai/share/LICENSE)** file for details.
