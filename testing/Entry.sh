#!/usr/bin/env bash

echo "*************Running entry.sh file**********"
cd code/
pwd
ls

URL=${@}

echo "Starting JMeter tests on ${URL}"

#Command
cd ../bin
sh jmeter -n -t /opt/apache-jmeter-5.2.1/code/petclinic_load_test.jmx -l /opt/apache-jmeter-5.2.1/code/test_output.csv -JThreadNumber=<number_of_threads_to_run> -JRampUpPeriod=<ramp_up_period> -JURL=${URL}

echo "********entry.sh file RAN SUCCESSFULLY*******"
