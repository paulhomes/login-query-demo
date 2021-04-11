# login-query-demo

# Intro

This is a small demo to show performance differences for SAS Metadata Server Login object queries.
They are very fast when there are very few passwords stored in metadata. They become much slower
when there are large numbers of passwords stored in metadata, even when the metadata query does
not request any passwords be returned.

It makes sense that login queries will be slower when there are lots of passwords present
in metadata as there will be crypto operations associated with those passwords.
I was surprised to see a penalty when the query does not request passwords be returned.

:exclamation: WARNING: DO NOT RUN THIS CODE IN A PRODUCTION OR OTHERWISE REAL-USE SAS ENVIRONMENT.
You should only run it in demo, development or sandpit environments.
It is used to demonstrate loading and unloading large numbers of users and logins
and removing those added users/logins. It uses the SAS %MDU macros so if you run it in an
environment that is sync-ing real users with Active Directory then those users will get
removed from SAS metadata!

The demo consists of the following SAS programs:
* load-metadata.sas: bulk-loads a specified number of demo users and logins
* persons.sas: a Person query demo (always fast)
* logins.sas: a Login query demo (fast or slow)
* unload-metadata.sas: remove all demo users that were added by load-metadata.sas

# Preparation

Each program connects to a SAS metadata server on localhost using the sasadm@saspw
account. If you are not running the code on the metadata server then edit each program
and change metaserver=localhost (or better still move the repeated meta options into
an autoexec.sas). To specify the password for the sasadm@saspw account uncomment
the following line in each program and specify the password (or add it into an
autoexec.sas). 

:information_source: NOTE: forcing these manual changes is a safety feature and
means running this code unchanged in a production SAS environment will fail and
make no changes to SAS metadata.

You can specify the password in plain text or SAS PWENCODEd format:

````%let SASADMPW=thesecretpassword;````

... or:

````%let SASADMPW={sas002}theencodedversion;````

# Demo

To work through the demo:
  1. Edit load-metadata.sas:
     * Set USER_COUNT to the number of users to create (2 Login objects
       are created for each user).  The difference should be very clear
       even with only 500 users.
     * Leave DEMOPW as blank so the logins are created with no passwords.
  2. Run load-metadata.sas to load the users and confirm they were added
     in SAS Management Console.
  3. Run persons.sas - it should be very fast - less than a second for me
  4. Run logins.sas - it should also be very fast - less than a second for me
  5. Run unload-metadata.sas to remove all the demo users and logins
     and confirm they were removed in SAS Management Console.
  6. Edit load-metadata.sas:
     * Set DEMOPW to non-blank (e.g. test) so the logins are created
       with passwords.
  7. Run load-metadata.sas to load the users and confirm they were added
     in SAS Management Console.
  8. Run persons.sas - it should still be very fast - less than a second for me
  9. Run logins.sas - it should be much slower - about 12 seconds for me
 10. Run unload-metadata.sas to remove all the demo users and logins
     and confirm they were removed in SAS Management Console.

That ends the demo.
