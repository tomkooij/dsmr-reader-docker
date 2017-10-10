#!/bin/bash

source /root/.virtualenvs/dsmrreader/bin/activate
cp /root/dsmr-reader/dsmrreader/provisioning/django/postgresql.py /root/dsmr-reader/dsmrreader/settings.py \
sed -i 's/localhost/dsmrdb/g' /root/dsmr-reader/dsmrreader/settings.py \
/root/dsmr-reader/manage.py migrate \
/root/dsmr-reader/manage.py collectstatic --noinput

if [[ -z ${DSMR_USER} ]] || [[ -z $DSMR_EMAIL ]] || [[ -z ${DSMR_PASSWORD} ]]; then
  echo "DSMR web credentials not set. Exiting."
  exit 1
else
#  if echo "from django.contrib.auth.models import User; User.objects.filter(is_superuser=True).exists()" | /root/dsmr-reader/manage.py shell; then
#    echo "DSMR web credentials already set!"
#  else
    echo "Setting DSMR web credentials..."
    (cat - | /root/dsmr-reader/manage.py shell) << !
from django.contrib.auth.models import User;
User.objects.create_superuser('$DSMR_USER',
                              '$DSMR_EMAIL',
                              '$DSMR_PASSWORD')
!

#  fi
fi

# START SERVICES
/usr/sbin/nginx
/usr/bin/supervisord -n
