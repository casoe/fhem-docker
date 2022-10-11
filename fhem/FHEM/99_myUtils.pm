##############################################
# $Id: myUtilsTemplate.pm 21509 2020-03-25 11:20:51Z rudolfkoenig $
#
# Save this file as 99_myUtils.pm, and create your own functions in the new
# file. They are then available in every Perl expression.

package main;

use strict;
use warnings;

sub
myUtils_Initialize($$)
{
  my ($hash) = @_;
}

# Enter you functions below _this_ line.

sub checkFritzMACpresent($$) {
  # Benötigt: Name der zu testenden Fritzbox ($d),
  #           zu suchende MAC ($m), 
  # Rückgabe: 1 = Gerät gefunden
  #           0 = Gerät nicht gefunden
  my ($d,$m) = @_;
  $m =~ s/:/_/g;
  $m = "mac_".uc($m);
  return (ReadingsVal($d,$m,"inactive") ne "inactive") ? 1 : 0;
}

1;
