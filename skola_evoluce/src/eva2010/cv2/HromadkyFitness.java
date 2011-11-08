package eva2010.cv2;

import java.util.Vector;
import java.util.Arrays;

import org.jgap.FitnessFunction;
import org.jgap.Gene;
import org.jgap.IChromosome;

public class HromadkyFitness extends FitnessFunction {


	private static final long serialVersionUID = 3635743112978793713L;

	Vector<Double> weights;
	int K;
 	
	public HromadkyFitness(Vector<Double> weights, int K) {
		this.weights = weights;
		this.K = K;
	}


		
	
	@Override
	protected double evaluate(IChromosome aSubject) {
		
		double sumVahy = 0;
		double[] vahy = new double[K];
		
		for (int i = 0; i < aSubject.getGenes().length; i++) {
			Gene g = aSubject.getGene(i);
			double vaha = weights.get(i);

			sumVahy+=(Double)vaha;
			vahy[(Integer)g.getAllele()] += vaha;
		}
			
		double min = Integer.MAX_VALUE;
		double max = Integer.MIN_VALUE;

		Arrays.sort(vahy);

		double dev = 0;
		double prumer = sumVahy/(double)K;

		double rozdil=0;
		
		for (int i = 0; i < K; i++) {
			if (vahy[i] < min) 
				min = vahy[i];
			if (vahy[i] > max)
				max = vahy[i];
			dev += (vahy[i]-prumer)*(vahy[i]-prumer);
			if (i!=K-1) {
				rozdil += vahy[i+1]/vahy[i];
			}
		}
		dev = Math.sqrt(dev/K);
		rozdil = rozdil / K;

		aSubject.setApplicationData(new Double(max - min));
	
		//double pokus = 100000 - new Double(max-min);return pokus;
		//return (10000-dev < 0) ? 0 : 10000-dev;
		return 1/dev;
	}

}
