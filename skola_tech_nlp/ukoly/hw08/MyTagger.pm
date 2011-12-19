package MyTagger;
use warnings;
use strict;



my $WEIGHT_CONSTANT=13/16;
my $TOPLINES_LENGTH = 10000; 

#spocita "vahu"
#tj. jak moc se mi par koncovka-tag "libi"
#cim vic se par vyskytne, tim je vaha vyssi
#ale cim vic se koncovka vyskytne obecne, tim je vaha nizsi
#13/16 je naprosto od oka, jak se mi to libilo
#kdyz je to mensi, prilis dulezite jsou koncovky, ktere se vyskytuji vsude (jednopismenne)
#kdyz je to vetsi, prilis dulezite jsou koncovky, co jsou parkrat v celem korpusu
sub _weight {
	my ($pair_strengths, $overall_usage, $pair) = @_;
	$pair =~ /(.*)\t(.*)/;	
	return $pair_strengths->{$pair}/(($overall_usage->{$1})**($WEIGHT_CONSTANT));
}

sub train {
	my ($encoding, $filename) = @_;
	
	#"sily" paru koncovka-tag - tj. jak je caste
	my %pair_strengths;

	#jak je casta cela koncovka
	my %overall_usage;

	open my $TAGFILE, "<:encoding($encoding)", $filename or die $filename." does not exist.";

	while (<$TAGFILE>) {
		my $line = $_;
		#tag je oddeleny /
		$line =~ /([^\/]*)\/(.)/;
		
		my $word = $1;
		my $part = $2;

		my @word_split = split //, $word;
		while (scalar @word_split) {
			my $ending = join ("", @word_split);
			$pair_strengths{$ending."\t".$part}++;
			$overall_usage{$ending}++;
			shift @word_split;
		}
	}

	close $TAGFILE;
	
	#abych to nemusel opisovat :)
	my $ret_weight = sub {return _weight(\%pair_strengths, \%overall_usage, $_[0])};
	my @top_endings = sort{$ret_weight->($b) <=> $ret_weight->($a)} keys %pair_strengths;
	@top_endings = @top_endings[0..$TOPLINES_LENGTH-1];
	
	open my $TOP_ENDINGSFILE, ">:utf8", "top_endings";
	for (@top_endings){
		if (defined $_) {
            print $TOP_ENDINGSFILE $_."\n";
	    }
    }
	close $TOP_ENDINGSFILE;
}

sub _guesspart {
	my ($top_endings, $word)=@_;
	for my $pair (@$top_endings) {
		$pair =~ /^(.*)\t(.*)$/;
		my $part = $2;
		my $ending = $1;
	
		#\Q automaticky escapuje pro regexp
		my $escaped_ending = "\Q$ending";
		if ($word =~ /$escaped_ending$/) {
			return $part;
		}
	}
	return "N";
}

sub tag {
	my @words = @_;

	open my $TOP_ENDINGSFILE, "<:utf8", "top_endings" or die "top_endings does not exist, maybe you want to run MyTagger::prepare first?";
	
	#Neni to v hashi koncovka->tag, protoze ZALEZI na poradi
	my @top_endings;
	while (<$TOP_ENDINGSFILE>) {
		chomp;
		push @top_endings, $_;
	}
	close $TOP_ENDINGSFILE;
	
	#print scalar @top_endings;

	my @parts;
	for my $word (@words) {
		push @parts, _guesspart(\@top_endings, $word);	
	}

	return @parts;
}

1;


=head1 NAME

MyTagger - my tagger, based on word endings.

=head1 SYNOPSIS

   use MyTagger;

   MyTagger::train("iso-8859-2", "textcz2.ptg");

   my @tags = MyTagger::tag(qw/Příliš žluťoučký kůň úpěl ďábelské ódy/);

=head1 Description

I thought about implementing tagger, based on "simple word ending rules", as described on
the course page. However, I didn't feel like really writing them.

Instead, I wrote a module, that takes an already tagged Czech corpus and tries to learn some 
word ending rules by itself. The corpus is downloaded from pages of Mr. Hajič course on
L<http://ufal.mff.cuni.cz/~hajic/courses/npfl067/textcz2.ptg> , but any corpus will do, provided, that 
the format C<word/tag> is kept, that the word will never contait a "/" letter and that first
letter after "/" letter is always part of speech tag.

The module saves C<top_endings> file with the endings to whenever it's run from and then loads it
again for tagging; it can be loaded again multiple times.

=head2 Training

C<MyTagger::train ( $encoding, $filename )> trains the endings on the file C<$filename> with the encoding C<$encoding> and then saves them into C<top_endings> file into current working directory.

=head2 Tagging
C<MyTagger::tag ( @words )> will tag words, based on C<top_endings> file. If the ending is not found, it will give the word the default C<N> tag.

=head1 AUTHOR

Karel Bilek <F<kb@karelbilek.com>>

=head1 COPYRIGHT

Copyright (c) 2011 Karel Bilek, All Rights Reserved.
This module is released under the same terms as Perl itself.

=cut
