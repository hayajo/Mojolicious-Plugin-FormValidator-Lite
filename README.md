# NAME

Mojolicious::Plugin::FormValidator::Lite - FormValidator::Lite plugin for Mojolicious

# SYNOPSIS

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

# DESCRIPTION

Mojolicious::Plugin::FormValidator::Lite is FormValidator::Lite plugin for Mojolicious

# AUTHOR

hayajo <hayajo@cpan.org>

# COPYRIGHT

Copyright 2013- hayajo

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[Mojolicious](http://search.cpan.org/perldoc?Mojolicious)

[FormValidator::Lite](http://search.cpan.org/perldoc?FormValidator::Lite)
