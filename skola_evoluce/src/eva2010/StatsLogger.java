package eva2010;

import java.io.IOException;
import java.io.OutputStreamWriter;

import org.jgap.Genotype;
import org.jgap.IChromosome;

public class StatsLogger {
	
	public static void log(Genotype pop, OutputStreamWriter out) {
		
		double bestFitness = pop.getFittestChromosome().getFitnessValue();
		
		double fitnessSum = 0;
		for (IChromosome ch : pop.getPopulation().getChromosomes()) {
			fitnessSum += ch.getFitnessValue();
		}
		
		double averageFitness = fitnessSum/pop.getConfiguration().getPopulationSize();
		
		try {
			out.write("" + bestFitness + " " + averageFitness + System.getProperty("line.separator"));
		}
		catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	

}
