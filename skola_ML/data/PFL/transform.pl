use 5.010;
use strict;
use warnings;
use Readonly;

Readonly my $sloveso => "arrive";

Readonly my %type_for_line=> qw(
    1 id
    2 pattern
    3 sentence
    4 morphology
    5 dependencies
    6 named_entities
);

sub for_every_line {
    my $name = shift;
    my $sub = shift;
    my $at_the_end = shift;
    open my $inf, "<", "data/development.instances/$sloveso.txt";
    my $i = 1;
    my %object;
    while (my $line = <$inf>) {
        chomp $line;
        $line =~ s/^[^:]*:\s*//;
        my $line_number = $i % 7;
        if ($line_number) {
            $object{$type_for_line{$line_number}} = $line;
            if ($line_number == 3) {
                my @split = split (/ /, $line);
                my $verb_nu;
                for my $i (0..$#split) {
                    if ($split[$i] =~ /</) {
                        $verb_nu = $i;
                        $split[$i] =~ s/[<>]//g;
                    }
                }
                $object{sentence_split} = \@split;
                $object{verb_number} = $verb_nu;
            }
            if ($line_number == 4) {
                my @split = split(/\t/, $line);
                my @words = map {
                    my ($form, $lemma, $POS) = split(/ /, $_);
                    my $object = {
                        form=>$form,
                        lemma=>$lemma,
                        POS=>$POS
                    };
                    $object;
                 } @split;
                $object{morphology_split} = \@words;
            }
            if ($line_number == 5) {
                my @split = split(/;/, $line);
                my @words = map{
                    my ($type, $head, $head_nu, $this, $this_nu) = 
                        $_ =~ /(.*)\((.*)-(.*?)'?, (.*)-(.*?)'?\)/;
                    my $object = {
                        type=>$type,
                        head_word=>$head,
                        head_number=>$head_nu-1,
                        this_word=>$this,
                        this_number=>$this_nu-1
                    };
                    $object;
                } @split;
                $object{dependencies_split} = \@words;
            }
        } else {
            my $res = $sub->(\%object);
            if (!defined $res) {
                die "Not defined at sentence number ".$object{id};
            }
            say $res;
            #say $object{dependencies};
            #say $object{verb_number};
            #say $object{sentence};
            #say $object{morphology};
            #say "-----------------------------------------";
            %object = ();
        }
    } continue {
        $i++;
    }
    if (defined $at_the_end) {
        $at_the_end->();
    }
}

sub dependency_has {
    my $what = shift;
    return sub{
        my $obj = shift;
        if ($obj->{dependencies}=~/($what)/) {
            return 1;
        } else {
            return 0;
        }
    }
}

#FEATURE(1..2)
sub is_modality {
    my $type = shift;
    my $regex = ($type == 1) ? 
        ('would|should') :
        ('can|could|may|must|ought|might');
    return dependency_has('aux\('.$sloveso.'-\d+, ('.$regex.')');
}

#FEATURE()
sub is_passive {
    return dependency_has('auxpass\('.$sloveso.'-'); 
}

#FEATURE()
sub is_negation {
    return dependency_has('neg\('.$sloveso.'-');
}

sub is_infinite_phrase {
    return dependeny_has('xcomp\([^-]*-\d+, '.$sloveso);
}


sub check_morph_words_around {
    my $away = shift;
    my $sub = shift;
    return sub {
        my $obj = shift;
        my $wanted_word_morph;
        if ($obj->{verb_number} + $away >= 0 and 
            $obj->{verb_number} + $away < scalar @{$obj->{morphology_split}}){
            $wanted_word_morph = $obj->{ morphology_split }->
                        [$obj->{verb_number}+$away]
        } else {
           return 0;
        }          
        return ($sub->($wanted_word_morph))?1:0;
    }
}

sub check_type {
    my @types = @_;
    my %types_hash; @types_hash{@_}=();
    return sub{return exists $types_hash{$_->{POS}}};
}

sub check_type_of_words_around {
    my $away = shift;
    my @types = @_;
    return check_morph_words_around($away, check_type(@types));
}

#FEATURE(-3..3)
sub is_to_be_around {
    my $away = shift;
    my @types = @_;
    return check_morph_words_around($away, sub{$_->{lemma} eq  "be"});
}


Readonly my %tense_types => qw (
    1 VBN
    2 VBD
    3 VBG
    4 VBP
    5 VB
);
#FEATURE(1..5)
sub is_tense {
    my $tense_type_number=shift;
    my $type = $tense_types{$tense_type_number};
    return check_type_of_words_around(0, $type);
}

Readonly my %POS_type_refs => (
    1 => [qw(NN  NNS  NNP NNPS DT PDT PRP PRP$ POS CD)],
    2 => [qw(JJ JJR JJS)],
    3 => [qw(VB VBD VBG VBN VBP VBZ)],
    4 => [qw(MD)],
    5 => [qw(RB RBR RBS RP IN)],
    6 => [qw(TO)],
    7 => [qw(WDT WP WP$)],
    8 => [qw(WRB)]
);
#FEATURE(-3..3\0, 1..8);
sub is_POS_around{
    my $how_far_away = shift;
    my $POS_type_number = shift;
    my $type_ref = $POS_type_refs{$POS_type_number};
    return check_type_of_words_around($how_far_away, @$type_ref);
}

sub do_something_with_dependent {
    my $what_do = shift;
    my $filter = shift;
    my $binary = shift;
    return sub {
        my $obj = shift;
        my @dependent = grep {$_->{head_number} eq $obj->{verb_number}}
            @{$obj->{dependencies_split}};
        my @filtered = grep {$_->{type}=~/$filter/} @dependent;
        if (!scalar @filtered) {
            return $binary?0:"NONE";
        } else {
            my $filtered_number = $filtered[0]->{this_number};
            my $dep_word_as_object = {
                morphology => $obj->{morphology_split}->[$filtered_number],
                dependency => $filtered[0]
            };
            return $what_do->($dep_word_as_object);
        }
    }
}

sub is_word_nominal {
    my $word = shift;
    if (defined $word->{dependency}) {
        if ($word->{dependency}->{type} eq "nsubj") {
            return 1;
        }
        if ($word->{dependency}->{type} eq "csubj") {
            return 0;
        }
    }
    my $number_pro_noun = $word->{morphology}{POS}=~ /^(NN|CD|WDT|WP)/;
    return $number_pro_noun;
}
#FEATURE(1..2)
sub presence_subject {
    my $type_number = shift;
    my $type = ($type_number == 1)? "(n|x)subj|agent":"(c|x)subj|agent";
    return do_something_with_dependent(sub{
        my $word = shift;
        my $is = is_word_nominal($word);
        if ($type_number == 1) {
             return $is?1:0;
        } else {
             #this could be done by some logical operator, but this is cleaner
             #I think
             return $is?0:1;
        }
    }, $type, 1);
}

sub check_if_dependent_is_plural {
    my $type = shift;
    return do_something_with_dependent(sub{
        return ($_[0]->{morphology}->{POS}=~/^NNP?S$/)?1:0;
    }, $type, 1);
}

sub simple_dependent_check {
    my $what = shift;
    return 
        do_something_with_dependent(sub{1}, $what, 1);
}

sub word_as_category {
    my $what = shift;
    return do_something_with_dependent(
        sub{lc($_[0]->{dependency}->{this_word})}, $what, 0);
}

#FEATURE()
sub plural_subject {
    return check_if_dependent_is_plural( "subj");
}

my %object_types = qw(
    1 dobj
    2 iobj
    3 nsubjpass
    4 csubjpass
    5 ccomp
    6 complm
);
$object_types{7}='('.join("|",@object_types{1..6}).')';


#FEATURE(1..7)
sub present_object {
    my $type_number = shift;
    return simple_dependent_check($object_types{$type_number});
}

#FEATURE()
sub plural_object {
    return check_if_dependent_is_plural($object_types{7});
}

#FEATURE()
sub particle_word {
    my $type = "prt";
    return word_as_category($type);
}

Readonly my %adverbial_types => qw (
    1 advmod
    2 advcl
    3 purpcl
    4 tmod
);
#FEATURE(1..4)
sub present_adverbial {
    my $type_number = shift;
    return simple_dependent_check($adverbial_types{$type_number}); 
}

Readonly my %adverbial_categorical_types => qw(
    1 ^prep$
    2 ^mark$
);
#FEATURE(1..2)
sub adverbial_word {
    my $type_number = shift;
    return word_as_category($adverbial_categorical_types{$type_number});
}

#FEATURE()
sub prepc{
    return do_something_with_dependent( sub{
        my $type_found = $_[0]->{dependency}->{type};
        $type_found =~ s/prepc_//;
        return $type_found;
    }, "prepc_", 0);
}

my %_semantic_class_of;
sub semantic_class_of {
    my $what = shift;
    if (!scalar keys %_semantic_class_of) {
        open my $inf, "<", "data/semantic-classes.wn.txt";
        my $last_category=0;
        while (my $line = <$inf>) {
            chomp($line);
            if ($line =~ /CATEGORY/) {
                $last_category++;
            } else {
                $_semantic_class_of{$line} = $last_category;
            }
        }
        close $inf;
    }
    return $_semantic_class_of{$what};
}
sub semantic_class_equals {
    my $lemma = shift;
    my $class = shift;
    return ((semantic_class_of($lemma)//0) == $class)?1:0;
}

sub nominal_class_of_type {
    my $class = shift;
    my $type = shift;
    return do_something_with_dependent(sub{
        my $word = shift;
        if (is_word_nominal($word)) {
            return semantic_class_equals($word->{morphology}->{lemma}, $class);
        } else {
            return 0;
        }
    }, $type, 1); 
}

#FEATURE(1..50)
sub nominal_subject_class {
    my $class = shift;
    return nominal_class_of_type($class, "(n|x)subj|agent"); 
}

#FEATURE(1..50)
sub nominal_object_class {
    my $class = shift;
    return nominal_class_of_type($class, $object_types{7}); 
}
#FEATURE(-1..1 \0, 1..50)
sub around_class {
    my $away = shift;
    my $class = shift;
    return check_morph_words_around($away, sub{
        my $morph = shift;
        if ($morph->{POS} !~ /^N/) {
            return 0;
        }
        return semantic_class_equals($morph->{lemma}, $class);
    });
}

#for_every_line($sloveso, words_around(0, "VB"));
for_every_line($sloveso, around_class(-1, 49));


