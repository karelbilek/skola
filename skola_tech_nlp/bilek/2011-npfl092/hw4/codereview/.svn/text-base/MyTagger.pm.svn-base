#ZADANI:
#create a simple Perl module
#the module contains a function that expects an array of words as its argument and returns an array of their (guessed) part-of-speech tags, such as N for nouns, A for adjectives, etc.
#you can choose any language and any tagset
#the actual solution can be quite stupid (e.g. just a few regular expressions for typical word endings)
#the module must contain POD
#create a script test.pl for testing the module's functionality (for more advanced Perl programmers: use Test::More)	


#REVIEW: too long comments up there

package MyTagger;
use strict;
use warnings;
use diagnostics;
use utf8;

#REVIEW: I have to admit I don't like Exporter syntax very much, because I
#always lose my head in it, so I just copy-paste it from somewhere else when 
#I have to use it. I think this was copy-pasted too.
#
#Much saner option is to use Perl6::Export::Attrs .

require Exporter;
use vars	qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 0.01;

@ISA         = qw(Exporter);
@EXPORT      = qw(&tagWord &posTagger);
%EXPORT_TAGS = ( );


#REVIEW: in Best Practices, K&R indenting style is recommended
#REVIEW: in Best Practices, it is recommended to use 
#lowercase_with_underscores for names

#REVIEW: the posTagger name is quite unintuitive (what is posTagger? is it
#name of the class?)

sub posTagger
	{
        #REVIEW: tabs are used instead of spaces, can cause problems

        #REVIEW: it would be probably cleaner to use @sentence instead of 
        #@_

		#my @sentence = shift;				
				
		#return map {"$_ :: ". tagWord($_) }
		
        #REVIEW: this is very strange and looks confusing
        return map {tagWord($_) }
				@_;
	}


#REVIEW: it is good to keep constistent bracketing style.
#The first posTagger use { on newline, but tagWord uses { on the same line
sub tagWord{
        
        #REVIEW: the code leftovers in comments are really confusing

		#my $word = shift;
		my $tag;
		#push
						
		#more concrete:
		

        #REVIEW: this is basically undreadable (no offense)
        #much better would be using hash of some kind with
        #the regular expressions would be nice,  or even just 
        #the beginnings / endings would do
        #Also, this is almost a dictionary and probably would be better read
        #from external file.

		#PRONOUNS
		#1st singular - I
		if($_=~/^I$/){$tag="P";}
		elsif($_=~/^[M,m]e$/){$tag="P";}
		elsif($_=~/^[M,m]ine$/){$tag="P";} 
		elsif($_=~/^[M,m]y$/){$tag="P";} 
		#2nd singular - you
		elsif($_=~/^[Y,y]ou$/){$tag="P";}
		elsif($_=~/^[Y,y]ours$/){$tag="P";}
		elsif($_=~/^[Y,y]our$/){$tag="P";} 
		#3rd sg. - he
		elsif($_=~/^[H,h]e$/){$tag="P";}
		elsif($_=~/^[H,h]im$/){$tag="P";}
		elsif($_=~/^[H,h]is$/){$tag="P";} 
		#3rd sg. - she		
		elsif($_=~/^[S,s]he$/){$tag="P";}
		elsif($_=~/^[H,h]er$/){$tag="P";}
		elsif($_=~/^[H,h]ers$/){$tag="P";} 
		#3rd sg. - it		
		elsif($_=~/^[I,i]t$/){$tag="P";}
		elsif($_=~/^[I,i]ts$/){$tag="P";}
		#1st plural - we
		elsif($_=~/^[W,w]e$/){$tag="P";}
		elsif($_=~/^[O,o]ur$/){$tag="P";}
		elsif($_=~/^[O,o]urs$/){$tag="P";} 
		#2nd plural - the same as singular
		#3rd sg. - they
		elsif($_=~/[T,t]hey$/){$tag="P";}
		elsif($_=~/[T,t]hem$/){$tag="P";}
		elsif($_=~/[T,t]heir$/){$tag="P";} 
		elsif($_=~/[T,t]heirs$/){$tag="P";} 	
		elsif($_=~/[T,t]hat$/){$tag="P";} 			
		elsif($_=~/[T,t]his$/){$tag="P";}
		elsif($_=~/[T,t]hese$/){$tag="P";}
		elsif($_=~/[T,t]hose$/){$tag="P";}
		elsif($_=~/[W,w]hich$/){$tag="P";}
		elsif($_=~/[W,w]hose$/){$tag="P";}
		elsif($_=~/[W,w]hat$/){$tag="P";}
		elsif($_=~/[A,a]ny$/){$tag="P";}
		elsif($_=~/[n,N]one$/){$tag="P";}		
		elsif($_=~/[n,N]oone$/){$tag="P";}				
		elsif($_=~/[s,S]omeone$/){$tag="P";}				
		elsif($_=~/[h,H]ere$/){$tag="P";}
		elsif($_=~/[s,S]ome$/){$tag="P";}
		
		#VERBS
		#to be
		elsif($_=~/^[A,a]m$/){$tag="V";}
		elsif($_=~/^I'm$/){$tag="V";}
		elsif($_=~/^[A,a]re$/){$tag="V";}
		elsif($_=~/^[A,a]ren't$/){$tag="V";}
		elsif($_=~/^[I,i]s$/){$tag="V";}
		elsif($_=~/^[I,i]sn't$/){$tag="V";}
		elsif($_=~/^[W,w]as$/){$tag="V";}
		elsif($_=~/^[W,w]asn't$/){$tag="V";}
		elsif($_=~/^[B,b]een$/){$tag="V";}


		#to DO
		elsif($_=~/^[D,d]o$/){$tag="V";}
		elsif($_=~/^[D,d]on't$/){$tag="V";}
		elsif($_=~/^[D,d]oes$/){$tag="V";}
		elsif($_=~/^[D,d]oesn't$/){$tag="V";}
		#past of DO
		elsif($_=~/^[D,d]id$/){$tag="V";}
		elsif($_=~/^[D,d]idn't$/){$tag="V";}
		elsif($_=~/^[D,d]one$/){$tag="V";}			
		elsif($_=~/[p,P,Cl,cl,L,l]oses$/){$tag="V";}
		#may, should, could, would
		elsif($_=~/[s,S,c,C,w,W]ould$/){$tag="V";}
		elsif($_=~/[m,M]ay$/){$tag="V";}
		elsif($_=~/[m,M]ight$/){$tag="V";}
		elsif($_=~/[w,W]ill$/){$tag="V";}		
		#past participle
		#-ed
		elsif($_=~/[^ ]+[^ ]+ed$/){$tag="V";}
		elsif($_=~/[^ ]+[^ ]+nt$/){$tag="V";}#sent, lent, 
		elsif($_=~/[^ ]+[^ ]+ght$/){$tag="V";}#bought
		
		#*ry (cry,try,)
		elsif($_=~/[^ ]+ry$/){$tag="V";}
		
		#izes, ays, es
		elsif($_=~/[^ ]+[^ ]+es$/){$tag="V";}#criticizes
		elsif($_=~/[^ ]+[^ ]+ys$/){$tag="V";}#plays				
		elsif($_=~/[^ ]+[^ ]+lls$/){$tag="V";}#yells,tells
		elsif($_=~/[^ ]+[^ ]+ll$/){$tag="V";}#yells,tell	
		elsif($_=~/[^ ]+[^ ]+ear$/){$tag="V";}#appear, disappear,clear
		#seen,been
		elsif($_=~/[s,b]een$/){$tag="V";}
		
		#gerundiums (noun/verb/adjective)
		elsif($_=~/[^ ]+[^ ]+ing$/){$tag="Ger";}
		
		#ending not (cannot )
		elsif($_=~/not$/){$tag="V";}
		#ending n't
		elsif($_=~/[^ ]+n't$/){$tag="V";}
		#help,yelp
		elsif($_=~/[h,y]elp$/){$tag="V";}
		elsif($_=~/ure$/){$tag="V";}
		

		#prepositions
		elsif($_=~/^[O,o]ut$/){$tag="Prep";}
		elsif($_=~/[T,t]o$/){$tag="Prep";}
		elsif($_=~/^[O,o]f$/){$tag="Prep";}
		elsif($_=~/^[A,a]bout$/){$tag="Prep";}
		elsif($_=~/^[U,u]p$/){$tag="Prep";}
		elsif($_=~/^[I,i]n$/){$tag="Prep";}
		elsif($_=~/^[O,o]n$/){$tag="Prep";}
		
		
		#conj
		elsif($_=~/^[B,b]ut$/){$tag="Conj";}
		elsif($_=~/^[H,h]owever$/){$tag="Conj";}
		elsif($_=~/^[A,a]nd$/){$tag="Conj";}
		elsif($_=~/^[S,s]ince$/){$tag="Conj";}
		elsif($_=~/^[S,s]ince$/){$tag="Conj";}
		elsif($_=~/^[A,a]lso$/){$tag="Conj";}
		elsif($_=~/^[s,S]o$/){$tag="Conj";}
		elsif($_=~/^[i,I]f$/){$tag="Conj";}
		elsif($_=~/^[t,T,w,W]hen$/){$tag="Conj";}
			
		#articles
		elsif($_=~/^[T,t]he$/){$tag="Art";}
		elsif($_=~/^[A,a]$/){$tag="Art";}
		elsif($_=~/^[A,a]n$/){$tag="Art";}
		
		#nouns
		elsif($_=~/er$/){$tag="N";} #teacher
		elsif($_=~/or$/){$tag="N";} #actor
		elsif($_=~/ism$/){$tag="N";}
		elsif($_=~/asm$/){$tag="N";} 
		elsif($_=~/ist$/){$tag="N";} #activist
		elsif($_=~/ment$/){$tag="N";} #tournament
		elsif($_=~/tion$/){$tag="N";} #nation
		elsif($_=~/ee$/){$tag="N";} #employee
		elsif($_=~/ey$/){$tag="N";} #attorney
		elsif($_=~/oe$/){$tag="N";} #pottatoe
		elsif($_=~/ain$/){$tag="N";} #domain
		elsif($_=~/man$/){$tag="N";} #woman,man
#		elsif($_=~/ook$/){$tag="N";} #book,cook, - ambivalent (look)
		elsif($_=~/ight$/){$tag="N";} #sight
		elsif($_=~/gram$/){$tag="N";} #kilogram
		elsif($_=~/ample$/){$tag="N";} #sample,example
		elsif($_=~/[n,N,cl,Cl,r,R,d,D,]ose$/){$tag="N";}
		#elsif($_=~/and$/){$tag="N";}
		#elsif($_=~/ands$/){$tag="N";}
			
		#plurals
		elsif($_=~/ers$/){$tag="N";} #teachers
		elsif($_=~/ors$/){$tag="N";} #actors
		elsif($_=~/isms$/){$tag="N";} 
		elsif($_=~/asms$/){$tag="N";} 
		elsif($_=~/ists$/){$tag="N";} #activists
		elsif($_=~/ments$/){$tag="N";} #tournaments
		elsif($_=~/tions$/){$tag="N";} #nations
		elsif($_=~/ees$/){$tag="N";} #employees
		elsif($_=~/eys$/){$tag="N";} #attorneys
		elsif($_=~/oes$/){$tag="N";} #pottatoe
		elsif($_=~/ains$/){$tag="N";} #domains
		elsif($_=~/men$/){$tag="N";} #women,men
#		elsif($_=~/ook$/){$tag="N";} #book,cook, - ambivalent (look)
		elsif($_=~/ights$/){$tag="N";} #sights
		elsif($_=~/ses$/){$tag="N";}
		
		elsif($_=~/ly$/){$tag="Adv";}
		
		#PUNCTUATION
		elsif($_=~/^\.$/){$tag="Punc";}
		elsif($_=~/^\,$/){$tag="Punc";}		
		elsif($_=~/^\"$/){$tag="Punc";}
		elsif($_=~/^\!$/){$tag="Punc";}	
		elsif($_=~/^\?$/){$tag="Punc";}
		elsif($_=~/^\;$/){$tag="Punc";}
		elsif($_=~/^\:$/){$tag="Punc";}
		elsif($_=~/^[(,)]$/){$tag="Punc";}
		
		#adjectives typical -less, -able, -full
		elsif($_=~/full$/){$tag="Adj";}
		elsif($_=~/less$/){$tag="Adj";}
		elsif($_=~/able$/){$tag="Adj";}				
		
		else {$tag="undecided"};

        #REVIEW: I think the code above is correct, but it is hard to decide
	    
        #REVIEW: It would be better to just add something (say, N) instead of
        #"undecided", so it "looks" like a tag and has a slight chance to be
        #correct
		return $tag;
}


#REVIEW: Why is this here? It looks like a leftover from some copy-pasted
#code
END { }       # module clean-up code here (global destructor)

1;

#REVIEW: Example in POD would be nice.
#REVIEW: POD is, unfortunately, totally wrong. At least I think so.
#There should be =head1 Name, not =Name
#(pod2html doesn't like it, either)

=Name MyTagger (posTagger)
=Usage The usage is posTagger(@array).
=Description It takes an array of English words and returns their guessed Part Of Speech tags based on the word's endings as array. If no suitable ending is matching, value undecided is returned for the untagged word. The tagset is {P,V,Ger,Prep,Conj,Art,N,Adv,Punct,undecided} meaning pronouns, verbs, gerunds, prepositions, conjunctions, articles, nouns, adverbs, punctuation and words which didn't match any of my regular expressions.
Required arguments @array of English words.
=Options No options are available.
=Exit status is always normal.
=Author Tomáš Knopp
=Bugs and limitations This tagger is very very far from being a good English P.O.S. tagger.
