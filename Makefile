SHELL := /bin/bash
PROJECT_ID := sentry

# ----------------------------------------------------------------------------
#    P R O D U C T I O N     C O M M A N D S
# ----------------------------------------------------------------------------

default: web

run: build web

deploy: run migrate collectstatic
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Bringing up fresh instance "
	@echo "You can access it on http://localhost:3333"
	@echo "------------------------------------------------------------------"

build:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Building in production mode"
	@echo "------------------------------------------------------------------"
	@docker-compose -p $(PROJECT_ID) build

web:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Running in production mode"
	@echo "------------------------------------------------------------------"
	@docker-compose -p $(PROJECT_ID) up -d
	@dipall | grep sentry

kill:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Killing in production mode"
	@echo "------------------------------------------------------------------"

	@docker-compose -p $(PROJECT_ID) kill

rm: kill
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Removing production instance!!! "
	@echo "------------------------------------------------------------------"
	@docker-compose -p $(PROJECT_ID) rm

logs:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Showing uwsgi logs in production mode"
	@echo "------------------------------------------------------------------"
	@docker-compose -p $(PROJECT_ID) logs sentry

shell:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Shelling in in production mode"
	@echo "------------------------------------------------------------------"
	@docker-compose -p $(PROJECT_ID) run uwsgi /bin/bash

dbshell:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Shelling in in production database"
	@echo "------------------------------------------------------------------"
	@docker exec -t -i $(PROJECT_ID)_db_1 psql -U docker -h localhost gis

dbrestore:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restore dump from backups/latest.dmp in production mode"
	@echo "------------------------------------------------------------------"
	@# - prefix causes command to continue even if it fails
	-@docker exec -t -i $(PROJECT_ID)_db_1 su - postgres -c "dropdb gis"
	@docker exec -t -i $(PROJECT_ID)_db_1 su - postgres -c "createdb -O docker -T template_postgis gis"
	@docker exec -t -i $(PROJECT_ID)_db_1 pg_restore /backups/latest.dmp | docker exec -i $(PROJECT_ID)_db_1 su - postgres -c "psql gis"

dbbackup:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Create `date +%d-%B-%Y`.dmp in production mode"
	@echo "Warning: backups/latest.dmp will be replaced with a symlink to "
	@echo "the new backup."
	@echo "------------------------------------------------------------------"
	@# - prefix causes command to continue even if it fails
	docker exec -t -i $(PROJECT_ID)_dbbackup_1 /backups.sh
	@docker exec -t -i $(PROJECT_ID)_dbbackup_1 cat /var/log/cron.log | tail -2 | head -1 | awk '{print $4}'
	# backups is intentionally missing from front of first clause below otherwise symlink comes
	# out with wrong path...
	# trigger sftp backups
	@docker exec -t -i $(PROJECT_ID)_sftppgbackup_1 /backups.sh
	@docker exec -t -i $(PROJECT_ID)_sftpmediabackup_1 /backups.sh

pushbackup:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Push local backup in sftpbackup to sftp remote server"
	@echo "------------------------------------------------------------------"
	@docker exec -t -i $(PROJECT_ID)_sftppgbackup_1 /start.sh push-to-remote-sftp
	@docker exec -t -i $(PROJECT_ID)_sftpmediabackup_1 /start.sh push-to-remote-sftp

pullbackup:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Pull remote sftp backup to local backup"
	@echo "------------------------------------------------------------------"
	@docker exec -t -i $(PROJECT_ID)_sftppgbackup_1 /start.sh pull-from-remote-sftp
	@docker exec -t -i $(PROJECT_ID)_sftpmediabackup_1 /start.sh pull-from-remote-sftp

reload:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Reload sentry in production mode"
	@echo "------------------------------------------------------------------"
	@docker exec -t -i $(PROJECT_ID)_uwsgi_1 uwsgi --reload  /tmp/django.pid

create-machine:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Creating a docker machine. Only useful for OSX and Windows"
	@echo "------------------------------------------------------------------"
	@docker-machine create --driver virtualbox inasafe-django
	@echo "Now attach to your machine by doing:"
	@echo '"$(docker-machine env sentry)"'

