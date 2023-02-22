echo "*********************************"
echo "** clean compile test-compile"
echo "*********************************"
mvn -B clean compile test-compile

echo "*********************************"
echo "** test"
echo "*********************************"
mvn -B test

echo "*********************************"
echo "** Integration test"
echo "*********************************"
mvn -B integration-test failsafe:verify

#mvn -B sonar:sonar -Dsonar.host.url=https://sonar.oobj.com.br -Dsonar.login=admin -Dsonar.password=sonar@oobj!

echo "*********************************"
echo "** deploy"
echo "*********************************"
mvn -B deploy -DskipTests

echo "*********************************"
echo "** semantic version"
echo "*********************************"
mvn -B git-changelog-maven-plugin:semantic-version

echo "*********************************"
echo "** changelog"
echo "*********************************"
mvn -B git-changelog-maven-plugin:git-changelog

git add .
git commit -m "chore(changelog): generating changelog"
git push

echo "*********************************"
echo "** release:[clean|prepare|perform]"
echo "*********************************"
mvn -B release:clean release:prepare release:perform