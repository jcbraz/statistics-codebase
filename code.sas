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
proc tree data=amazon.tree ncl=3 out=amazon.cluster noprint; 
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
cluster=4;
run;

data amazon.amazon_append; set amazon.clustered_users amazon.users_fake;
run;

*description of cluster 1;
proc ttest data=amazon.amazon_append;
where cluster=1 or cluster=4;
var d10_1-d10_9;
class cluster;
run;

*description of cluster 2;
proc ttest data=amazon.amazon_append;
where cluster=2 or cluster=4;
var d10_1-d10_9;
class cluster;
run;

proc corr data=amazon.clustered_users;
var d10_1-d10_9;
run;

*principal component analysis;
proc princomp data=amazon.amazon_users;
var d10_1-d10_9;
run;

*table with new principal components;
proc princomp data=amazon.amazon_users out=amazon.coord;
var d10_1-d10_9;
run;

*add a new column called avgi;
data amazon.coord_1; set amazon.coord;
avgi=mean(of d10_1-d10_9);
run;

*correlation between avgi and first principal component;
proc corr data=amazon.coord_1;
var avgi prin1;run;

*create new table with columns 'avgi' 'mini' 'maxi' 'new_1';
data amazon.sz_users; set amazon.amazon_users;
avgi=mean(of d10_1-d10_9);
mini=min(of d10_1-d10_9);
maxi=max(of d10_1-d10_9);
new_1=.;
if d10_1>avgi then new_1=(d10_1-avgi)/(maxi-avgi);
if d10_1<avgi then new_1=(d10_1-avgi)/(avgi-mini);
if d10_1=avgi then new_1=0;
if d10_1=. then new_1=0;
run;

*macro for doing the same without repeating;
data amazon.sz_unico; set amazon.amazon_users;
avgi=mean(of d10_1-d10_9);
mini=min(of d10_1-d10_9);
maxi=max(of d10_1-d10_9);
array a1 d10_1-d10_9;
array a2 new_1-new_9;
do over a2;
if a1>avgi then a2=(a1-avgi)/(maxi-avgi);
if a1<avgi then a2=(a1-avgi)/(avgi-mini);
if a1=avgi then a2=0;
if a1=. then a2=0;
end;
label d10_1='essential_goods';
label d10_2='luxury_goods';
label d10_3='house_products';
label d10_4='technology_products';
label d10_5='clothing_products';
label d10_6='offers';
label d10_7='avoid_going_outside';
label d10_8='price_comparison';
label d10_9='product_reviews';
label new_1='essential_goods';
label new_2='luxury_goods';
label new_3='house_products';
label new_4='technology_products';
label new_5='clothing_products';
label new_6='offers';
label new_7='avoid_going_outside';
label new_8='price_comparison';
label new_9='product_reviews';
run;

/*check difference between old and new variables*/
proc means data=amazon.sz_unico min max mean;
var d10_: new_: ; run;

/*principal component analysis with new variables*/
proc princomp data=amazon.sz_unico out=amazon.sz_unico_1;
var new_:; 
run;

/*cluster process with the first 3 principal components*/
proc cluster data=amazon.sz_unico_1 method=ward outtree=amazon.tree; 
var prin1-prin3;*selected using eigenvalues structure analysis;
id id;
run;

/*create dendrogram*/
proc template ;
define statgraph dendrogram; 
begingraph;
layout overlay;
dendrogram nodeID=_name_ parentID=_parent_ clusterheight=_height_;
    endlayout;
  endgraph;
end; run;

proc sgrender data=amazon.tree template=dendrogram; run;

/*create cluster table*/
proc tree data=amazon.tree ncl=5 out=amazon.cluster_1 noprint;
id id;
run;


/*create table merging dataset with cluster table*/
proc sort data=amazon.sz_unico_1; by id; run;
proc sort data=amazon.cluster_1; by id; run;
data amazon.new_merged_table; merge amazon.sz_unico_1 amazon.cluster_1; by id;
run;