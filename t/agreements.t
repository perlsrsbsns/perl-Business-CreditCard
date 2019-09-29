use Test::More tests => 1;
use Business::CreditCard;

# Old tests removed because by today all BIN's are unique. One BIN can't and shouldn't be different for 2+ countries.

ok ( test_card_id_base() );

sub test_cards {
  my $cards = shift;
  while( my ($k, $v)=each(%$cards) ){
    if(cardtype($k) ne $v){
      warn "Card $k - should be $v for $Business::CreditCard::Country ".
           " but cardtype returns ". cardtype($k). "\n";
      return;
    }
  }
  return 1;  
}

sub test_card_id_base {
  local($Business::CreditCard::Country) = '';

  my %cards = (
  '3528000000000007' => 'JCB',
  '3589000000000003' => 'JCB',
  '4111111111111111' => 'VISA',


  );
  test_cards(\%cards);
}
