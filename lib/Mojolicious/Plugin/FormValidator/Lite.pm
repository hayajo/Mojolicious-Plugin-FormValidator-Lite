package Mojolicious::Plugin::FormValidator::Lite;

use Mojo::Base 'Mojolicious::Plugin';
our $VERSION = '0.01';

use FormValidator::Lite;
use Storable qw/dclone/;

sub register {
    my ( $self, $app, $conf ) = @_;

    $app->helper(
        validator => sub {
            my ( $c, %opts ) = @_;

            my $constraints = $opts{constraints}  || $conf->{constraints}  || [];

            my $msg = $opts{message_data} || {};
            # merge config
            if ( my $conf_msg = dclone $conf->{message_data} ) {
                for my $key (qw/message param function/) {
                    $msg->{$key} = $conf_msg->{$key} if ( $conf_msg->{$key} );
                }
            }
            # set default values
            $msg->{message}  ||= {};
            $msg->{param}    ||= +{ map { $_ => $_ } keys %{ $c->req->params->to_hash } };
            $msg->{function} ||= 'en';

            my $lang;
            if ( $msg->{function} =~ /^(ja|en)$/ ) {
                $lang = $msg->{function};
                $msg->{function} = {};
            }

            my $v = FormValidator::Lite->new($c);
            $v->load_constraints(@$constraints);

            $v->set_message_data($msg);
            $v->load_function_message($lang) if ($lang);

            return $v;
        }
    );
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojolicious::Plugin::FormValidator::Lite - Blah blah blah

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('FormValidator::Lite');

  # Mojolicious::Lite
  plugin 'FormValidator::Lite';

=head1 DESCRIPTION

Mojolicious::Plugin::FormValidator::Lite is

=head1 AUTHOR

hayajo E<lt>hayajo@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- hayajo

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
