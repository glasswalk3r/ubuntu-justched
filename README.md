# ubuntu-justched
A Perl script to update Java Runtime Environment for Ubuntu LTS.

This program will download the tarball of JRE and generate a DEB package for it automatically. It is intended to provide an easier
way to update Oracle Java Runtime Environment on Ubuntu desktops.

The program should be scheduled (or executed at each logon) so the end user can receive a notification of a new JRE available for update, 
just like on Microsoft Windows jusched.exe program... well, almost. The update is NOT executed, only the package is generated.

## Rationale

Java Runtime Update on non-RPM Linux based distributions is not fun.

For Debian-based distributions, in a long past there was a DEB package available in the official repositories until that was forbidden
by the company that holds the rights of Java programming language. About that time you would need to accept a license agreement in their
website before being able to download a tarball, which forces you to do a lot of manual configuration to get it working.

Then the good folks of [WebUpd8](http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html) created a way to execute the
same thing (including getting the response of acceptance of the agreement and redirecting it to /dev/null), getting the tarball and creating
the respective DEB packages to install it. They even have their own PPA repository that you could add to your system.

That worked well for me for years. Recently, unfortunately I had an issue with a Brazilian home banking website that uses Java applets for
their authentication process... my local JVM was outdated. I checked with apt-get and everything was fine. WebUpd8 repository was outdated
(I'm not complaining, it is just a fact). I really don't think those good guys are responsible for getting my computer updated.

Besides, I don't need the JDK everywhere, in most cases the JVM is good enough.

I started copying their (WebUpd8) packages definitions and hacking it to get only the JVM related packages creation, then developing a web
crawler in Perl to download the JVM, getting information it about and generating the respective Debian package files automatically by using 
Template Toolkit.

Then I discovered (by accident) that Debian already has this great program called [Java-Package](https://wiki.debian.org/JavaPackage), which basically
does all the hard lifting for me to "debianize" the JVM tarball.

The result of this work is the Perl program justched (yes, it started with a typo from the jusched.exe program available on Windows) but I think
it's a fun name (the pun was unintented). Hopefully, you can get the JVM DEB package created with minimal effort for your own computer (or even an
entire network of Ubuntu desktops). Running it on a desktop will even send you a notification telling you that a new version of Java is available, so
you might want to add it to your user's crontab or to execute at each logon.

justched was created for Ubuntu LTS (currently Trusty). It could work on other different Debian-based Linux distributions, but I'm unable to validate (or maintain) that.

### Why a DEB instead of `<your-preferred-solution>`?

Using a package to install and maintain software is the main reason to have a package management after all. It is easier and organized way to do that.
There is people out there that think it's fun to do everything from a tarball, but I don't agree with them.

## How to configurate it?

First you need to add the project PPA. justched is not available on CPAN. Open a terminal and enter:

```
sudo add-apt-repository ppa:glasswalk3r-yahoo/ubuntu-justched
sudo apt-get update
sudo apt-get install java-justched
```

There is also a dependency of another package liblinux-info-perl. PPA configuration explicit declares that, so it should solve automatically. If not, you
might need to add it's related PPA as well:

```
sudo add-apt-repository ppa:glasswalk3r-yahoo/linux-info
sudo apt-get update
sudo apt-get install java-justched
```

This is the minimum information. You can check more details on [Launchpad](https://help.launchpad.net/Packaging/PPA/InstallingSoftware) documentation about it.

Read the online help of justched program with a

```
justched -h
```

And edit the configuration file.

Now you may want to add the program to your session startup. In most cases invoking `gnome-session-properties` from Unity will do it. You can see a lot more of 
options to enable it in http://askubuntu.com/questions/30931/how-do-i-make-a-program-auto-start-every-time-i-log-in.

justched will now look for newer version of JVM in your Ubuntu. If something newer is found, it will be downloaded and converted automatically to a DEB file. The
location of the DEB file will be defined by justched configuration file and you will have to install it manually. A desktop notification will be sent to you when this
is done.

In future versions I may add a GUI to help users to do that easily.

## Known problems

The package libdesktop-notify-perl on Ubuntu Trusty is outdated. [Desktop::Notify](http://search.cpan.org/search?query=Desktop%3A%3ANotify&mode=all) 0.05 has 
changes in it's API and I found out that I couldn't get a icon being show in notifications. Hopefully this will be changed in the future.

The Java-Package program expects input from the end-user to accept default values. justched use Expect to handle that, so if the prompt changes, justched
will fail to do the right thing.

As any other web crawler, justched might also fail if the Java website changes their HTML. This may include a different way to request your acceptance of 
Java license (maybe they will also ask us to dance the [Macarena](https://www.youtube.com/watch?v=XiBYM6g8Tck) to do it).

