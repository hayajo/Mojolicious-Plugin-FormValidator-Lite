package Mojolicious::Plugin::FormValidator::Lite;

use Mojo::Base 'Mojolicious::Plugin';
our $VERSION = '0.01';

use FormValidator::Lite;

sub register {
    my ( $self, $app, $conf ) = @_;

    $app->helper(
        validator => sub {
            my $c = shift;
            if ( !$c->stash('validator') ) {
                my $v = _validator($c, $conf);
                $c->stash('validator' => $v);
            }
            return $c->stash('validator');
        },
    );

    no strict 'refs';
    *{Mojo::Upload::type} = sub { $_[0]->headers->content_type };
    *{Mojo::Upload::fh}   = sub {
        my $asset = $_[0]->asset;
        if ( $asset->isa('Mojo::Asset::Memory') ) {
            my $file = Mojo::Asset::File->new;
            $file->add_chunk($asset->emit(upgrade => $file)->slurp);
            return $file->handle;
        }
        return $asset->handle;
    };
}

sub _validator {
    my ( $c, $conf ) = @_;

    my $constraints      = $conf->{constraints}      || [];
    my $param_message    = $conf->{param_message}    || {};
    my $function_message = $conf->{function_message} || 'en';
    my $message          = $conf->{message}          || {};

    my $v = FormValidator::Lite->new($c->req);
    $v->load_constraints(@$constraints);
    $v->load_function_message($function_message);
    $v->set_param_message(%$param_message);

    for my $key (keys %$message) {
        $v->set_message($key => $message->{$key});
    }

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
      param_message => {
          username => 'User Name'
          email    => 'Email',
      },
      function_message => 'ja',
  }; # default settings

  post '/' => sub {
      my $self = shift;
      $self->validator->set_message('homepage.url' => '[_1] is not valid URL');
      $self->validator->set_param_message('homepage' => 'HomePage');
      $self->validator->check(
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
  % if (validator->has_error) {
  <ul>
    % for my $msg (validator->get_error_messages) {
    <li class="text-error"><%= $msg %><li>
    % }
  </ul>
  % }
  ...
  ...
  ...
  % if (validator->is_error('email')) {
  <span class="text-error"><%= join " ", validator->get_error_messages_from_param('email') %></span>
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
