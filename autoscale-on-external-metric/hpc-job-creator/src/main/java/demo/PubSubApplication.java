/*
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package demo;

import com.google.cloud.spring.pubsub.core.PubSubTemplate;
import com.google.cloud.spring.pubsub.integration.AckMode;
import com.google.cloud.spring.pubsub.integration.inbound.PubSubInboundChannelAdapter;
import com.google.cloud.spring.pubsub.integration.outbound.PubSubMessageHandler;
import com.google.cloud.spring.pubsub.support.BasicAcknowledgeablePubsubMessage;
import com.google.cloud.spring.pubsub.support.GcpPubSubHeaders;
import java.util.Random;
import java.util.function.Consumer;
import java.util.function.Supplier;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.PublishSubscribeChannel;
import org.springframework.integration.support.MessageBuilder;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;
import org.springframework.messaging.handler.annotation.Header;
import reactor.core.publisher.Flux;
import reactor.core.scheduler.Schedulers;

@SpringBootApplication
public class PubSubApplication {

  private static final Log LOGGER = LogFactory.getLog(PubSubApplication.class);
  private static final Random rand = new Random(2020);

  public static void main(String[] args) {
    SpringApplication.run(PubSubApplication.class, args);
  }

  // [START pubsub_spring_cloud_stream_output_binder]
  // Create an output binder to send messages to `projects/prj-gke-mt-spike/topics/topic-one` using a Supplier bean.
  @Bean
  public Supplier<Flux<Message<String>>> sendMessageToTopicOne() {
    return () ->
        Flux.<Message<String>>generate(
                sink -> {
                  // try {
                  //   Thread.sleep(10000);
                  // } catch (InterruptedException e) {
                  //   // Stop sleep earlier.
                  // }

                  Message<String> message =
                      MessageBuilder.withPayload("message-" + rand.nextInt(1000)).build();
                  LOGGER.info(
                      "Sending a message via the output binder to projects/prj-gke-mt-spike/topics/topic-one! Payload: "
                          + message.getPayload());
                  sink.next(message);
                })
            .subscribeOn(Schedulers.boundedElastic());
  }
  // [END pubsub_spring_cloud_stream_output_binder]
}
