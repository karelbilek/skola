use 5.010;
use strict;
use warnings;
use Readonly;

Readonly my $sloveso => $ARGV[0];

Readonly my %type_for_line=> qw(
    1 id
    2 pattern
    3 sentence
    4 morphology
    5 dependencies
    6 named_entities
);

sub for_every_line {
    my @all_res;
    my $name = shift;
    my @subs = @_;
    open my $inf, "<", "data/development.instances/$name.txt";
    my $i = 1;
    my %object;
    while (my $line = <$inf>) {
        chomp $line;
        $line =~ s/^[^:]*:\s*//;
        my $line_number = $i % 7;
        if ($line_number) {
            $object{$type_for_line{$line_number}} = $line;
            if ($line_number == 2) {
                $object{pattern}=~s/\..*$//;
            }
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
                    my $object_morp = {
                        form=>$form,
                        lemma=>$lemma,
                        POS=>$POS
                    };
                    $object_morp;
                 } @split;
                $object{morphology_split} = \@words;
            }
            if ($line_number == 5) {
                my @split = split(/;/, $line);
                my @words = map{
                    my ($type, $head, $head_nu, $this, $this_nu) = 
                        $_ =~ /(.*)\((.*)-(.*?)'*, (.*)-(.*?)'*\)/;
                    my $object_dep = {
                        type=>$type,
                        head_word=>$head,
                        head_number=>$head_nu-1,
                        this_word=>$this,
                        this_number=>$this_nu-1
                    };
                    $object_dep;
                } @split;
                $object{dependencies_split} = \@words;
            }
        } else {
            my @line_res;
            push @line_res, $object{id};
            push @line_res, $object{pattern};
            my @nus = map {$_->(\%object)} @subs;
            if (scalar@nus != scalar @subs) {
                die "Something fishy at sentence number ".$object{id};
            }
            push @line_res, @nus;
            push @all_res, \@line_res;
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
    return @all_res;
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
    return ["is_modality_$type", 
        dependency_has('aux\('.$sloveso.'-\d+, ('.$regex.')')];
}

#FEATURE()
sub is_passive {
    return ["is_passive",
        dependency_has('auxpass\('.$sloveso.'-')]; 
}

#FEATURE()
sub is_negation {
    return ["is_negation",
        dependency_has('neg\('.$sloveso.'-')];
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
    return sub{return exists $types_hash{$_[0]->{POS}}};
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
    return ["is_to_be_around_$away",
        check_morph_words_around($away, sub{$_[0]->{lemma} eq  "be"})];
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
    return ["is_tense_$tense_type_number",
        check_type_of_words_around(0, $type)];
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
    return ["is_POS_around_$how_far_away"."_$POS_type_number",
        check_type_of_words_around($how_far_away, @$type_ref)];
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
            return $binary?0:q(NONE);
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
sub present_subject {
    my $type_number = shift;
    my $type = ($type_number == 1)? "(n|x)subj|agent":"(c|x)subj|agent";
    return ["present_subject_$type_number",
      do_something_with_dependent(sub{
        my $word = shift;
        my $is = is_word_nominal($word);
        if ($type_number == 1) {
             return $is?1:0;
        } else {
             #this could be done by some logical operator, but this is cleaner
             #I think
             return $is?0:1;
        }
    }, $type, 1)];
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
    return ["plural_subject", 
        check_if_dependent_is_plural( "subj")];
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
    return ["present_object_$type_number",
        simple_dependent_check($object_types{$type_number})];
}

#FEATURE()
sub plural_object {
    return ["plural_object",
        check_if_dependent_is_plural($object_types{7})];
}

#FEATURE()
sub particle_word {
    my $type = "prt";
    return ["particle_word", word_as_category($type)];
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
    return ["present_adverbial_$type_number", 
        simple_dependent_check($adverbial_types{$type_number})]; 
}

Readonly my %adverbial_categorical_types => qw(
    1 ^prep$
    2 ^mark$
);
#FEATURE(1..2)
sub adverbial_word {
    my $type_number = shift;
    return ["adverbial_word_$type_number",
        word_as_category($adverbial_categorical_types{$type_number})];
}

#FEATURE()
sub prepc{
    return ["prepc", do_something_with_dependent( sub{
        my $type_found = $_[0]->{dependency}->{type};
        $type_found =~ s/prepc_//;
        return $type_found;
    }, "prepc_", 0)];
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
    return ["nominal_s_class_$class", 
        nominal_class_of_type($class, "(n|x)subj|agent")]; 
}

#FEATURE(1..50)
sub nominal_object_class {
    my $class = shift;
    return ["nominal_o_class_$class", 
        nominal_class_of_type($class, $object_types{7})]; 
}
#FEATURE(-1..1 \0, 1..50)
sub around_class {
    my $away = shift;
    my $class = shift;
    return ["around_class_$away"."_$class",
     check_morph_words_around($away, sub{
        my $morph = shift;
        if ($morph->{POS} !~ /^N/) {
            return 0;
        }
        return semantic_class_equals($morph->{lemma}, $class);
    })];
}

#vraci featury jako funkce
sub all_features {
    my @res;
    push (@res, is_modality(1), is_modality(2));
    push (@res, is_passive);
    push (@res, is_negation);
    push (@res, map {is_to_be_around($_)} (-3..3));
    push (@res, map {is_tense($_)} (1..5));
    for my $i ((-3..-1), (1..3)) {
        for my $j (1..8) {
            push (@res, is_POS_around($i, $j));
        }
    }
    push(@res, map {present_subject($_)} (1..2));
    push(@res, plural_subject);
    push(@res, map {present_object($_)} (1..7));
    push(@res, plural_object);
    push(@res, particle_word);
    push(@res, map {present_adverbial($_)} (1..4));
    push(@res, map {adverbial_word($_)}(1..2));
    push(@res, prepc);
    push (@res, map {nominal_subject_class($_)}(1..50));
    push (@res, map {nominal_object_class($_)}(1..50));
    push (@res, map {around_class(1,$_)}(1..50)); 
    push (@res, map {around_class(-1,$_)}(1..50));
    return @res;
}

my @r = all_features;
my @head = ("", "semantic_class");

        #nemuze mit minus v nazvu sloupce
for(@r){
    $_->[0]=~s/-/m/g;
    push (@head, $_->[0])
};

#ted pro kazdou radku spustim spravne funkce
#(pri tom ctu soubor)
my @res = for_every_line($sloveso, map {$_->[1]} @r);

#najit ty, co se nebudou brat, protoze jsou vsude stejne
my %not_printing;
for my $column (2..$#head) {
    my $first_found = $res[0]->[$column];
    my $is_different=0;
    ROWS:
    for my $row (0..$#res) {
        if ($res[$row]->[$column] ne $first_found) {
            $is_different=1;
            last ROWS;
        }
    }
    if (!$is_different) {
        $not_printing{ $column }=1;
    }
}

#udelat z nebinarnich binarni
if (($ARGV[1]//"") eq "binary") {
    COLUMN:
    for my $column(2..$#head) {
        #zjednodusene - pokud mam ve sloupci v prvnim radku 1 ci 0
        #je to binarni, pokud ne, neni -> musim z toho udelat binarni
        #sloupecky
        my $first_found = $res[0]->[$column];
        if ($first_found ne "0" and $first_found ne "1") {
            #jsem tady <= neni to binarni
            my $original_feature_name = $head[$column];
            my %values;
            for my $row (0..$#res) {
                $values{ $res[$row]->[$column] } = undef;
            }
            my @new_features = keys %values;
            next COLUMN if (scalar @new_features == 1);
            
            for my $new_feature (@new_features) {
                for my $row (0..$#res) {
                    if ($res[$row]->[$column] eq $new_feature) {
                        push @{$res[$row]}, 1;
                    } else {
                        push @{$res[$row]}, 0;
                    }
                }

                my $name = $original_feature_name."_".$new_feature;
                push @head, $name;
            }

            $not_printing{ $column } = 1;
            
        }
    }
}

for my $column (0..$#head) {
    if (!exists $not_printing{$column}){
        print $head[$column]."\t";
    }
}
print "\n";

use List::Util qw(shuffle);
@res = shuffle(@res);

for my $row (0..$#res) {
    for my $column (0..$#head) {
        if (!exists $not_printing{$column}){
            print $res[$row]->[$column]."\t";
        }
    }
    print "\n";
}

my $count = 283 - scalar keys %not_printing;
use File::Slurp;
write_file("current_results/feature_count", $count);
