pokus <- function() {
	for (i in (1:4)) {
		x<-sample(1:6,1);
		if (x==6) {
			return(1);
		}
	} 
	return(0);
	}


pokusu<-500000;
dobre <- 0;

for (i in 1:pokusu) {
	if (pokus()==1) {
		dobre<-dobre+1;
	}
}

dobre/pokusu;
1-(5/6)^4


