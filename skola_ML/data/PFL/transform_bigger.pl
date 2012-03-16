use 5.010;
use strict;
use warnings;
use Readonly;

Readonly my $sloveso => $ARGV[0];
Readonly my $treshold => $ARGV[1];
Readonly my $paral => $ARGV[2];
Readonly my $binary_as_YESNO => (($ARGV[3] || "") eq "yes");

Readonly my @row_poradi => qw(143 146 213 135 22 106 74 100 192 120 169 195 2
87 10 36 104 39 37 208 248 45 91 221 218 202 190 172 184 215 239 170 44 49 26
134 182 154 51 231 70 223 48 183 168 35 132 209 62 121 102 110 148 52 142 25
60 12 194 153 1 205 158 160 174 210 152 235 6 73 242 3 249 33 31 101 40 177
186 127 11 56 79 224 207 42 88 30 216 53 80 117 243 98 125 175 149 237 71 16
140 46 118 228 245 96 137 112 28 136 97 187 161 220 5 240 180 164 54 47 24 238
147 19 176 50 212 131 166 84 133 124 99 232 89 38 78 234 200 23 206 138 94 76
95 119 8 116 204 0 165 141 201 15 214 14 109 92 67 7 167 58 189 244 115 41 191
18 173 222 247 86 111 236 83 199 90 197 227 108 34 43 246 4 219 226 61 75 65
229 69 171 211 17 139 185 113 72 9 163 196 103 68 217 193 155 13 129 225 157
114 107 178 66 55 21 188 123 159 85 241 63 128 59 82 181 64 145 126 57 198 203
179 77 144 29 130 151 233 150 32 122 27 105 156 162 93 81 20 230);
Readonly my %row_poradi => map {($_ => $row_poradi[$_])} @row_poradi; 

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
                if ($object{pattern} eq "u" or $object{pattern} eq "x") {
                    $object{pattern} = "ux";
                }
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
                    $form =~ s/^&(.*);$/$1/;
                    $lemma =~ s/^&(.*);$/$1/;
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
                    }
                    ;
                    if (defined
                            $object{morphology_split}[
                                $object_dep->{this_number}
                            ]) {
                        $object_dep;
                    } else {
                        ();
                    }
                } @split;
                $object{dependencies_split} = \@words;
            }
            if ($line_number == 6) {
               #hack - je tam jednou : => je tam aspon jedna entita
               if ($line =~ /:/) {
                    $object{has_named_entity} = 1;
                    my @NEs = split (/;/, $line);
                    my @object_NEs;
                    for my $NE (@NEs) {
                        my ($entity, $description) = split (/:/, $NE);
                        push @object_NEs, 
                            {entity=>$entity,
                            type=>$description};
                    }
                    $object{NE_split} = \@object_NEs;
               } else {
                    $object{has_named_entity} = 0;
                    $object{NE_split} = [];
               }
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

sub do_with_morph_words_around {
    my $away = shift;
    my $sub = shift;
    my $binary = shift;
    return sub {
        my $obj = shift;
        my $wanted_word_morph;
        if ($obj->{verb_number} + $away >= 0 and 
            $obj->{verb_number} + $away < scalar @{$obj->{morphology_split}}){
            
            $wanted_word_morph = $obj->{ morphology_split }->
                        [$obj->{verb_number}+$away]
        } else {
           return $binary? 0 : q(NONE);
        }
        my $res = $sub->($wanted_word_morph);
        if ($binary) {
           return ($res)?1:0;
        }
        return $res;
    }

}

sub check_morph_words_around {
    my $away = shift;
    my $sub = shift;
    return do_with_morph_words_around($away, $sub, 1);
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
   # 4 => [qw(MD)],
    5 => [qw(RB RBR RBS RP IN)],
  #  6 => [qw(TO)],
    7 => [qw(WDT WP WP$)],
  #  8 => [qw(WRB)]
);
#FEATURE(-3..3\0, 1..8);
sub POS_around{
    my $away = shift;
    return ["POS_around_$away",
        do_with_morph_words_around($away, sub{return $_[0]->{POS}})];
}

#FEATURE(-?..?);
sub is_POS_around{
    my $how_far_away = shift;
    my $POS_type_number = shift;
    my $type_ref = $POS_type_refs{$POS_type_number};
    return ["is_POS_around_$how_far_away"."_$POS_type_number",
        check_type_of_words_around($how_far_away, @$type_ref)];
}

sub do_something_with_all_dependent {
    my $what_do = shift;
    my $binary = shift;
    return sub {
        my $obj = shift;
        my @dependent = grep {$_->{head_number} eq $obj->{verb_number}}
            @{$obj->{dependencies_split}};
        if (!scalar @dependent) {
            return $binary?0:q(NONE);
        } else {
         #   my $result = "";
            my @results;

            for my $d (@dependent) {
                my $number = $d->{this_number};
                
                my $dep_word_as_object = {
                    morphology => $obj->{morphology_split}->[$number],
                    dependency => $d
                };
                    
                push (@results, $what_do->($dep_word_as_object)); 
            }
            
            if ($binary) {
                for (@results) {return 1 if ($_ == 1);}
                return 0;
            } else {
                my $res = join "", @results;
                if ($res eq "") {return "NONE"} else {return $res}
            }
        }
    }
}

sub do_something_with_dependent {
    my $what_do = shift;
    my $filter = shift;
    my $binary = shift;
    return do_something_with_all_dependent(sub{
        my $word_as_object = shift;
        if ($word_as_object->{dependency}->{type} =~ /$filter/) {
            return $what_do->($word_as_object);
        } else {
            if ($binary) {
                return 0;
            } else {
                return "";
            }
        }
    }, $binary);
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
    if (!defined $word->{morphology}{POS}) {
        use Data::Dumper;
        print Dumper($word);
        
        die ":-/";
        
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

sub is_word_nominal_class{
   my $word = shift;
   my $class = shift;
    if (is_word_nominal($word)) {
        return semantic_class_equals($word->{morphology}->{lemma}, $class);
    } else {
        return 0;
    }
}

sub nominal_class_of_type {
    my $class = shift;
    my $type = shift;
    return do_something_with_dependent(sub{
        my $word = shift;
        return is_word_nominal_class($word, $class);
    }, $type, 1); 

}

#FEATURE(1..50)
sub any_dependent_class {
    my $class = shift;
    return ["any_dep_class_$class", do_something_with_all_dependent(sub {
        my $word = shift;
        return is_word_nominal_class($word, $class);
    }, 1)];
}

#FEATURE(1..50)
sub nominal_subject_class {
    my $class = shift;
    return ["nominal_s_class_$class", 
        nominal_class_of_type($class, "(n|x)subj|agent")]; 
}


#FEATURE(1..50)
sub has_named_entity  { 
    return ["has_named_entity", 
        sub{my $obj = shift; return $obj->{has_named_entity}}]; 
}

#FEATURE(A..Z)
sub has_named_entity_of_type {
    my $type = shift;
    return ["has_named_entity_type_$type", 
        sub{
            my $obj = shift;  
            for my $NE (@{$obj->{NE_split}}) {
                if ($NE->{type} eq $type) {
                    return 1;
                }
            }
            return 0;
        }]; 
}

#FEATURE(1..50)
sub nominal_object_class {
    my $class = shift;
    return ["nominal_o_class_$class", 
        nominal_class_of_type($class, $object_types{7})]; 
}
#FEATURE(-?..? \0, 1..50)
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

#FEATURE(1..?)
sub sentence_part {
    my $divisor = shift;
    return ["sentence_part_$divisor", sub {
        my $object = shift;
        my $part = int ( $object->{verb_number} / $divisor);
        return $part + 2; 
        #+2 proto, abych si pozdeji nemyslel, ze je to binarni
    }];
}

#FEATURE(1..?)
sub sentence_length {
    my $divisor = shift;
    return ["sentence_len_$divisor", sub {
        my $object = shift;
        my $part = int ( scalar(@{$object->{morphology_split}}) / $divisor);
        return $part + 2; 
        #+2 proto, abych si pozdeji nemyslel, ze je to binarni
    }];
}

#FEATURE(-?..+?)
sub lemma_at_position {
    my $position = shift;
    return ["lemma_at_$position", sub {
        my $object = shift;
        return lc($object->{morphology_split}->[$position]->{lemma});
    }];
}

#FEATURE(-?..+?)
sub POS_at_position {
    my $position = shift;
    return ["POS_at_$position", sub {
        my $object = shift;
        return $object->{morphology_split}->[$position]->{POS};
    }];
}

#vraci featury jako funkce
sub all_features {
    my @res;
    push (@res, is_modality(1), is_modality(2));
    push (@res, is_passive);
    push (@res, is_negation);

    #zmena
    push (@res, map {is_to_be_around($_)} (-6..6));
    push (@res, map {is_tense($_)} (1..5));

    #zmena
    for my $i ((-6..-1), (1..6)) {
        for my $j (1,2,3,5,7) {
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
    
    
    #======nove====
    
    push (@res, has_named_entity);
    push (@res, map {has_named_entity_of_type($_)} ('A'..'Z'));
    
    push (@res, map {any_dependent_class($_)}(1..50));
    push (@res, map {around_class(2,$_)}(1..50)); 
    push (@res, map {around_class(-2,$_)}(1..50));
    push (@res, map {around_class(3,$_)}(1..50)); 
    push (@res, map {around_class(-3,$_)}(1..50));
    push (@res, map {around_class(4,$_)}(1..50)); 
    push (@res, map {around_class(-4,$_)}(1..50));
    push (@res, map {around_class(5,$_)}(1..50)); 
    push (@res, map {around_class(-5,$_)}(1..50));
    push (@res, map {around_class(6,$_)}(1..50)); 
    push (@res, map {around_class(-6,$_)}(1..50));

    push(@res, map {sentence_part($_)}(5,10,15));
    push(@res, map {sentence_length($_)}(5,10,15));

    push(@res, map {lemma_at_position($_)}(-1));
    push(@res, map {POS_at_position($_)}(1));
 
    for my $i ((-6..-1), (1..6)) {
            push (@res, POS_around($i));
    }
 
    return @res;
}

my @r = all_features;
my @head = ("", "semantic_class");

        #nemuze mit minus v nazvu sloupce
for(@r){
    push (@head, $_->[0])
};

#ted pro kazdou radku spustim spravne funkce
#(pri tom ctu soubor)
my @res = for_every_line($sloveso, map {$_->[1]} @r);

my %not_printing;

#udelat z nebinarnich binarni
if (1 or ($ARGV[1]//"") eq "binary") {
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
            @values{ map {$res[$_][$column] } (0..$#res) } = ();
           
            my @new_features = keys %values;
            if (scalar @new_features == 1) {
                $not_printing{ $column } = 1;
                next COLUMN;
            }
            
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

#najit ty, co se nebudou brat, protoze jsou vsude stejne
COLUMN:
for my $column (2..$#head) {
    next COLUMN if ($not_printing{$column});
    
    my %values;

    @values{ map {$res[$_][$column] } (0..$#res) } = ();
    if (scalar keys %values == 1) {
        $not_printing{ $column } = 1;
        next COLUMN;
    }

    #pouzito mene, nez 1x -> pryc!
   
    
    #kolikrat pouzita 1?
    my $one_used = scalar grep {$res[$_][$column]} (0..$#res); 
   
    #kolikrat pouzita 0?

    my $zero_used = (scalar @res) - $one_used;

    my $diff = abs($zero_used - $one_used);

    if ($one_used < $treshold or $zero_used < $treshold ) {
        $not_printing{ $column } = 1;
        next COLUMN;
    } 
}


for my $column (0..$#head) {
    if (!exists $not_printing{$column}){
        my $r = $head[$column];
        $r=~s/-/m/g;
        $r=~s/'/ap/g;
        $r=~s/,/carka/g;
        $r=~s/\$/dolr/g;
        $r=~s/:/dtecka/g;
        $r=~s/\./tecka/g;
        $r=~s/\?/otaz/g;
        $r=~s/\(/zavl/g;
        $r=~s/;/stred/g;
        $r=~s/\)/zavp/g;
        $r=~s/`/zpap/g;
        print $r."\t";
    }
}

print "\n";

for my $cycle_row (0..$#res) {
    my $row = $row_poradi{$cycle_row};
    if (!defined $row) {die "AAAA!!"};

    for my $column (0..$#head) {
        if (!exists $not_printing{$column}){
            if ($binary_as_YESNO and $column>=2) {
                my $yesno = $res[$row]->[$column] ? "YES" : "NO"; 
                print $yesno."\t";
            } else {
                print $res[$row]->[$column]."\t";
            }
        }
    }
    print "\n";
}

my $count = -1 + $#head - scalar keys %not_printing ;
use File::Slurp;
write_file("current_results/feature_count_$paral", $count);

