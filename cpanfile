requires 'perl', '5.010001';

# requires 'Some::Module', 'VERSION';
requires 'Mojolicious', '0';
requires 'FormValidator::Lite', '>= 0.35';
requires 'Clone', '>= 0.34';

on test => sub {
    requires 'Test::More', '0.88';
    requires 'URI', '0';
};
