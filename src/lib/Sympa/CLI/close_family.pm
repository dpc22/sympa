# -*- indent-tabs-mode: nil; -*-
# vim:ft=perl:et:sw=4

# Sympa - SYsteme de Multi-Postage Automatique
#
# Copyright 2021 The Sympa Community. See the
# AUTHORS.md file at the top-level directory of this distribution and at
# <https://github.com/sympa-community/sympa.git>.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

package Sympa::CLI::close_family;

use strict;
use warnings;

use Sympa;
use Conf;
use Sympa::Family;
use Sympa::List;
use Sympa::Spindle::ProcessRequest;

use parent qw(Sympa::CLI);

use constant _options => qw();
use constant _args    => qw(family);

sub _run {
    my $class   = shift;
    my $options = shift;
    my $family  = shift;

    my $lists = Sympa::List::get_lists($family);
    my @impossible_close;
    my @close_ok;

    foreach my $list (@{$lists || []}) {
        my $listname = $list->{'name'};

        my $spindle = Sympa::Spindle::ProcessRequest->new(
            context          => $family->{'domain'},
            action           => 'close_list',
            current_list     => $list,
            sender           => Sympa::get_address($family, 'listmaster'),
            scenario_context => {skip => 1},
        );
        unless ($spindle and $spindle->spin and $class->_report($spindle)) {
            push @impossible_close, $listname;
            next;
        }
        push(@close_ok, $listname);
    }

    if (@impossible_close) {
        print "\nImpossible list closure for : \n  "
            . join(", ", @impossible_close) . "\n";
    }
    if (@close_ok) {
        print "\nThese lists are closed : \n  "
            . join(", ", @close_ok) . "\n";
    }

    exit 0;
}

1;
__END__

=encoding utf-8

=head1 NAME

sympa-close_family - Close lists of the family

=head1 SYNOPSIS

C<sympa.pl close_family> I<family>C<@@>I<domain>

=head1 DESCRIPTION

Close lists of specified family.

=cut
