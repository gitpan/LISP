package LISP::Lambda;

use strict;
use warnings;
require Exporter;

our @ISA = qw(LISP Exporter);
our $VERSION = '0.01';

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use LIST ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	&apply
	&mapcar
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);

# Preloaded methods go here.

sub new {
 my $proto = shift;
 my $class = ref($proto) || $proto;
 bless shift, $class;
}

sub mapcar {
 my $code = shift;
 my @lists = (@_);
 my @car_list;
 my @rlist;
 {
  my $done=1;
  for my $list (@lists) {
   my $elem = $list->pop;
   push @car_list, $elem;
   $done = 0 unless $list->nilp;
  }
  push @rlist, $code->(@car_list);
  @car_list=();
  last if $done;
  redo;
 }
 return LISP->new(\@rlist);
}

sub apply {
 my $code = shift;
 my $list = shift;
 $code->(@{$list->sub_nodes});
}


1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

LISP::Lambda - Perl extension for implementing Lisp Lambda expressions

=head1 SYNOPSIS

  use LISP::Lambda;

  my $lambda = LISP::Lambda->new(\&sub);

  $lambda->mapcar(@lists)
  $lambda->apply($list);

=head1 DESCRIPTION

Lambda expressions are Lisp's version of anonymous subroutines, and may be
blessed into this package so that you can use them or the provided 'meta-methods'
in an object oriented way. If you want to want to use them as regular
functions, you may export them. Any reference to lists here refers to
linked lists ala Lisp, and not to perl lists/arrays.

=head2 Methods

	mapcar(FUNCTION, LISTS)
		mapcar applies the FUNCTION to the list formed by the first
		element of each list, then to the second, etc., up to the
		length of the shortest list, and returns a list of the results.

		$list = LISP->new([[a],[b],[c],[d]]); # ((a) (b) (c) (d))
		$car  = $list->can('car');
		$cars = $car->mapcar($list);
		print   $cars->string;                # Prints (a b c d);

		$list1  = LISP->new([qw(1 2 3)]]);
		$list2  = LISP->new([qw(4 5 6)]]);
		$lister = $list1->can('list');
		$list3  = mapcar($lister, $list1, $list2);
		print $list3->string       # Prints ((1 4) (2 5) (3 6))
		

	apply(FUNCTION, LIST)
		apply returns the result of executing FUNCTION using the subnodes of
		LIST as arguments. 

		$list      = LISP->new([qw(1 2 3)]);
		$totaller  = sub { my $total=0; $total += $_ for @_; $total };
		print apply($totaller, $list);   # Prints 6

		$inc = LISP->new(sub { map {$_ + 1} @_ });
		my @ary = $inc->apply($list);
		print "@ary";     # Prints 2 3 4

=head2 EXPORT

	:all
		 exports methods mapcar and apply, and each may be exported individually.

=head1 AUTHOR

Douglas Wilson, dwilson@gtemail.net

=head1 SEE ALSO

perl(1).

=cut
