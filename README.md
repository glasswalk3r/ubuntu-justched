# ubuntu-justched
A Perl script to update Java Runtime Environment for Ubuntu LTS.

This program will download the tarball of JRE and generate a DEB package for it automatically. It is intended to provide an easier
way to update Oracle Java Runtime Environment on Ubuntu desktops.

The program should be scheduled (or executed at each logon) so the end user can receive a notification of a new JRE available for update, 
just like on Microsoft Windows jusched.exe program... well, almost. The update is NOT executed, only the package is generated.

