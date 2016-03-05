package Java::Justched::Config;

use warnings;
use strict;

=pod

=head1 NAME

Java::Jusched::Config - Pod about justched configuration file

=head1 SYNOPSIS

    # somewhere in your local file system
    [basic]
    maintainer = John Doe
    maint_email = john.doe@foobar.org
    url = http://www.java.com/download/manual.jsp
    download = /tmp

=head1 DESCRIPTION

This module is about documentation over the configuration file used by the justched program.

This configuration file is expected to be in /etc/default/justched, but it can be overrided by the respective command line option
of justched program. Check justched online help for more details.

The configuration file is a INI file with a section named 'basic'. This is expected.

Also, the following properties are expected:

=over

=item *

maintainer: a string with the name of the package maintainer (probably you!)

=item *

maint_email: the maintainer e-mail address.

=item *

url: the URL used to download the Oracle's JRE url. You probably don't want to change that unless are expecting to update the webcrawler of justched as well.

=item *

download: the directory that will be used as working directory. The download tarball and DEB package will be stored there.

=back

The C<maintainer> and C<maint_email> properties should be edited because such information will be stored in the DEB package itself.

=head1 EXPORTS

Nothing: this is just Pod.

=head1 SEE ALSO

L<Config::IniFiles>: the Perl module used to process the INI file.

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 of Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

This file is part of Ubuntu Justched project.

Ubuntu Justched is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Ubuntu Justched is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Linux Info.  If not, see <http://www.gnu.org/licenses/>.

=cut

1;
