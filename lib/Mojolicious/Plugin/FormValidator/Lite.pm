package Mojolicious::Plugin::FormValidator::Lite;

use Mojo::Base 'Mojolicious::Plugin';
our $VERSION = '0.01';

use FormValidator::Lite;
use Storable qw/dclone/;

sub register {
    my ( $self, $app, $conf ) = @_;

    $app->helper(
        validator => sub {
            my ($c, %opts) = @_;
            _validator($c, \%opts, $conf);
        },
    );
}

sub _validator {
    my ( $c, $opts, $conf ) = @_;

    return $c->stash('validator') if ( $c->stash('validator') );

    my $constraints = $opts->{constraints} || $conf->{constraints} || [];
    my $message     = $opts->{message_data} || {};

    # merge config
    if ( my $conf_message = dclone $conf->{message_data} ) {
        for my $key (qw/message param function/) {
            $message->{$key} = $conf_message->{$key} if ( $conf_message->{$key} );
        }
    }

    # set default values
    $message->{message}  ||= {};
    $message->{param}    ||= +{ map { $_ => $_ } keys %{ $c->req->params->to_hash } };
    $message->{function} ||= 'en';

    my $lang;
    if ( $message->{function} =~ /^(ja|en)$/ ) {
        $lang = $message->{function};
        $message->{function} = {};
    }

    my $v = FormValidator::Lite->new($c);
    $v->load_constraints(@$constraints);
    $v->set_message_data($message);
    $v->load_function_message($lang) if ($lang);

    $c->stash( validator => $v );

    return $v;
}

1;
__END__

=encoding utf-8

=head1 NAME

Mojolicious::Plugin::FormValidator::Lite - FormValidator::Lite plugin for Mojolicious

=head1 SYNOPSIS

  # Mojolicious::Lite
  plugin 'FormValidator::Lite' => {
      constraints  => [qw/Email +MyApp::Validator::Constraint/],
      message_data => {
          param => {
              username => 'User Name'
              email    => 'Email',
              homepage => 'HomePage',
          },
          function => 'ja',
      },
  }; # default options

  post '/' => sub {
      my $self = shift;
      $self->validator(
          message_data => {
              message => {
                  'homepage.url' => '[_1] is not valid URL'
              },
          }, # additional/replacement options
      )->check(
          username => [qw/NOT_NULL/],
          email    => [qw/NOT_NULL EMAIL_LOOSE/],
          homepage => [qw/URL/],
      );

      if ( $self->validator->has_error ) {
          $self->stash( error => 'Registration failed' );
          $self->res->code(422);
          return $self->__render_filled_html('index');
      }

      $self->stash( info => 'Registration succeeded' );
      $self->render('index');
  };

  # in template
  % if (validator->is_error('email')) {
  <div>
      <span><%= join " ", validator->get_error_messages_from_param('email') %></span>
  </div>
  % }

=head1 DESCRIPTION

Mojolicious::Plugin::FormValidator::Lite is FormValidator::Lite plugin for Mojolicious

=head1 AUTHOR

hayajo E<lt>hayajo@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- hayajo

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Mojolicious>

L<FormValidator::Lite>

=cut
