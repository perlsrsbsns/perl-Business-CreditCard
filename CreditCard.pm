package Business::CreditCard;

require Exporter;
use vars qw( @ISA $VERSION @EXPORT @EXPORT_OK %EXPORT_TAGS $Country );

@ISA = qw( Exporter );

$VERSION = "0.37";

@EXPORT = qw( cardtype validate generate_last_digit );
@EXPORT_OK = qw( receipt_cardtype validate_card );
$EXPORT_TAGS{NEW} = [ qw( validate_card cardtype receipt_cardtype ) ];

$Country = 'US';

=head1 NAME

C<Business::CreditCard> - Validate/generate credit card checksums/names

=head1 SYNOPSIS

    use Business::CreditCard;
 
    print validate("5276 4400 6542 1319");
    print cardtype("5276 4400 6542 1319");
    print generate_last_digit("5276 4400 6542 131");

Business::CreditCard is available at a CPAN site near you.

=head1 DESCRIPTION

These subroutines tell you whether a credit card number is
self-consistent -- whether the last digit of the number is a valid
checksum for the preceding digits.  

The validate() subroutine returns 1 if the card number provided passes
the checksum test, and 0 otherwise.

The cardtype() subroutine returns a string containing the type of
card.  The list of possible return values is more comprehensive than it used
to be, but additions are still most welcome.

Possible return values are:

  VISA
  MasterCard
  Maestro
  Discover
  American Express
  MIR
  Dankort
  UnionPay
  JCB
  RuPay
  Troy
  UATP
  Verve
  InterPayment
  enRoute
  Solo
  Laser
  Isracard
  Unknown

"Not a credit card" is returned on obviously invalid data values.

Versions before 0.31 may also have returned "Diner's Club/Carte Blanche" (these
cards are now recognized as "Discover card").

As of 0.30, cardtype() will accept a partial card masked with "x", "X', ".",
"*" or "_".  Only the first 2-6 digits and the length are significant;
whitespace and dashes are removed.  With two digits, Visa, MasterCard, Discover
and Amex are recognized (versions before 0.36 needed four digits to recognize
all Discover cards).  With four digits, almost all cards except some
Switch cards are recognized.  With six digits (the full "BIN" or "IIN"), all
cards are recognized.  Six digits are also required for receipt_cardtype().

The generate_last_digit() subroutine computes and returns the last
digit of the card given the preceding digits.  With a 16-digit card,
you provide the first 15 digits; the subroutine returns the sixteenth.

This module does I<not> tell you whether the number is on an actual
card, only whether it might conceivably be on a real card.  To verify
whether a card is real, or whether it's been stolen, or to actually process
charges, you need a Merchant account.  See L<Business::OnlinePayment>.

These subroutines will also work if you provide the arguments
as numbers instead of strings, e.g. C<validate(5276440065421319)>.  

=head1 PROCESSING AGREEMENTS

Credit card issuers have recently been forming agreements to process cards on
other networks, in which one type of card is processed as another card type.

By default, Business::CreditCard returns the type the card should be treated as
in the US.  You can change this to return the type the card should
be treated as in a different country by setting
C<$Business::CreditCard::Country> to your two-letter country code.  This
is probably what you want to determine if you accept the card, or which
merchant agreement it is processed through.

You can also set C<$Business::CreditCard::Country> to a false value such
as the empty string to return the "base" card type.  This is probably only
useful for informational purposes when used along with the default type.

Here are the currently known agreements:

=over 4

=item Most Diner's club is now identified as Discover.  (This supercedes the earlier identification of some Diner's club cards as MasterCard inside the US and Canada.)

=item JCB cards in the 3528-3589 range are identified as Discover inside the US and territories.

=item China Union Pay cards are identified as Discover cards in the US, Mexico and most Caribbean countries.

2019 upd: The problem of the above mentioned could be mistakes in BIN database commercial solutions, such as binbase.com or bindb.com.
For example, binbase.com's Single license differs a lot from Extended license, the first one may always contain lots of errors,
but still it's widely used by lots of small card processors/merchants due to a low cost and good availability.
Specially many US merchants prefer using cheap outsourced solutions for their checkout systems, which often result
into inaccurate information, please read https://baymard.com/checkout-usability/credit-card-patterns

=back

=head1 RECEIPT REQUIREMENTS

Discover requires some cards processed on its network to display "PayPal"
on receipts instead of "Discover".  The receipt_cardtype() subroutine will
return "PayPal card" for these cards only, and otherwise the same output as
cardtype().

Use this for receipt display/printing only.

Note: this subroutine is not exported by default like the others.
Before 0.36, you needed to call this subroutine fully-qualified, as
Business::CreditCard::receipt_cardtype()

In 0.36 and later, you can import it into your namespace:

  use Business::CreditCard qw( :DEFAULT receipt_cardtype );


=head1 ORIGINAL AUTHOR

Jon Orwant

The Perl Journal and MIT Media Lab

=head1 MAINTAINER

Current maintainer of 0.37 (a fork of 0.36) is Lisa Shadow <perlsrsbsns@protonmail.com>.

Current maintainer of 0.36 is Ivan Kohler <ivan-business-creditcard@420.am>.

Lee Lawrence <LeeL@aspin.co.uk>, Neale Banks <neale@lowendale.com.au> and
Max Becker <Max.Becker@firstgate.com> contributed support for additional card
types.  Lee also contributed a working test.pl.  Alexandr Ciornii
<alexchorny@gmail.com> contributed code cleanups.  Jason Terry
<jterry@bluehost.com> contributed updates for Discover BIN ranges.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 1995,1996,1997 Jon Orwant
Copyright (C) 2001-2006 Ivan Kohler
Copyright (C) 2007-2016 Freeside Internet Services, Inc.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

(paraphrasing Neil Bowers) We export all functions by default.  It would be
better to let the user decide which functions to import.  And validate() is
a bit of a generic name.

The question is, after almost 2 decades with this interface (inherited from
the original author, who probably never expected it to live half this long),
how to change things to behave in a more modern fashion without breaking
existing code?  "use Business::CreditCard <some_minimum_version>" turns it off?
Explicitly ask to turn it off and list that in the SYNOPSIS?

=head2 validate() and @EXPORT transition plan

First (done in 0.36): 

validate_card() is the new name for validate().  Both work for now.

New-style usage (not recommended for code that needs to support B:CC before 0.36):

  use Business::CreditCard qw( :NEW );

You get validate_card(), cardtype() and receipt_cardtype().  You can also ask
for them explicitly / individually:

  use Business::CreditCard qw( validate_card cardtype receipt_cardtype );


Second (we're at now now): 

Waiting for 0.36+ to become more prevalent.


Third:

Recommend new-style usage.  Maybe asking for a specific minimum version turns
it on too?


Fourth:
 (this is the incompatible part):

Don't export validate() (or anything else [separately?]) by default.

This is the part that will break things and we probably won't do for a long
time, until new-style usage is the norm and the tradeoff of breaking old code
is worth it to stop or namespace pollution.  Maybe do a 1.00 releaes with the
current API and 2.00 is when this happens (with a 1.99_01 pre-release)?

=head1 SEE ALSO

L<Business::CreditCard::Object> is a wrapper around Business::CreditCard
providing an OO interface.  Assistance integrating this into the base
Business::CreditCard distribution is welcome.

L<Business::OnlinePayment> is a framework for processing online payments
including modules for various payment gateways.

http://neilb.org/reviews/luhn.html is an excellent overview of similar modules
providing credit card number verification (LUHN checking).

=cut

## ref http://neilb.org/reviews/luhn.html#Comparison it looks like
## Business::CCCheck is 2x faster than we are.  looking at their implementation
## not entirely a fair comparison, we also do the equivalent of their CC_clean,
## they don't recognize certain cards at all (i.e. Switch) which require
## an expensive check before VISA, Diners doesn't exist anymore, Discover is
## a lot more than just 6011*, they don't handle processing agreements, etc.

sub cardtype {
    # Allow use as a class method
    shift if UNIVERSAL::isa( $_[0], 'Business::CreditCard' );

    my ($number) = @_;
    
    my $cnumber = $number;
    $cnumber =~ s/[^\d]//g; # $cnumber will be used for all checks in future, because
							# I don't think working around 'x' just for example purposes is practical at all.
	my $bin = int substr($cnumber,0,6);
	
    $number =~ s/[\s\-]//g;
    $number =~ s/[x\*\.\_]/x/gi;

    return "Not a credit card" if $number =~ /[^\dx]/i;

    #$number =~ s/\D//g;
    {
      local $^W=0; #no warning at next line
      return "Not a credit card"
        unless ( length($number) >= 13
                 || length($number) == 8 || length($number) == 9 #Isracard
               )
            && 0+$number;
    }
    
    return "VISA" if $number =~ /^4[\dx]{15}$/;
    
    return "Dankort" if $number =~ /^5019[\dx]{12}$/;
    
    return "InterPayment" if $number =~ /^63[789][\dx]{13}$/;
    return "InterPayment" if $number =~ /^636[\dx]{13,16}$/;
    
    return "RuPay" if $number =~ /^652[12][\dx]{12}$/;

	return "Verve" if (( $bin >= 506099 && $bin <= 506198 ) || ( $bin >= 650002 && $bin <= 650027 )) 
	                  && (length $cnumber >= 16 && length $cnumber <= 19);

	return "Maestro" 
	  if $number =~ /^6759[\dx]{8,15}$/      # Maestro UK 6759
	  || $number =~ /^67677[04][\dx]{6,13}$/ # Maestro UK 676770, 676774
	  || $number =~ /^5[06789][\dx]{10,17}$/ # Maestro 50, 56-59
	  || $number =~ /^6[1-9][\dx]{10,17}$/; # Maestro 61–69

    return "MasterCard" 
      if $number =~ /^5[1-5][\dx]{14}$/
      || $number =~ /^2 ( 22[1-9] | 2[3-9][\dx] | [3-6][\dx]{2} | 7[0-1][\dx] | 720 ) [\dx]{12}$/x
      || $number =~ /^2[2-7]xx[\dx]{12}$/;

    return "American Express" if $number =~ /^3[47][\dx]{13}$/;

    return "Discover"
      if   $number =~ /^30[0-5x][\dx]{13,16}$/  #diner's:  300-305, 30x
      ||   $number =~ /^309[5x][\dx]{12}$/      #          3095, 309x
      ||   $number =~ /^36[\dx]{12,17}$/        #          36
      ||   $number =~ /^3[89][\dx]{14,17}$/     #          38 and 39
      ||   $number =~ /^60[1x]{2}[\dx]{12,15}$/ #discover: 6011 601x 60xx
      ||   $number =~ /^64[4-9x][\dx]{13,16}$/  #          644-649, 64x 
      ||   $number =~ /^65[\dx]{14,17}$/        #          65
      || ( $number =~ /^62[24-68x][\dx]{13,16}$/ && $Country =~ /^(US|MX|AI|AG|AW|BS|BB|BM|BQ|VG|KY|CW|DM|DO|GD|GP|JM|MQ|MS|BL|KN|LC|VC|MF|SX|TT|TC)$/i ) #China Union Pay identified as Discover in US, Mexico and Caribbean
      || ( $number =~ /^35(2[89x]|[3-8][\dx]|xx)[\dx]{12,15}$/ && $Country =~ /^(US|PR|VI|MP|PW|GU)$/i ); #JCB cards in the 3528-3589 range are identified as Discover in US, Puerto Rico, US Virgin Islands, Northern Mariana Islands, Palau and Guam

    # return "RuPay" if $number =~ /^60[\dx]{14}$/; # The information on the wiki might be erroneous on this one, 
													# because binbase.com lists the whole range 60* as Maestro
													# This will remain commented and reserved for future just in case
													# something change.
													
	return "Maestro" if $number =~ /^60[\dx]{10,17}$/;

    return "MIR" if $number =~ /^220[0-4][\dx]{12}$/;

    return "Troy" if $number =~ /^9792[0-8][0-9][\dx]{10}$/;

    return "UATP" if $number =~ /^1[\dx]{14}$/;
    
    #"Diners Club enRoute"
    return "enRoute" if $number =~ /^2(014|149)[\dx]{11}$/; # Diners Club enRoute is obsolete

    return "JCB" if $number =~ /^(3[\dx]{4}|2131|1800)[\dx]{11}$/;

    return "Solo" # Solo is obsolete
      if $number =~ /^6(3(34[5-9][0-9])|767[0-9]{2})[\dx]{10}([\dx]{2,3})?$/;

    return "UnionPay"
      if $number =~ /^62[\dx]{14,17}$/
      || $number =~ /^81[\dx]{14}$/;
      
    return "Laser" # Laser is obsolete
      if $number =~ /^6(304|7(06|09|71))[\dx]{12,15}$/;

    return "Isracard"
      if $number =~ /^[\dx]{8,9}$/;

    return "Unknown";
}

sub receipt_cardtype {
    # Allow use as a class method
    shift if UNIVERSAL::isa( $_[0], 'Business::CreditCard' );

    my ($number) = @_;

    $number =~ s/[\s\-]//g;
    $number =~ s/[x\*\.\_]/x/gi;

    #ref Discover IIN Bulletin Feb 2015_021715
    return "PayPal card" if $number =~ /^6(01104|506[01]0)[\dx]{10,13}$/;

    cardtype($number);
}

sub generate_last_digit {
    # Allow use as a class method
    shift if UNIVERSAL::isa( $_[0], 'Business::CreditCard' );

    my ($number) = @_;

    die "invalid operation" if length($number) == 8 || length($number) == 9;

    my ($i, $sum, $weight);

    $number =~ s/\D//g;

    for ($i = 0; $i < length($number); $i++) {
	$weight = substr($number, -1 * ($i + 1), 1) * (2 - ($i % 2));
	$sum += (($weight < 10) ? $weight : ($weight - 9));
    }

    return (10 - $sum % 10) % 10;
}


## this (GPLed) code from Business::CCCheck is apparantly 4x faster than ours
## ref http://neilb.org/reviews/luhn.html#Comparison
## maybe see if we can speed ours up a bit
#  my @ccn = split('',$ccn);
#  my $even = 0;
#  $ccn = 0;
#  for($i=$#ccn;$i >=0;--$i) {
#    $ccn[$i] *= 2 if $even;
#    $ccn -= 9 if $ccn[$i] > 9;
#    $ccn += $ccn[$i];
#    $even = ! $even;
#  }
#  $type = '' if $ccn % 10;
#  return $type;

sub validate { validate_card(@_); }

sub validate_card {
    # Allow use as a class method
    shift if UNIVERSAL::isa( $_[0], 'Business::CreditCard' );

    my ($number) = @_;

    my ($i, $sum, $weight);
    
    return 0 if $number =~ /[^\d\s]/;

    $number =~ s/\D//g;

    if ( $number =~ /^[\dx]{8,9}$/ ) { # Isracard
        $number = "0$number" if length($number) == 8;
        for($i=1;$i<length($number);$i++){
            $sum += substr($number,9-$i,1) * $i;
        }
        return 1 if $sum%11 == 0;
        return 0;
    }

    return 0 unless length($number) >= 13 && 0+$number;

    for ($i = 0; $i < length($number) - 1; $i++) {
	$weight = substr($number, -1 * ($i + 2), 1) * (2 - ($i % 2));
	$sum += (($weight < 10) ? $weight : ($weight - 9));
    }

    return 1 if substr($number, -1) == (10 - $sum % 10) % 10;
    return 0;
}

1;


