package eva2010.cv1;

import java.io.FileInputStream;


import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.util.Properties;
import java.util.Vector;

import org.jgap.Chromosome;
import org.jgap.Configuration;
import org.jgap.Gene;
import org.jgap.Genotype;
import org.jgap.InvalidConfigurationException;
import org.jgap.impl.DefaultConfiguration;
import org.jgap.impl.IntegerGene;
import org.jgap.impl.StandardPostSelector;
import org.jgap.impl.WeightedRouletteSelector;

import eva2010.StatsLogger;

public class BitGA {

	static int maxGen;
	static int dimension;
	static int popSize;
	static String logFilePrefix;
	static String resultsFile;
	static int repeats;
	
	
	public static void main(String[] args)  {
		
		Properties prop = new Properties();
		try {
			InputStream propIn = new FileInputStream("ga.properties");
			prop.load(propIn);
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		maxGen = Integer.parseInt(prop.getProperty("max_generations","20"));
		dimension = Integer.parseInt(prop.getProperty("dimension","25"));
		popSize = Integer.parseInt(prop.getProperty("population_size", "30"));
		logFilePrefix = prop.getProperty("log_filename_prefix", "ga.log");
		resultsFile = prop.getProperty("results_filename", "ga.log");
		repeats = Integer.parseInt(prop.getProperty("repeats", "10"));
		
		for (int i = 0; i < repeats; i++) {
			run(i);
		}
		
		Vector<Vector<Double>> bestFitnesses = new Vector<Vector<Double>>();
		try {
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
		
			FileWriter out = new FileWriter(resultsFile);
			
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
			System.out.println("FINISHED");
		}
		catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
	static void run(int number) {
		
		//vytvoříme defaultní konfiguraci
		Configuration conf = new DefaultConfiguration();
		Configuration.reset();
		
		try {
			
			
			Gene[] sampleGenes = new Gene[dimension];
			
			for (int i = 0; i < dimension; i++) {
				
				sampleGenes[i] = new IntegerGene(conf,0,1);
			}
			
			//vzorový jedinec, podle parametrů??? netušim
			Chromosome sampleChromosome = new Chromosome(conf, sampleGenes);
			
			//nastavení věcí pro evoluci
			conf.setSampleChromosome(sampleChromosome);
			conf.setFitnessFunction(new BitGAFitness());
			conf.setPopulationSize(popSize);
			
			conf.addNaturalSelector(new WeightedRouletteSelector(conf), true);
					//pálíme králíkárnu
			conf.removeNaturalSelectors(false);
			conf.addNaturalSelector(new StandardPostSelector(conf), false);
			
				//typ populace neni population, ale genotype :)
			Genotype pop = Genotype.randomInitialGenotype(conf);
			
			
			System.out.println("Generation -1: " + pop.getFittestChromosome().toString());
			
			OutputStreamWriter out = new OutputStreamWriter(new FileOutputStream(logFilePrefix + "." + number));
			
			for (int i = 0; i < maxGen; i++) {
				//nejdůležitější, ale není extra komplikovaná
				pop.evolve();
				System.out.println("Generation " + i + ": " + pop.getFittestChromosome().toString());
				
				StatsLogger.log(pop, out);
				
				
			}
			out.close();
		}
		catch (InvalidConfigurationException e) {
			e.printStackTrace();
		}
		catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	
}
