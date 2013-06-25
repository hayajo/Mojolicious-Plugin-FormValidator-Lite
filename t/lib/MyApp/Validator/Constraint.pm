package t::lib::MyApp::Validator::Constraint;
use strict;
use warnings;
use FormValidator::Lite::Constraint;
use URI;

rule 'URL' => sub {
    URI->new($_, 'http')->scheme;
};

1;
