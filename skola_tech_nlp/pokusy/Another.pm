sub get_statistics {
	my $s=new Zpravostroj::AllDates();
	my $name = shift;
	my $subref = shift;
	my $size_days = shift;
	my $size_articles = shift;
	
	my $allcounter = new Zpravostroj::OutCounter(name=>"data/allresults/$name");
	
	$s->traverse(sub{
		my $d = shift;
		
		
		my $hash = $d->get_statistics($size_articles, $subref, $name);
		
		
		$allcounter->add_hash($hash);
		
		return ();
	},$size_days);
	
	$allcounter->count_and_sort_it();
}

