package Verb::English;

use Readonly;
use Moose;

has 'infinitive' => (
	is => 'ro', 
	isa => 'Str', 
	required => 1,
);

sub _read_past_tense {
	my %result;

	open my $file, "<", "irregular_verbs";
	while (my $line = <$file>) {
		chomp $line;
		my ($word, $past) = $line =~ /(.*)\t(.*)/;
		$result{$word} = $past;
	}
	return %result;
}

Readonly my %past_tense_of => _read_past_tense();

sub _irregular_past_tense {
	my $self = shift;

	my $past_form = $past_tense_of{ $self->infinitive() };
	if (defined $past_form) { 
		return $past_form;
	} else {
		return undef;
	}
}

sub _regular_past_tense {
	
	my $self = shift;
	my $infinitive = $self->infinitive();

	if ($infinitive =~ /e$/) {
		return $infinitive."d";
	}

	if ($infinitive =~ /^(.*)y$/) {
		return $1."ied";
	}

	if ($infinitive =~ /[^aeiouy][aeiouy]([^aeiouy])$/) {
		return $infinitive.$1."ed";
	}

	return $infinitive."ed";

}

sub past_tense {

	my $self = shift;
	my $irregular_past = $self->_irregular_past_tense();
	
	if (defined $irregular_past) {
		return $irregular_past;
	} 
	else {
		return $self->_regular_past_tense();
	}
}

1;


