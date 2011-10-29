package eva2010;

import java.io.*;
import java.util.Vector;

import org.jgap.Genotype;
import org.jgap.IChromosome;

//vyrazne jsem si ho prepsal, aby se mi vic libil :)
//dela vsechno, co ma co do cineni se zapisem vysledku, tj. i resulty

public class StatsLogger {

	String logFilePrefix;
	String resultsFileName;
	int repeats=0;

	OutputStreamWriter outputFile;

	public StatsLogger(String logFilePrefix, String resultsFileName) {
		this.logFilePrefix = logFilePrefix;
		this.resultsFileName = resultsFileName;
	}

	public void setRun(int what) throws IOException {
		repeats=Math.max(what+1, repeats);
		
		try {	
			outputFile = new OutputStreamWriter(new FileOutputStream(logFilePrefix + "." + what));
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	public void closeRun()  {
		try {
			outputFile.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void writeResults(int maxGen) {
		try {
			Vector<Vector<Double>> bestFitnesses = loadBestFitnesses(repeats);
			writeGenStatistics(bestFitnesses, repeats, maxGen);	
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public Vector<Vector<Double>> loadBestFitnesses(int repeats) throws IOException {
		Vector<Vector<Double>> bestFitnesses = new Vector<Vector<Double>>();
	
		for (int i = 0; i < repeats; i++) {
			Vector<Double> column = new Vector<Double>();
			
			BufferedReader in = new BufferedReader(new FileReader(logFilePrefix + "." + i));
			String line = null;
			while ((line = in.readLine()) != null) {
				double best = Double.parseDouble(line.split(" ")[0]);
				column.add(best);
			}
			
			bestFitnesses.add(column);
		}
		return bestFitnesses;

	}

	public void writeGenStatistics(Vector<Vector<Double>> bestFitnesses, int repeats, int maxGen) throws IOException {	
		FileWriter out = new FileWriter(resultsFileName);
		
		for (int j = 0; j < maxGen; j++) {
			double min = Double.MAX_VALUE;
			double max = -Double.MAX_VALUE;
			double sum = 0;
			for (int i = 0; i < repeats; i++) {
				double current = bestFitnesses.get(i).get(j);
				
				min = Math.min(current, min);
				max = Math.max(current, max);
				sum += current;	
			}	
			
			double avg = sum/repeats;
			
			out.write(min + " " + avg + " " + max + System.getProperty("line.separator"));
			
		}
		out.close();
		
	}

	public void logRun(Genotype pop) {
		
		double bestFitness = pop.getFittestChromosome().getFitnessValue();
		
		double fitnessSum = 0;
		for (IChromosome ch : pop.getPopulation().getChromosomes()) {
			fitnessSum += ch.getFitnessValue();
		}
		
		double averageFitness = fitnessSum/pop.getConfiguration().getPopulationSize();
		
		try {
			outputFile.write("" + bestFitness + " " + averageFitness + System.getProperty("line.separator"));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
