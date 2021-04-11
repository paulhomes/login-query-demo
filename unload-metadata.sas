/*
Bulk unloads all previously loaded demo users and logins.
--
Paul Homes
*/

%*let SASADMPW=thesecretpassword;

options
  metaserver=localhost
  metaport=8561
  metaprotocol=bridge
  metarepository="Foundation"
  metauser="sasadm@saspw"
  metapass="&SASADMPW"
  ;

filename reqxml "unload-metadata-request.xml" lrecl=32767 encoding="utf-8";
filename respxml "unload-metadata-response.xml" lrecl=32767 encoding="utf-8";

%* create sync libs under work;
%let basedir=%sysfunc(pathname(work));
libname master "%sysfunc(dcreate(master,&basedir))";
libname target "%sysfunc(dcreate(target,&basedir))";
libname change "%sysfunc(dcreate(change,&basedir))";

%mduimpc(libref=master,maketable=0);         

data &persontbla;
%definepersoncols;
stop;
run;

data &phonetbla;
%definephonecols;
stop;
run;

data &locationtbla;
%definelocationcols;
stop;
run;

data &emailtbla;
%defineemailcols;
stop;
run;

data &idgrptbla;
%defineidgrpcols;
stop;
run;

data &idgrpmemstbla;
%defineidgrpmemscols;
stop;
run;

data &authdomtbla ;
%defineauthdomcols;
stop;
run;

data &logintbla;
%definelogincols; 
stop;
run;

%mduextr(libref=target);
%mducmp(master=master, target=target, change=change, externonly=1);
%mduchgv(change=change, target=target, temp=work, errorsds=work.mduchgverrors);

proc print data=work.mduchgverrors;
run;

%macro dounload;
%if (&MDUCHGV_ERRORS ne 0) %then %do;
    %put ERROR: Bulk unload of demo users aborted due to validation errors;
    %return;
%end;

%mduchgl(
    change=change, 
    temp=work,
    outrequest=reqxml,
    outresponse=respxml,
    extidtag=DemoTag,
    submit=1
);

%mend;

%dounload;
