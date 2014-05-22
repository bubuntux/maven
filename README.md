Bubuntux's Maven Repository [![Build Status](https://travis-ci.org/bubuntux/mvn.svg?branch=repo)](https://travis-ci.org/bubuntux/mvn)
===

How to use it
-------------

Add this in your **pom.xml** file 

```
<repositories>
  <repository>
    <id>bubuntux-repo</id>
    <url>https://raw.github.com/bubuntux/mvn/repo/</url>
  </repository>
</repositories>
```

How to manually add artifacts
-----------------------------

```
mvn -DaltDeploymentRepository=bubuntux-repo::default::file:[mvn-repo-dir] -Dmaven.test.skip=true clean deploy 
```

How to automatically add artifacts
----------------------------------

Add this in your **.travis.yml** file

```
after_success: if [[ $TRAVIS_PULL_REQUEST == 'false' && $TRAVIS_BRANCH == 'master' ]]; then mvn deploy -DskipTests=true -B; fi
env:
  global:
    secure: [Your encrypted TOKEN]

```

Add this in your **pom.xml** file

```
<properties>
    <built.repo.dir>${project.build.directory}/mvn-repo</built.repo.dir>
</properties>

<distributionManagement>
    <repository>
        <id>internal.repo</id>
        <name>Temporary Staging Repository</name>
        <url>file://${built.repo.dir}</url>
    </repository>
</distributionManagement>

<plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-deploy-plugin</artifactId>
      <version>2.8.1</version>
      <configuration>
          <altDeploymentRepository>internal.repo::default::file://${built.repo.dir}</altDeploymentRepository>
      </configuration>
    </plugin>
    <plugin>
      <groupId>com.github.github</groupId>
      <artifactId>site-maven-plugin</artifactId>
      <version>0.8</version>
      <configuration>
          <oauth2Token>${env.TOKEN}</oauth2Token>
          <message>${project.groupId}:${project.artifactId}:${project.version} - Build ${env.TRAVIS_BUILD_NUMBER} ( ${project.ciManagement.url}/builds/${env.TRAVIS_BUILD_ID} )</message>
          <merge>true</merge>
          <noJekyll>true</noJekyll>
    
          <repositoryOwner>bubuntux</repositoryOwner>
          <repositoryName>mvn</repositoryName>
          <branch>refs/heads/repo</branch>
    
          <outputDirectory>${built.repo.dir}</outputDirectory>
          <includes>
              <include>**/*</include>
          </includes>
      </configuration>
      <executions>
          <execution>
              <goals>
                  <goal>site</goal>
              </goals>
              <phase>deploy</phase>
          </execution>
      </executions>
  </plugin>
</plugins>
```

Additionally if you want to include the sources add this plugin

```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-source-plugin</artifactId>
    <version>2.1.2</version>
    <executions>
        <execution>
            <id>attach-sources</id>
            <phase>verify</phase>
            <goals>
                <goal>jar-no-fork</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```
