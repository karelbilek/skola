package Zpravostroj::Forker;
use forks;

use Moose;
use MooseX::StrictConstructor;
use Moose::Util::TypeConstraints;

use Zpravostroj::Globals;

#mnozstvi povolenych threadu naraz
#(muze se mozna stat, ze pobezi o 1 navic, ale mozna ne)
has 'size' => (
	is=>'ro',  #WRONG 1 - mezery mezi =>
	required=>1,
	isa=>'Int'
);



#bezici thready
has 'threads' => (
	is=>'rw',
	isa=>'ArrayRef',
	default=>sub{[]} #WRONG ? - not sure about this, it is Moose hack by itself
);

#cekajici subroutiny /s closures/
has 'waiting_subs' => (
	is=>'rw',
	isa=>'ArrayRef',
	default=>sub{[]}
);


#cekam na skonceni vseho = dokud je 0 bezicich threadu
sub wait {
	my $s = shift;		#WRONG?? - I always write $s instead of $self
	
	while (!$s->is_all_completed()) {
		sleep(1);		#WRONG - no parentheses, builtin
		$s->check_waiting();
	}
}

#da pocet bezicich threadu
sub get_curr_running {
	my $s = shift;
	
	#procisti zombiky
	my @threads = grep {$_->is_running()} @{$s->threads}; # WRONG - spaces
	$s->threads(\@threads);
	
	return scalar @threads;
}

#vrati 1, kdyz uz neni treba nic delat
sub is_all_completed {
	my $s = shift;
	
	return (($s->get_curr_running == 0) and (scalar @{$s->waiting_subs} == 0));
}

#kolik jeste muze bezet threadu?
sub how_many_free_to_run {
	my $s = shift;
	return ($s->size - $s->get_curr_running);
}

#spusti thread a prida ho do threads
sub add_to_threads {
	my $s = shift;
	my $sub = shift;
	
	my $thread = threads->new(sub {
		threads->detach();
		eval{$sub->();};
		if ($@) {
			say "Died with $@";
		}
	});
	
	push @{$s->threads}, $thread;
}

#zkontroluje, jestli neni mozne pridat nove thready
#(je spousteno casto)
sub check_waiting {
	my $s = shift;
	
	
	my $subs = $s->how_many_free_to_run();
	
	my $added=0;   #WRONG - spaces
	
	for (1..$subs) {
		if (scalar @{$s->waiting_subs} > 0) {
			$added=1;
			my $sub = shift @{$s->waiting_subs};
			$s->add_to_threads($sub);
		} 
	}
	
	#pokud jsem neco spustil, jdu to zkontrolovat znovu
	#(nekdy to napr. hned zemre)
	if ($added) {
		$s->check_waiting();
	} 
}

#"spusteni" == zarazeni na konec fronty
sub run {
	
	my $s = shift;
	
	my $sub = shift;
	
	
	push @{$s->waiting_subs}, $sub; # WRONG - spaces
	
	
	$s->check_waiting();
	
	
}

__PACKAGE__->meta->make_immutable;
