package LISP;

use strict;
use warnings;

use LISP::List qw(listp nilp);
use LISP::Lambda qw(mapcar apply);

require Exporter;

our @ISA = qw(Exporter);

use constant CAR => 0;
use constant CDR => 1;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use LIST ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	&cons
	&list
	&listp
	&nilp
	&mapcar
	&apply
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);

our $VERSION = '0.01';


# Preloaded methods go here.

# Construct a new list from an array ref
sub new {
 my $proto = shift;
 my $class = ref($proto) || $proto;

 my $arg = $_[0];
 return LISP::List->new unless $arg;
 my $ref = ref($arg);
 return LISP::List->new(@_) if $ref eq 'ARRAY';
 return LISP::Lambda->new(@_) if $ref eq 'CODE';
 return LISP::Symbol->new(@_) if $ref eq 'SCALAR';

 bless {}, $class;
}

sub cons {
 my $self = shift if @_ > 2;
 my $node = LISP->new([]);
 $node->rplaca($_[0]);
 $node->rplacd($_[1]);
 return $node;
}

sub list {
 LISP->new([@_]);
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

LISP - Perl extension for blah blah blah

=head1 SYNOPSIS

  use LISP;

  my $list = LISP->new(\@array);
  my $lambda = LISP->new(\&function);

  my $cons_cell = LISP->cons($car, $cdr);
  my $list = LISP::list(@array);

=head1 DESCRIPTION

Implements Lisp-like linked-lists and functions/methods.

=head2 Methods
    new ([ARRAYREF|CODEREF])
        If given an array reference, returns a linked list with every array reference
        within the given array reference also expanded into another list.

        If given a subroutine reference, blesses the reference into LISP::Lamba and
        returns the reference.

    cons (CAR, CDR)
        Creates a new cons-cell and returns it.
        
    list (ARRAY)
        Like the new method, but called with an array as an argument instead of an
        array reference, and is more meant to be called as a function rather than a
        method (This could change).

=head2 EXPORT

None by default.

        :all
            This will export cons and list from this package, listp and nilp from
            LISP::List, and mapcar and apply from LISP::Lambda.


=head1 AUTHOR

Douglas Wilson, dwilson@gtemail.net

=head1 SEE ALSO

LISP::List, LISP::Lambda, perl(1).

=cut
