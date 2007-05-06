# $Id: Signature.pm,v 1.9 2006/04/18 21:46:01 pfeiffer Exp $
package Signature;

=head1 NAME

Signature -- Interface definition for various signature classes

=head1 USAGE

Derive a package from this package.

=head1 DESCRIPTION

Makepp is quite flexible in the algorithm it uses for deciding whether
a target is out of date with respect to its dependencies.  Most of this
flexibility is due to various different implementations of the Signature
class.

Each rule can have a different signature class associated with it,
if necessary.  In the makefile, the signature class is specified by
using the :signature modifier, like this:

   %.o : %.c
	   : signature special_build
	   $(CC) $(CFLAGS) -c $(FIRST_DEPENDENCY) -o $(TARGET)

This causes the signature class C<Signature::special_build> to be used for
this particular rule.

Only one object from each different signature class is actually created; the
object has no data, and its only purpose is to contain a blessed reference to
the package that actually implements the functions.  Each rule contains a
reference to the Signature object that is appropriate for it.  The object is
found by the name of the Signature class.  For example, the above rule uses
the object referenced by C<$Signature::special_build::special_build>.  (The
purpose of this naming scheme is to make it impossible to inherit accidently a
singleton object, which would cause the wrong Signature class to be used.)


=head2 signature

   $signature = $sigobj->signature($objinfo);

This function returns a signature for the given object (usually a
FileInfo class, but possibly some other kind of object).  A signature is
simply an ASCII string that will change if the object is modified.

$sigobj is the dummy Signature class object.

$objinfo is the a reference to B<makepp>'s internal description of that object
and how it is to be built.  See L<makepp_extending> for details.

The default signature function simply calls $objinfo->signature, i.e., it uses
the default signature function for objects of that class.  For files, this is
the file date concatenated with the file size.

=cut

$Signature::signature = bless []; # Make the singleton object.

sub signature {
  return $_[1]->signature;
}

# This is used to determine whether the signature is file content based, as
# opposed to timestamp based.  This is used to determine whether the signature
# can be used in a build cache key, because we never want to use
# timestamp-based signatures for that.
sub is_content_based {
  # A heuristic that works for all the current Signature subclasses, but
  # not necessarily for all possible subclasses.
  return $_[0] =~ m|^[+/A-Za-z\d]{22}$|;
}

=head1 BUGS

A signature must not contain 22 consecutive characters that are alphanumeric
or '+' or '/', unless the signature is dependent only on file content and
expected to be alias-free.
Otherwise, aliases can cause corruption when you use build caches.
There probably ought to be a more robust way to determine whether a signature
was generated by a method that is prone to aliasing.

=cut

1;
