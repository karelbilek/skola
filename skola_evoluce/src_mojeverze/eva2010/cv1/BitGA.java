package eva2010.cv1;

import java.io.*;
import java.util.*;
import org.jgap.*;
import org.jgap.impl.*;

import eva2010.StatsLogger;

public class BitGA {

	
	static class GAProperties {
		//kolikrát opakovat evolvování
		static int maxGen;

		//?? asi velikost? něčeho?
		static int dimension;

		//velikost populace
		static int popSize;

		//kolikrát opakovat CELÝ EXPERIMENT
		static int repeats;

		//nějaké souborové detaily
		static String logFilePrefix;
		static String resultsFileName;
		
		public static void loadProperties() {

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
			resultsFileName = prop.getProperty("results_filename", "ga.log");
			repeats = Integer.parseInt(prop.getProperty("repeats", "10"));
		}
	}

	static StatsLogger stats;

	public static void main(String[] args)  {
	
		GAProperties.loadProperties();

		stats = new StatsLogger(GAProperties.logFilePrefix, GAProperties.resultsFileName);

		//spustí se repeat-krát experiment	
		for (int i = 0; i < GAProperties.repeats; i++) {
			run(i);
		}
		
		//znovunačtou se fitnessy, udělá se statistika
		//pozn. - tady ten muj refractoring trochu zmenil chovani pri exceptionech, ale who cares
		stats.writeResults(GAProperties.maxGen);
		System.out.println("FINISHED");
				
	}

	
	//nacte znovu nejlepsi fitnessy ze souboru zpatky do vectoru
	
	static Configuration myConfiguration() throws InvalidConfigurationException {
		Configuration conf = new DefaultConfiguration();
		Configuration.reset();

		//vzorový jedinec
		Gene[] sampleGenes = new Gene[GAProperties.dimension];	
		for (int i = 0; i < GAProperties.dimension; i++) {
			sampleGenes[i] = new IntegerGene(conf,0,1);
		}
		Chromosome sampleChromosome = new Chromosome(conf, sampleGenes);
		


		//parametry pro evoluci
		conf.setSampleChromosome(sampleChromosome);
		
/*****************NASTAVENI FITNESS***********************/
		conf.setFitnessFunction(new BitGAFitness());
		
		
		conf.setPopulationSize(GAProperties.popSize);
		
		conf.addNaturalSelector(new WeightedRouletteSelector(conf), true);
				//pálíme králíkárnu
		conf.removeNaturalSelectors(false);
		conf.addNaturalSelector(new StandardPostSelector(conf), false);

		return conf;
	}

	static void run(int number) {
		try {
			Configuration conf = myConfiguration();
			Genotype pop = Genotype.randomInitialGenotype(conf);
			
			System.out.println("Generation -1: " + pop.getFittestChromosome().toString());
		
			stats.setRun(number);			
			
			for (int i = 0; i < GAProperties.maxGen; i++) {
				pop.evolve();
				System.out.println("Generation " + i + ": " + pop.getFittestChromosome().toString());
				
				stats.logRun(pop);
			}
			stats.closeRun();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	
}
