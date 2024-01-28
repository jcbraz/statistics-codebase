/* Define the library reference */
libname amazon 'C:\Users\bbsstudent\Desktop\SAS_Project';

/* Import data from CSV to SAS dataset */
proc import datafile='C:\Users\bbsstudent\Desktop\SAS_Project\amazon_survey.csv'
            out=amazon.amazon_users
            dbms=csv
            replace;
run;

/* Plot tree with single linkage method */
proc cluster data=amazon.amazon_users method=single;
var d10_1-d10_9;
run;
proc tree; run;

/* Plot tree with ward method */
proc cluster data=amazon.amazon_users method=ward;
var d10_1-d10_9;
run;
proc tree; run;

/* create tree table in 'amazon' library */
proc cluster data=amazon.amazon_users method=ward outtree=amazon.tree noprint;
id id;
var d10_1-d10_9;
run;

/* create cluster table based on tree table --> we decided to create for 4 clusters*/
proc tree data=amazon.tree ncl=4 out=amazon.cluster noprint; 
id id;
run;

/* merge the cluster table with the dataset --> adding column 'cluster' to the dataset*/
proc sort data=amazon.amazon_users; by id; run;
proc sort data=amazon.cluster; by id; run;
data amazon.clustered_users; merge amazon.amazon_users amazon.cluster;
by id;
run;

proc freq data=amazon.clustered_users;
table gender*cluster / expected chisq;
run;

proc freq data=amazon.clustered_users;
table age*cluster / expected chisq;
run;

proc freq data=amazon.clustered_users;
table occupation*cluster / expected chisq;
run;

proc freq data=amazon.clustered_users;
table origin*cluster / expected chisq;
run;

proc freq data=amazon.clustered_users;
table yearly_income*cluster / expected chisq;
run;

*means for every variable used for clustering;
proc means data=amazon.clustered_users ;
var d10_1-d10_9;
run;

data amazon.users_fake; set amazon.clustered_users;
cluster=5;
run;

data amazon.amazon_append; set amazon.clustered_users amazon.users_fake;
run;

