/*
Demo to show a simple Person object query is always fast.
This is something to compare with a Login object query.
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

filename _omireq "persons-request.xml" lrecl=32767 encoding="utf-8";
filename _omires "persons-response.xml" lrecl=32767 encoding="utf-8";

data _null_;
file _omireq;
put '<GetMetadataObjects>';
put '  <Reposid>$METAREPOSITORY</Reposid>';
put '  <Type>Person</Type>';
put '  <Objects/>';
put '  <NS>SAS</NS>';
%* OMI_NOFORMAT (67108864) + OMI_GET_METADATA(256) + OMI_TEMPLATE(4)
put '  <Flags>67109124</Flags>';
put '  <Options>';
put '    <Templates>';
put '      <Person Id="" Name="" />';
put '    </Templates>';
put '  </Options>';
put '</GetMetadataObjects>';
run;

proc metadata in=_omireq out=_omires header=full verbose;
run;

filename _omires;
filename _omireq;
