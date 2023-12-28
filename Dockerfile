#Stage 0 build artifact from source
FROM maven:3.8.3-openjdk-17 AS BUILD
WORKDIR /app
COPY .  .
RUN mvn package -DskipTests 


# Stage 1 - package app to run
FROM openjdk:18-alpine as RUN
WORKDIR /run
COPY --from=BUILD /app/target/demo-0.0.1-SNAPSHOT.jar /run/demo.jar

ARG USER=devops
ENV HOME /home/$USER
RUN adduser -D $USER && \
chown $USER:$USER /run/demo.jar

RUN apk add curl
HEALTHCHECK --interval=30s --timeout=10s --retries=2 --start-period=20s \
	CMD curl -f http://localhost:8080/ || exit 1

#Switch to user
USER $USER

EXPOSE 8080
CMD java  -jar /run/demo.jar
