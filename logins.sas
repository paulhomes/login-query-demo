/*
Demo to show a simple Login object query can be much slower when passwords
are present in metadata, even when the password is not requested in the
query template.
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

filename _omireq "logins-request.xml" lrecl=32767 encoding="utf-8";
filename _omires "logins-response.xml" lrecl=32767 encoding="utf-8";

data _null_;
file _omireq;
put '<GetMetadataObjects>';
put '  <Reposid>$METAREPOSITORY</Reposid>';
put '  <Type>Login</Type>';
put '  <Objects/>';
put '  <NS>SAS</NS>';
%* OMI_NOFORMAT (67108864) + OMI_GET_METADATA(256) + OMI_TEMPLATE(4)
put '  <Flags>67109124</Flags>';
put '  <Options>';
put '    <Templates>';
put '      <Login Id="" Name="" />';
put '    </Templates>';
put '  </Options>';
put '</GetMetadataObjects>';
run;

proc metadata in=_omireq out=_omires header=full verbose;
run;

filename _omires;
filename _omireq;
