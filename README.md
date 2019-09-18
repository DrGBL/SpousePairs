# SpousePairs
Code for deriving a list of preliminary spouse-pairs in UK Biobank

<b>Input</b>

Assuming two data-sets containing variables in the following order (UK Biobank Field IDs):

a) file1: tab delimited file containing: <br>

UK Biobank ID (0-0.0) <br>
How are people in household related to participant (6141) <b> NOTE: There are multiple columns for this question </b> <br>

b) file2: tab delimited file containing: <br>

UK Biobank ID (0-0.0) <br>
Sex (31-0.0) <br>
Date of Birth (33-0.0) <br>
UK Biobank Assessment Centre (54-0.0) <br>
Type of accommodation lived in (670-0.0) <br>
Own or rent accommodation lived in (680-0.0) <br>
Length of time at current address (699-0.0) <br>
Number in household (709-0.0) <br>
Number of vehicles in household (728-0.0) <br>
Home coordinates East-West (nearest km) (20074-0.0) <br>
Home coordinates North-South (nearest km) (20075-0.0) <br>

<b> Next step </b>

We recommend using genetic data to remove preliminary pairs which are closely related. This can be done using PLINK!
