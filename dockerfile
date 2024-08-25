# stage 1 : build jar dulu
FROM maven:3-eclipse-temurin-21 AS mvnbuild
# membuat working folder
WORKDIR /opt/application
# menambahkan pom.xml dari laptop ke dalam container
COPY pom.xml .
# donlod dependensi dulu, supaya menjadi layer terpisah dari compile
RUN mvn dependency:go-offline
# menambahkan folder src ke dalam container
COPY src ./src
# menjalankan compile source code dan buat jar file
RUN mvn clean install package -DskipTests

FROM adoptopenjdk/openjdk21
# Create the / directory in the final image
WORKDIR /
COPY --from=mvnbuild /opt/application/target/*.jar streaming-be-test-0.0.1-SNAPSHOT.jar
RUN mkdir logs
# tzdata for timzone
RUN apt-get update -y
RUN apt-get install -y tzdata

# timezone env with default
ENV TZ Asia/Jakarta
ENTRYPOINT ["java","-Xms512m","-Xmx4048m","-jar","/streaming-be-test-0.0.1-SNAPSHOT.jar"]
