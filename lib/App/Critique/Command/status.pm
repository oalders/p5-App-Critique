package App::Critique::Command::status;

use strict;
use warnings;

use App::Critique::Session;

use App::Critique -command;

sub execute {
    my ($self, $opt, $args) = @_;

    my $session = $self->cautiously_load_session( $opt, $args );

    info('Session file loaded.');

    my @tracked_files = $session->tracked_files;
    my $num_files     = scalar @tracked_files;
    my $curr_file_idx = $session->current_file_idx;

    my ($violations, $reviewed, $edited) = (0, 0, 0);
    foreach my $file ( @tracked_files ) {
        $violations += $file->recall('violations') if defined $file->recall('violations');
        $reviewed   += $file->recall('reviewed')   if defined $file->recall('reviewed');
        $edited     += $file->recall('edited')     if defined $file->recall('edited');
    }

    if ( $opt->verbose ) {
        info(HR_DARK);
        info('CONFIG:');
        info(HR_LIGHT);
        info('  perl_critic_profile : %s', $session->perl_critic_profile // 'auto');
        info('  perl_critic_theme   : %s', $session->perl_critic_theme   // 'auto');
        info('  perl_critic_policy  : %s', $session->perl_critic_policy  // 'auto');
        info('  git_work_tree       : %s', $session->git_work_tree       // 'auto');
        info('  git_branch          : %s', $session->git_branch          // 'auto');
    }

    info(HR_DARK);
    info('FILES: <legend: [v|r|e] path>');
    if ( $opt->verbose ) {
        info(HR_LIGHT);
        info('CURRENT FILE INDEX: (%d)', $curr_file_idx);
    }
    info(HR_LIGHT);
    foreach my $i ( 0 .. $#tracked_files ) {
        my $file = $tracked_files[$i];
        info('%s [%s|%s|%s] %s',
            ($i == $curr_file_idx ? '>' : ' '),
            $file->recall('violations') // '-',
            $file->recall('reviewed')   // '-',
            $file->recall('edited')     // '-',
            $file->relative_path( $session->git_work_tree ),
        );
    }
    info(HR_DARK);
    info('TOTAL: %d files', $num_files );
    info('  (v)iolations : %d', $violations);
    info('  (r)eviwed    : %d', $reviewed  );
    info('  (e)dited     : %d', $edited    );

    if ( $opt->verbose ) {
        info(HR_LIGHT);
        info('PATH: (%s)', $session->session_file_path);
    }
    info(HR_DARK);

}

1;

__END__

# ABSTRACT: Display status of the current critique session.

=pod

=head1 NAME

App::Critique::Command::status - Display status of the current critique session.

=head1 DESCRIPTION

This command will display information about the current critique session.
Among other things, this will include information about each of the files,
such as how many violations were found, how many of those violations were
reviewed, and how many were edited.

=cut
