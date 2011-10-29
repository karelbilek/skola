package eva2010.cv1;

import org.jgap.FitnessFunction;
import org.jgap.Gene;
import org.jgap.IChromosome;

public class BitGAFitness extends FitnessFunction {

	private static final long serialVersionUID = 210164789836068426L;

	@Override
	protected double evaluate(IChromosome arg0) {
		
		double fitness = 0;
		
		int i = 0;
		for (Gene g : arg0.getGenes()) {
			i++;			
			if (g.getAllele().equals(i%2)) {
				fitness += 1.0;
			}
		}
		
		return fitness/arg0.getGenes().length;
	}

}
