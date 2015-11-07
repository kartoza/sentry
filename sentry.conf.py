# This file is just Python, with a touch of Django which means you
# you can inherit and tweak settings to your hearts content.
from sentry.conf.server import *
import os

CONF_ROOT = os.path.dirname(__file__)
TIME_ZONE = 'Africa/Johannesburg'

# Remeber to set the SECRET_KEY environment variable when putting this into
# production so no one can spoofe your sessions. Changing this will cause your
# current user sessions to become invalidated.
SECRET_KEY = os.environ.get('SECRET_KEY') or 'notasecret'

# This is only acceptable if we are behind some kind of reverse proxy, or a HTTP
# load ballancer, since it will do the HOST name checking for us!
ALLOWED_HOSTS = ['*']

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'gis',
        'USER': 'docker',
        'HOST': 'db',
        'PORT': '5432',

        # If you're using Postgres, we recommend turning on autocommit
        'OPTIONS': {
            'autocommit': True,
        },
    }
}
SENTRY_CACHE = 'sentry.cache.redis.RedisCache'

SENTRY_REDIS_OPTIONS = {
    'hosts': {
        0: {
            'host': 'redis',
            'port': 6379,
        },
    }
}

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
# Host for sending e-mail.
EMAIL_HOST = 'smtp'
# Port for sending e-mail.
EMAIL_PORT = 25
# SMTP authentication information for EMAIL_HOST.
# See fig.yml for where these are defined
EMAIL_HOST_USER = 'noreply@kartoza.com'
EMAIL_HOST_PASSWORD = 'docker'
EMAIL_USE_TLS = False
EMAIL_SUBJECT_PREFIX = '[PROJECTA]'

# The email address to send on behalf of
SENTRY_URL_PREFIX = 'sentry.kartoza.com'
SERVER_EMAIL = 'noreply@kartoza.com'
SENTRY_ADMIN_EMAIL = 'tim@kartoza.com'

SENTRY_WEB_HOST = '0.0.0.0'
SENTRY_WEB_PORT = 3333
SENTRY_WEB_OPTIONS = {
    'workers': 3,             # number of gunicorn workers
    'limit_request_line': 0,  # required for raven-js
    'secure_scheme_headers': {'X-FORWARDED-PROTO': 'https'},
}

# If you're using a reverse proxy, you should enable the X-Forwarded-Proto
# and X-Forwarded-Host headers, and uncomment the following settings
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
USE_X_FORWARDED_HOST = True

