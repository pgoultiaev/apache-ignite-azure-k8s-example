package nl.acme.app;

import org.apache.ignite.Ignition;
import org.apache.ignite.client.ClientCache;
import org.apache.ignite.client.ClientException;
import org.apache.ignite.client.IgniteClient;
import org.apache.ignite.configuration.ClientConfiguration;

/**
 * Example of Apache ignite thin client based on:
 * https://apacheignite.readme.io/docs/java-thin-client-quick-start
 *
 * Set CLUSTERADDR env variable as "host:port" to configure Ignite client to connect to
 * your (activated) Ignite cluster
 */
public class App {
    public static void main(String[] args) {
        String igniteClusterAddress = System.getenv("CLUSTERADDR");
        System.out.println("Configuring client with address: " + igniteClusterAddress);
        ClientConfiguration cfg = new ClientConfiguration().setAddresses(igniteClusterAddress);
        System.out.println("Trying to start ignite client");
        try (IgniteClient igniteClient = Ignition.startClient(cfg)) {
            System.out.println();

            System.out.println(">>> Thin client put-get example started.");
            final String CACHE_NAME = "put-get-example";

            ClientCache<Integer, Address> cache = igniteClient.getOrCreateCache(CACHE_NAME);

            System.out.format(">>> Created cache [%s].\n", CACHE_NAME);

            Integer key = 1;
            Address val = new Address("1545 Jackson Street", 94612);

            cache.put(key, val);

            System.out.format(">>> Saved [%s] in the cache.\n", val);

            Address cachedVal = cache.get(key);

            System.out.format(">>> Loaded [%s] from the cache.\n", cachedVal.toString());
        } catch (ClientException e) {
            System.err.println(e.getMessage());
        } catch (Exception e) {
            System.err.format("Unexpected failure: %s\n", e);
        }
        System.out.println("Done");
    }
}
