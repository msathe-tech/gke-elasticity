package com.hpc.hpcjobprocessor;

import com.google.cloud.spring.pubsub.core.PubSubTemplate;
import com.google.cloud.spring.pubsub.integration.AckMode;
import com.google.cloud.spring.pubsub.integration.inbound.PubSubInboundChannelAdapter;
import com.google.cloud.spring.pubsub.integration.outbound.PubSubMessageHandler;
import com.google.cloud.spring.pubsub.support.BasicAcknowledgeablePubsubMessage;
import com.google.cloud.spring.pubsub.support.GcpPubSubHeaders;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.PublishSubscribeChannel;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.support.GenericMessage;

import java.io.FileWriter;
import java.io.IOException;
import java.io.BufferedWriter;

@SpringBootApplication
public class HpcJobProcessorApplication {

	private static final Log LOGGER = (Log) LogFactory.getLog(HpcJobProcessorApplication.class);
  
	public static void main(String[] args) {
		SpringApplication.run(HpcJobProcessorApplication.class, args);
    
	}

	// [START pubsub_spring_inbound_channel_adapter]
  // Create a message channel for messages arriving from the subscription `projects/prj-gke-mt-spike/subscriptions/sub-one`.
  @Bean
  public MessageChannel inputMessageChannel() {
    return new PublishSubscribeChannel();
  }

  // Create an inbound channel adapter to listen to the subscription `projects/prj-gke-mt-spike/subscriptions/sub-one` and send
  // messages to the input message channel.
  @Bean
  public PubSubInboundChannelAdapter inboundChannelAdapter(
      @Qualifier("inputMessageChannel") MessageChannel messageChannel,
      PubSubTemplate pubSubTemplate) {
    PubSubInboundChannelAdapter adapter =
        new PubSubInboundChannelAdapter(pubSubTemplate, "projects/prj-gke-mt-spike/subscriptions/sub-one");
    adapter.setOutputChannel(messageChannel);
    adapter.setAckMode(AckMode.MANUAL);
    adapter.setPayloadType(String.class);
    return adapter;
  }

  // Define what happens to the messages arriving in the message channel.
  @ServiceActivator(inputChannel = "inputMessageChannel")
  public void messageReceiver(
      String payload,
      @Header(GcpPubSubHeaders.ORIGINAL_MESSAGE) BasicAcknowledgeablePubsubMessage message) {
    LOGGER.info("Message arrived via an inbound channel adapter from projects/prj-gke-mt-spike/subscriptions/sub-one! Payload: " + payload);
    String FILE_PATH = new String("/hpc/")
      .concat(System.getenv().get("NODE_NAME"))
      .concat("_")
      .concat(System.getenv().get("POD_NAME"));
    FileWriter fw;
    BufferedWriter bw;
    try {
      fw = new FileWriter(FILE_PATH, true);
      bw = new BufferedWriter(fw);
      bw.write(payload);
      bw.newLine();
      bw.close();
    } catch (IOException ioe) {
      LOGGER.info("Failed to write to file");
      ioe.printStackTrace();
    }
    
    // try {
    //   LOGGER.info("Begin processing the Payload: " + payload);
    //     Thread.sleep(60000);
    // } catch (InterruptedException e) {
    //     // Stop sleep earlier.
    // }
    message.ack();
  }
  // [END pubsub_spring_inbound_channel_adapter]

  // [START pubsub_spring_outbound_channel_adapter]
  // Create an outbound channel adapter to send messages from the input message channel to the
  // topic `projects/prj-gke-mt-spike/topics/topic-two`.
  @Bean
  @ServiceActivator(inputChannel = "inputMessageChannel")
  public MessageHandler messageSender(PubSubTemplate pubsubTemplate) {
    PubSubMessageHandler adapter = new PubSubMessageHandler(pubsubTemplate, "projects/prj-gke-mt-spike/topics/topic-two");

    adapter.setSuccessCallback(
        ((ackId, message) ->
            extracted(message)));

    adapter.setFailureCallback(
        (cause, message) -> LOGGER.info("Error sending " + message + " due to " + cause));

    return adapter;
  }
  // [END pubsub_spring_outbound_channel_adapter]


  private void extracted(final Message<?> message) {
    String payload = message.getPayload().toString();
    LOGGER.info("Finished Processing Payload: " + payload + ". Message was sent via the outbound channel adapter to projects/prj-gke-mt-spike/topics/topic-two!");
    // try {
    //   LOGGER.info("Begin processing the Payload: " + payload);
    //     Thread.sleep(1000);
    // } catch (InterruptedException e) {
    //     // Stop sleep earlier.
    // }
    // System.exit(0);
  }

}
