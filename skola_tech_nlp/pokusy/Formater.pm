package Formater;

use Moose;

has 'length' => (
      is      => 'rw',
      isa     => 'Int',
      default => 20 
);

sub join_words {
	my ($a, $b) = @_;
	if ($a eq "") {
		return $b;
	} else {
		return $a." ".$b;
	}
}

sub reformat {
	my $self = shift;
	my $text = shift;


	my @words = split(/\s/, $text);
	my $result;
	my $current_line="";
	for my $word (@words) {
		if (length(join_words($current_line, $word)) <= $self->length()){
			
			$current_line=join_words($current_line, $word);

		} else {
			$result .= $current_line."\n";
			$current_line = $word;
		}
	}
	$result .= $current_line."\n";
	return $result;
}



1;



=head1 NAME
Formater - for formating text that has longer lines.

=head1 SYNOPSIS

   use Formater;

   my $formater = new Formater(length=>30);

   my $formated_text = $formater->reformat($unformated_text);

=head1 Description
It formats text that has longer lines so it no longer has longer lines; however, it also deletes all newlines and formats the text in one piece. The line length can be changed. 

It is dead simple and this POD documentiation is longer than the source code.

=head2 new Formater ()

Creates Formater that has length 20.

=head2 new Formater ( $length )

Creates Formater with arbitrary length.

=head2 reformat ( $text )

Reformats the text as requested, returns the string.
=head1 AUTHOR

Karel Bilek <F<kb@karelbilek.com>>

=head1 COPYRIGHT

Copyright (c) 2011 Karel Bilek, All Rights Reserved.
I doubt it will be ever useful to anyone, ever.

=cut
