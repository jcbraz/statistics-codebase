/* Define the library reference */
libname amazon 'C:\Users\bbsstudent\Desktop\amazon';

/* Import data from CSV to SAS dataset */
proc import datafile='C:\Users\bbsstudent\Desktop\amazon\amazon_users.csv'
            out=amazon.amazon_users
            dbms=csv
            replace;
run;

/* Perform clustering analysis using the imported dataset */
proc cluster data=amazon.amazon_users method=ward;
   var your_var1-your_var8; /* Specify your actual variable names */
run;
var d10_1-d10_8;
run;
proc tree; run;


proc cluster data=amazon.amazon_users method=ward outtree=amazon.tree noprint;
id id;
var d10_1-d10_8;
run;
proc tree data=amazon.tree ncl=3 out=amazon.cluster noprint; 
id id;
run;

proc sort data=amazon.amazon_users; by id; run;
proc sort data=amazon.cluster; by id; run;
data amazon.amazon_users_1; merge amazon.amazon_users amazon.cluster;
by id;
run;

proc freq data=amazon.amazon_users_1;
table sex*cluster / expected chisq;
run;

proc means data=amazon.amazon_users_1 ;
var d10_1-d10_8;
*class cluster;
run;

data amazon.amazon_users_fake; set amazon.amazon_users_1;
cluster=4;
run;

data amazon.amazon_users_append; set amazon.amazon_users_1 amazon.amazon_users_fake;
run;

*description of cluster1;
proc ttest data=amazon.amazon_users_append;
where cluster=1 or cluster=4;
var d10_1-d10_8;
class cluster;
run;

*description of cluster3;
proc ttest data=amazon.amazon_users_append;
where cluster=3 or cluster=4;
var d10_1-d10_8;
class cluster;
run;

proc corr data=amazon.amazon_users_1;
var d10_1-d10_8;
run;

*2nd part;
proc princomp data=amazon.amazon_users;
var d10_1-d10_8;
run;
proc princomp data=amazon.amazon_users out=amazon.coord;
var d10_1-d10_8;
run;

data amazon.unit_1_84; set amazon.coord;
if id=1 or id =84;
run;

data amazon.coord_1; set amazon.coord;
avgi=mean(of d10_1-d10_8);
run;
proc corr data=amazon.coord_1;
var avgi prin1;run;


data amazon.sz_amazon_users; set amazon.amazon_users;
avgi=mean(of d10_1-d10_8);
mini=min(of d10_1-d10_8);
maxi=max(of d10_1-d10_8);
new_1=.;
if d10_1>avgi then new_1=(d10_1-avgi)/(maxi-avgi);
if d10_1<avgi then new_1=(d10_1-avgi)/(avgi-mini);
if d10_1=avgi then new_1=0;
if d10_1=. then new_1=0;
run;

data amazon.sz_amazon_users; set amazon.amazon_users;
avgi=mean(of d10_1-d10_8);
mini=min(of d10_1-d10_8);
maxi=max(of d10_1-d10_8);
array a1 d10_1-d10_8;
array a2 new_1-new_8;
do over a2;
if a1>avgi then a2=(a1-avgi)/(maxi-avgi);
if a1<avgi then a2=(a1-avgi)/(avgi-mini);
if a1=avgi then a2=0;
if a1=. then a2=0;
end;
label new_1='leisure';
label new_2='schemas';
label new_3='new_fans';
label new_4='usual_friends';
label new_5='work';
label new_6='show';
label new_7='suffer';
label new_8='time';
run;

proc means data=amazon.sz_amazon_users min max mean;
var d10_: new_: ; run;


proc princomp data=amazon.sz_amazon_users out=amazon.sz_amazon_users_1;
var new_:; 
run;
