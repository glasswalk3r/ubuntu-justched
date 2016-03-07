# ubuntu-justched
A Perl script to update Java Runtime Environment for Ubuntu LTS.

This program will download the tarball of JRE and generate a DEB package for it automatically. It is intended to provide an easier
way to update Oracle Java Runtime Environment on Ubuntu desktops.

The program should be scheduled (or executed at each logon) so the end user can receive a notification of a new JRE available for update, 
just like on Microsoft Windows jusched.exe program... well, almost. The update is NOT executed, only the package is generated.

# Rationale

Java Runtime Update on non-RPM Linux based distributions is not fun.

For Debian-based distributions, in a long past there was a DEB package available in the official repositories until that was forbidden
by the company that holds the rights of Java programming language. About that time you would need to accept a license agreement in their
website before being able to download a tarball, which forces you to do a lot of manual configuration to get it working.

Then the good folks of [WebUpd8](http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html) created a way to execute the
same thing (including getting the response of acceptance of the agreement and redirecting it to /dev/null), getting the tarball and creating
the respective DEB packages to install it. They even have their own PPA repository that you could add to your system.

That worked well for me for years. Recently, unfortunately I had an issue with a Brazilian home banking website that uses Java applets for
their authentication process... my local JVM was outdated. I checked with apt-get and everything was fine. WebUpd8 repository was outdated
(I'm not complaining, it is just a fact). I really don't thing those good guys are responsible for getting my computer updated.

Besides, I don't need the JDK in everywhere, in most cases the JVM is good enough.

I started copying their (WebUpd8) packages definitions and hacking it to get only the JVM related packages creation. I started developing also a
crawler in Perl to download the JVM, getting information about and generating the respective Debian package files automatically by using 
Template Toolkit.

Then I discovered (by accident) that Debian already has this great program called [Java-Package](https://wiki.debian.org/JavaPackage), which basically
does all the hard lifting for me to "debianize" the JVM tarball.

The result of this work is the Perl program justched (yes, it started with a bad type from the jusched.exe program available on Windows) but I think
it's a fun name (the pun was unintented). Hopefully, you can get the JVM DEB package created with minimal effort for your own computer (or even an
entire network of Ubuntu desktops). Running it on a desktop will even send you a notification telling you that a new version of Java is available, so
you might want to add it to your user's crontab or to execute at each logon.

justched was created for Ubuntu LTS (currently Trusty) but could work on other different Debian-based Linux distributions, but I'm unable to validate
(or maintain) that.

## Why a DEB instead of <your-own-solution>

Using a package to install and maintain software is the main reason to have a package management after all. It is easier and organized way to do that.
There is people out there that think it's fun to do everything from a tarball, but I don't think like that.

# Known problems

The package libdesktop-notify-perl on Ubuntu Trusty is outdated. Desktop::Notify 0.05 has changes in it's API and I found out that I couldn't get a
icon being show in notifications. Hopefully this will be changed in the future.
