package LISP::List;

use Carp;
use strict;
use warnings;

require Exporter;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use LIST ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	&listp
	&nilp
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);

our $VERSION = '0.01';
our @ISA = qw(LISP Exporter);
our $AUTOLOAD;

use constant CAR => 0;
use constant CDR => 1;

*isa = \&UNIVERSAL::isa;

our $NIL = bless [], 'LISP::List';
$$NIL[CAR] = $NIL;
$$NIL[CDR] = $NIL;

# Preloaded methods go here.

# Construct a new list from an array ref
sub new {
 my $proto = shift;
 my $class = ref($proto) || $proto;
 return bless $NIL, $class unless @_;

 my $list = bless [$NIL, $NIL], $class;
 my $node = $list;
 my $prv_node = bless [$NIL, $NIL], $class;
 for (@{$_[0]}) {
  # Recursively create lists if neccessary
  my $car = ref eq 'ARRAY' && $class->new($_)
         || defined        && $_
         ||                   $NIL;
  $node->rplaca($car);
  # Set cdr of previous node to this node
  $prv_node->rplacd($node);
  $prv_node = $node;
  $node = bless [], $class;
 }
 $prv_node->rplacd($NIL);
 return $list;
}

sub car {
 $_[0][CAR];
}

sub rplaca {
 $_[0][CAR] = $_[1];
}

sub cdr {
 $_[0][CDR];
}

sub rplacd {
 $_[0][CDR] = $_[1];
}

# Returns an array reference to the sub_nodes of lists
sub sub_nodes {
 my @lists = @_;
 my (@nodes, $node);
 for my $list (@lists) {
  push @nodes, $node while listp($list) and !nilp($list) and $node = $list->pop;
 }
 return \@nodes;
}

sub append {
 return $_[0]->new(sub_nodes);
}

sub reverse {
 return $_[0]->new([reverse @{&sub_nodes}]);
}

sub pop {
 my $elem = $_[0]->car;
 $_[0] = $_[0]->cdr;
 return $elem;
}

sub push {
 my $node = $_[0]->cons($_[1], $_[0]);
 $_[0] = $node;
}

sub last {
 my $node = shift;
 my $last = $node;
 $last = $node while listp($node) and !nilp($node) and $node = $node->cdr;
 return $last;
}

sub length {
 my $node = shift;
 my $len = 0;
 $len++ while listp($node) and !nilp($node) and $node = $node->cdr;
 return $len;
}

sub mapcar {
 my $list = shift;
 my $func = shift;
 my @lists = ($list, @_);
 LISP::Lambda::mapcar($func, @lists);
}

sub apply {
 my $list = shift;
 my $code = shift;
 $code->($list->subnodes);
}

sub string {
 my $list = shift;
 return "NIL" if nilp($list);
 my $str = "(";
 while (listp($list) and !nilp($list) and my $elem = $list->pop) {
  $str .= "$elem ", next unless listp($elem);
  $str .= "NIL ", next if nilp($elem);
  $str .= $elem->string.' ';
 }
 $str .= ". $list " unless nilp($list);
 substr($str, -1, 1) = ")";
 return $str;
}

sub listp {
 isa($_[0], 'LISP::List');
}

sub nilp {
 listp($_[0]) and $_[0] eq $LISP::List::NIL;
}

sub AUTOLOAD {
 return if $AUTOLOAD =~ /::DESTROY$/;
 # Autoload cadr, caddr, etc.
 if ($AUTOLOAD =~ /::c([ad]+)([ad])r$/) {
  no strict 'refs';
  my $meth1 = "c$1r";
  my $meth2 = "c$2r";
  *{$AUTOLOAD} = sub { shift->$meth2->$meth1 };
  goto &$AUTOLOAD;
 }
 carp $AUTOLOAD =~ /(.*)::(.*)$/
  ? qq!Couldn't load sub/method "$2" via package "$1"!
  : "Couldn't load subroutine &$AUTOLOAD";
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

LISP::List - Perl extension for implementing linked lists as in Lisp

=head1 SYNOPSIS

  use LISP::List;

  $list = LISP->new([qw(1 2 3)]);

  $car = $list->car;
  $cdr = $list->cdr;

  $caar = $list->cddr;
  $cddr = $list->cddr;
  $cadr = $list->cadr; # etc.

  $list->rplaca($car);
  $list->rplacd($cdr);

  @sub_nodes = $list->sub_nodes;
  $rev_list = $list->reverse;
  $new_list = $list->append(@lists);

  $scalar = $list->pop;
  $list->push($element);
  $last_list   = $list->last;
  $length      = $list->length;
  $is_a_list     = $list->listp;
  $is_empty_list = $list->nilp;

  $new_list = $list->mapcar($code_ref, [@more_lists]);
  $result   = $list->apply($code_ref);

  $string   = $list->string;

=head1 DESCRIPTION

This is an implementation of linked lists, with Lisp-like functionality. 
Any reference to lists here refers to Lisp-like linked lists, while @variables
in perl will be called arrays.


= head2 Explanation
    Here is a brief description of linked lists in Lisp.

    (1 2 3 4) is short hand for:
    (1 . (2 . (3 . (4 . NIL))))
    which graphically represented as:
    .--.--.--.--NIL
    |  |  |  |
    1  2  3  4

    The list 'starts' with the node in the upper-left corner.
    The car of a list node is the element below a node, and the cdr of a
    node is the element to the right of a node. In a 'true' list, the cdr of
    a list is always a list, and the 'last' cdr is NIL, which represents
    the empty list.

    List nodes are also called 'cons' cells. Cons cells do not have to have
    a list (NIL or otherwise) as their cdr. Things referred to as lists below
    do not always refer to a 'true' list necessarily, and may also apply to cons cells.

=head2 Methods

    new (ARRAY_REF)
        Calling LISP::List->new($array_ref), or LISP->new($array_ref) for short,
        will create a new linked list of the elements of $array_ref, with each
        array reference within $array_ref itself becoming a linked list.

    car
        Returns the car of a list.

    cdr 
        Returns the cdr of a list.

    caar, cddr, cadr, etc.
        E.g. cadr returns the car of the cdr of a list, any method matching
        /c[ad][ad]+r/ is autoloaded to return the appropriate chaining of car and cdr.

    sub_nodes
        Returns all of the car's of the top-level nodes of a list in an array.

    reverse
        Returns a copy of the top-level nodes of a list in reverse.

    append (LISTS)
        Copies the top-level nodes of all but the last list and appends all of the
        copies, including the last list, together into a new list.

    pop
        Returns the car of a list and sets the list to the cdr of itself.

    push (ELEMENT)
        Creates a new cons cell with the given element as its car, and the list as
        its cdr, and sets the list to the new cons cell.

    last
        Returns the last non-NIL top-level node of the LIST.

    length
        Returns the number of non-NIL top-level nodes of a list.

    listp
        Returns true if its argument is a list (This method may be exported and used as
        a function).
    
    nilp
        Returns true if its argument is NIL (This method may be exported and used as
        a function).

    string
        Returns a string representation of a list.

    apply (CODEREF)
        Same as apply in LISP::Lambda but takes the arguments in a different order, so
        the list is the object instead of the subroutine.

    mapcar (CODEREF, [@MORE_LISTS])
        Same as mapcar in LISP::Lambda but takes arguments in a different order, so the
        list is the object instead of the subroutine.


=head2 EXPORT

Nothing exported by default.

    :all
        exports the methods/functions listp and nilp so they can be used as functions on
        values other than lists.
    


=head1 AUTHOR

Douglas Wilson, dwilson@gtemail.net

=head1 SEE ALSO

perl(1).

=cut
