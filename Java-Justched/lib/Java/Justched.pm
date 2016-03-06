package Java::Justched;

use strict;
use warnings;
use Linux::Info::SysInfo 0.6;
use Expect 1.21;
use Desktop::Notify 0.03;
use Cwd;
use Config;
use Exporter 'import';
use Carp;
use File::Spec;

=pod

=head1 NAME

Java::Jusched - core functions for justched script

=head1 SYNOPSIS

    use Java::Justched qw(:all);

=head1 DESCRIPTION

Unless you're a developer, you're probably looking for the justched Perl script. Check it's online help.

Otherwise, here you will find information about all subs used by the justched to do what is supposed to do. Those subs are really specific, not generic, but
since you're a developer I understand that you know what you're doing.

=head1 EXPORTS

The tag C<all> will export the subs C<gen_pkg>, C<get_remove_jvm>, C<get_local_jvm>, C<send_notification> and C<check_arch>.

=cut

our @EXPORT_OK =
  (qw(gen_pkg get_remote_jvm get_local_jvm check_arch send_notification));
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

=pod

=head1 FUNCTIONS

=head2 gen_pkg

Generates the DEB package automatically by using the program C<make-jpkg> from the package Java-Package.

The location of the result files is defined in the INI file located at C</etc/default/justched/config.ini> file by default.

Expects as parameter the JVM tarball filename and a instance of L<Config::IniFiles> with the configuration.

Results will be sent to user desktop as well as a notification.

Unfortunately the C<make-jpkg> program expects input from STDIN so this function attempts to use L<Expect> to provide such input. Errors might occur if the C<make-jpkg>
output is modified.

=cut

sub gen_pkg {

    my ( $jvm_tarball, $cfg ) = @_;
    my $exp = Expect->new();
    $exp->raw_pty(1);
    my @params = (
        '--full-name', $cfg->val( 'basic', 'maintainer' ),
        '--email', $cfg->val( 'basic', 'maint_email' ), $jvm_tarball
    );
    $exp->spawn( 'make-jpkg', @params )
      or die "could not execute make-jpkg program: $!";
    $exp->expect(
        10,
        [
            qr/Is\sthis\scorrect\s\[Y\/n\]:/ =>
              sub { my $exp = shift; $exp->send("Y\n"); exp_continue_timeout; }
        ]
    );

    # fetching the generated package name from make-jpkg output
    my @match_info = $exp->expect( 3600, '-re', 'dpkg\s-i\soracle-.*\.deb' );
    $match_info[2] =~ s/^\s+//;
    $match_info[2] =~ s/\s+$//;

    #dpkg -i oracle-java8-jre_8u73_amd64.deb
    my $deb_pkg = ( split( /\s/, $match_info[2] ) )[2];
    # one hour waiting for script termination should be more than enough
    $exp->expect( 3600, 'Removing temporary directory: done' );
    $exp->soft_close();

    if ( defined($deb_pkg) ) {
        my $loc = File::Spec->catfile( getcwd(), $deb_pkg );
        send_notification(
            'Java Runtime Environment (JRE) update available',
            "Check out DEB file $loc for installing"
        );
        unlink $jvm_tarball or warn "Could not remove $jvm_tarball: $!";
        return 1;
    }
    else {
        send_notification(
            'Java Runtime Environment (JRE) update failed!',
"Please execute justched program manually in verbose mode for more details. The tarball $jvm_tarball is still available for package manual creation with make-jpkg."
        );
        return 0;
    }

}

=head2 send_notification

Sends a message to the end-user desktop session by using L<Desktop::Notify>.

Expects as parameter two strings: the summary and body messages.

=cut

sub send_notification {

    my ( $summary, $body ) = @_;

    my $notify = Desktop::Notify->new(
        app_icon =>
          File::Spec->catfile( 'usr', 'share', 'pixmaps', 'sun_java.png' ),
        app_name => 'justched'
    );
    my $notification = $notify->create(
        summary => $summary,
        body    => $body,
        timeout => 5000
    );
    $notification->show();
    $notification->close();

}

=head2 get_remote_jvm

Checks remotely the lastest JVM available for download for Linux (32 and 64 bits).

Expects as parameter a L<WWW::Mechanize> instance and the URL to check the JVM downloads.

Returns a hash reference with the keys C<version> and C<update> with their respective values recovered.

=cut

sub get_remote_jvm {

    my ( $mech, $url ) = @_;
    $mech->get($url);
    my $first = scalar( $mech->find('h4') );

    my $info;
    foreach my $row ( $first->content_list ) {
        $row =~ s/^\s+//;
        if ( $row =~ /^Version/ ) {
            $row =~ s/\s+$//;
            $info = $row;
            last;
        }
    }

    #Version 8 Update 73
    my @parts = split( /\s/, $info );
    my %info = ( version => $parts[1], update => $parts[3] );

    #validations
    foreach my $key (qw(version update)) {

        unless ( exists( $info{$key} ) and ( defined( $info{$key} ) ) ) {
            warn "Missing information about $key, please check HTML from $url";
            return undef;
        }

    }

    return \%info;

}

=head2 get_local_jvm

Recovers information from the local installed JVM (if available).

Returns a hash reference with the keys C<version>, C<platform>, C<jvm_vendor> and C<update>.

JVM availability is checked by issuing a C<which> program in the shell. If available, a custom Java class will
be executed and information from the JVM will be provided to STDOUT, which output will be read and parsed. The output would
look like this:

    alceu@foobar:~$ java JvmDetails 
    1.8.0_73
    64
    Oracle Corporation

In respective order, the JVM version and update, the platform the JVM was compiled for and finally the JVM provider.

This Java class is expected to be in the same location as the C<justched> script. The source code of it (not impressive by any means)
is also available, if you're especially paranoic.

If you're just a bit paranoic, the class SHA256sum output follows below:

    146a512f89f6025b92cc0ad7146479d33a2f03f5ed426d40c805d81ebdf7ad28b2067857e9bbe4dd8efefd70172535024a464a47702f323228116275eed65a88  JvmDetails.class

If you're not happy B<yet>, delete the JvmDetails.class file and compile it again yourself!

=cut

sub get_local_jvm {

    my $class_path = shift || $Config{sitebin};
    my $jvm = `which java`;
    chomp($jvm);
    if ( defined($jvm) ) {
        my $cmd             = "$jvm -classpath $class_path JvmDetails";
        my $details         = `$cmd`;
        my @parts           = split( /\n/, $details );
        my @version_numbers = split( /\./, $parts[0] );
        my %details         = (
            version    => $version_numbers[1],
            update     => ( split( '_', $version_numbers[2] ) )[1],
            platform   => $parts[1],
            jvm_vendor => $parts[2]
        );
        return \%details;

    }
    else {

        return undef;

    }

}

=head2 check_arch

Checks if the JVM available platform is correct compared to the OS (32 or 64 bits).

Expects as parameter a hash reference with information about the local JVM installed.

Returns the corresponding integer 32 or 64 depending on the system platform.

If there is a misconfiguration (like having a 32 bits JVM installed in a 64 system) the function
will print a warning in STDERR with C<warn>.

=cut

sub check_arch {
    my $local_jvm = shift;

    my $linux_info = Linux::Info::SysInfo->new();
    my $arch       = $linux_info->get_proc_arch;

    if ( defined($local_jvm) ) {
        if ( $local_jvm->{platform} != $arch ) {
            warn 'local JVM is '
              . $local_jvm->{platform}
              . " but the processor architecture is $arch";
        }

        return $local_jvm->{platform};
    }
    else {
        return $arch;
    }

}

=pod

=head1 SEE ALSO

=over

=item *

L<Linux::Info::SysInfo>

=item *

L<Expect>

=item *

L<Desktop::Notify>

=back

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
