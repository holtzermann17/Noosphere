#!/bin/sh
cd /vinstalls/pm/var/www/noosphere/emailbridge
/vinstalls/pm/usr/local/j2sdk1.4.1/bin/java -cp lib/commons-codec-1.3.jar:lib/commons-logging-1.0.4.jar:lib/commons-httpclient-3.1.jar:lib/activation.jar:lib/mail.jar:lib/mailapi.jar:lib/mysql-connector-java-3.1.14-bin.jar:. pm.mailbridge.BridgeParser 1>>log 2>>err
