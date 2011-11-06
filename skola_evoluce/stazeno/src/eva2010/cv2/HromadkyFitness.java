package eva2010.cv2;

import java.util.Vector;


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
		
		double[] vahy = new double[K];
		
		for (int i = 0; i < aSubject.getGenes().length; i++) {
			Gene g = aSubject.getGene(i);
			
			vahy[(Integer)g.getAllele()] += weights.get(i);
		}
		
		double min = Integer.MAX_VALUE;
		double max = Integer.MIN_VALUE;
		for (int i = 0; i < K; i++) {
			if (vahy[i] < min) 
				min = vahy[i];
			if (vahy[i] > max)
				max = vahy[i];
		}
		
		aSubject.setApplicationData(new Double(max - min));
		
		return 1/(max - min);
	}

}
