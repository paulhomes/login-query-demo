/*
Bulk loads a specified number of users and logins into SAS metadata using
the SAS MDU macros for the purpose of load testing SAS metadata server.

Part of a demo to show simple Login object queries are much slower when
passwords are present in metadata, even when the password is not
requested in the query template.

This program is used to load metadata to set up the demo environment.

See logins.sas for a Login query demo (fast or slow).
See persons.sas for a Person query demo (always fast).
See unload-metadata.sas to remove the demo users.

Set USER_COUNT to the number of users to create (2 Login objects
are created for each user).  The difference should be very clear
even with only 500 users.

Set DEMOPW to blank for fast Login queries and anything else for slow queries.

Set SASADMPW to your sasadm@saspw password (I have it set in an autoexec).

--
Paul Homes
*/

%let USER_COUNT=500;
%let DEMOPW=;
%*let SASADMPW=thesecretpassword;

options
  metaserver=localhost
  metaport=8561
  metaprotocol=bridge
  metarepository="Foundation"
  metauser="sasadm@saspw"
  metapass="&SASADMPW"
  ;

filename reqxml "load-metadata-request.xml" lrecl=32767 encoding="utf-8";
filename respxml "load-metadata-response.xml" lrecl=32767 encoding="utf-8";

%* create sync libs under work;
%let basedir=%sysfunc(pathname(work));
libname master "%sysfunc(dcreate(master,&basedir))";
libname target "%sysfunc(dcreate(target,&basedir))";
libname change "%sysfunc(dcreate(change,&basedir))";

%mduimpc(libref=master,maketable=0);         

data &persontbla;
%definepersoncols;
do userIndex=1 to &USER_COUNT;
   keyid=cats('U',put(userIndex,z7.));
   name=catx(' ','DemoUser',keyid);
   description='Demo user for load testing';
   title='';
   output;
end;
drop userIndex;
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
infile cards dsd missover;
input keyid authDomName;
cards;
A001,DefaultAuth
A002,DBAuth
;
run;

data &logintbla;
%definelogincols; 
do userIndex=1 to &USER_COUNT;
   keyid=cats('U',put(userIndex,z7.));
   userid=lowcase(keyid);
   password="&DEMOPW";
   authdomkeyid='A001';
   output;
   userid=cats('d',put(userIndex,z7.));
   password="&DEMOPW";
   authdomkeyid='A002';
   output;
end;
drop userIndex;
run;


%mduextr(libref=target);
%mducmp(master=master, target=target, change=change, externonly=1);
%mduchgv(change=change, target=target, temp=work, errorsds=work.mduchgverrors);

proc print data=work.mduchgverrors;
run;

%macro doload;
%if (&MDUCHGV_ERRORS ne 0) %then %do;
    %put ERROR: Bulk load of demo users aborted due to validation errors;
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

%doload;
