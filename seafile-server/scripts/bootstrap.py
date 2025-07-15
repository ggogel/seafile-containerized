#!/usr/bin/env python3
#coding: UTF-8

"""
Bootstraping seafile server, letsencrypt (verification & cron job).
"""

import argparse
import os
from os.path import abspath, basename, exists, dirname, join, isdir
import shutil
import sys
import uuid
import time

from utils import (
    call, get_conf, get_install_dir, loginfo,
    get_script, render_template, get_seafile_version, eprint,
    cert_has_valid_days, get_version_stamp_file, update_version_stamp,
    wait_for_mysql, wait_for_nginx, read_version_stamp
)

seafile_version = get_seafile_version()
installdir = get_install_dir()
topdir = dirname(installdir)
shared_seafiledir = '/shared/seafile'
ssl_dir = '/shared/ssl'
generated_dir = '/bootstrap/generated'


def is_https():
    return get_conf('HTTPS', 'false').lower() == 'true'

def parse_args():
    ap = argparse.ArgumentParser()
    ap.add_argument('--parse-ports', action='store_true')

    return ap.parse_args()

def init_seafile_server():
    version_stamp_file = get_version_stamp_file()
    if exists(join(shared_seafiledir, 'seafile-data')):
        if not exists(version_stamp_file):
            update_version_stamp(os.environ['SEAFILE_VERSION'])
        # sysbol link unlink after docker finish.
        latest_version_dir='/opt/seafile/seafile-server-latest'
        current_version_dir='/opt/seafile/' + get_conf('SEAFILE_SERVER', 'seafile-server') + '-' +  read_version_stamp()
        if not exists(latest_version_dir):
            call('ln -sf ' + current_version_dir + ' ' + latest_version_dir)
        loginfo('Skip running setup-seafile-mysql.py because there is existing seafile-data folder.')
        return

    loginfo('Now running setup-seafile-mysql.py in auto mode.')
    domain = get_conf('SEAFILE_URL', 'seafile.example.com')
    proto = 'https' if is_https() else 'http'
    env = {
        'SERVER_NAME': 'seafile',
        'SERVER_IP': domain,
        'FORCE_HTTPS_IN_CONF': 'true' if is_https() else 'false',
        'MYSQL_USER': 'seafile',
        'MYSQL_USER_PASSWD': str(uuid.uuid4()),
        'MYSQL_USER_HOST': '%.%.%.%',
        'MYSQL_HOST': get_conf('DB_HOST','127.0.0.1'),
        # Default MariaDB root user has empty password and can only connect from localhost.
        'MYSQL_ROOT_PASSWD': get_conf('DB_ROOT_PASSWD', ''),
    }

    # Change setup-seafile-mysql.py to disable check MYSQL_USER_HOST
    call('''sed -i -e '/def validate_mysql_user_host(self, host)/a \ \ \ \ \ \ \ \ return host' {}'''
        .format(get_script('setup-seafile-mysql.py')), shell=True)
    call('''sed -i -e '/def validate_mysql_host(self, host)/a \ \ \ \ \ \ \ \ return host' {}'''
        .format(get_script('setup-seafile-mysql.py')), shell=True)
    
    # Change setup-seafile-mysql.py to allow protocol (http/https) in SERVER_IP
    call('''sed -i '/SERVICE_URL = "http:\/\//s/http:\/\///' {}'''
        .format(get_script('setup-seafile-mysql.py')), shell=True)

    setup_script = get_script('setup-seafile-mysql.sh')
    call('{} auto -n seafile'.format(setup_script), env=env)
    with open(join(topdir, 'conf', 'seahub_settings.py'), 'a+') as fp:
        fp.write('\n')
        fp.write("""CACHES = {
    'default': {
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': 'memcached:11211',
    },
    'locmem': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
    },
}
COMPRESS_CACHE_BACKEND = 'locmem'""")
        fp.write('\n')
        fp.write("TIME_ZONE = '{time_zone}'".format(time_zone=os.getenv('TIME_ZONE',default='Etc/UTC')))
        fp.write('\n')
        fp.write('FILE_SERVER_ROOT = "{proto}://{domain}/seafhttp"'.format(proto=proto, domain=domain))
        fp.write('\n')

    # By default ccnet-server binds to the unix socket file
    # "/opt/seafile/ccnet/ccnet.sock", but /opt/seafile/ccnet/ is a mounted
    # volume from the docker host, and on windows and some linux environment
    # it's not possible to create unix sockets in an external-mounted
    # directories. So we change the unix socket file path to
    # "/opt/seafile/ccnet.sock" to avoid this problem.
    with open(join(topdir, 'conf', 'ccnet.conf'), 'a+') as fp:
        fp.write('\n')
        fp.write('[Client]\n')
        fp.write('UNIX_SOCKET = /opt/seafile/ccnet.sock\n')
        fp.write('\n')

    # Disabled the Elasticsearch process on Seafile-container
    # Connection to the Elasticsearch-container
    if os.path.exists(join(topdir, 'conf', 'seafevents.conf')):
        with open(join(topdir, 'conf', 'seafevents.conf'), 'r') as fp:
            fp_lines = fp.readlines()
            if '[INDEX FILES]\n' in fp_lines:
               insert_index = fp_lines.index('[INDEX FILES]\n') + 1
               insert_lines = ['es_port = 9200\n', 'es_host = elasticsearch\n', 'external_es_server = true\n']
               for line in insert_lines:
                   fp_lines.insert(insert_index, line)

            # office
            if '[OFFICE CONVERTER]\n' in fp_lines:
               insert_index = fp_lines.index('[OFFICE CONVERTER]\n') + 1
               insert_lines = ['host = 127.0.0.1\n', 'port = 6000\n']
               for line in insert_lines:
                   fp_lines.insert(insert_index, line)

        with open(join(topdir, 'conf', 'seafevents.conf'), 'w') as fp:
            fp.writelines(fp_lines)

        # office
        with open(join(topdir, 'conf', 'seahub_settings.py'), 'r') as fp:
            fp_lines = fp.readlines()
            if "OFFICE_CONVERTOR_ROOT = 'http://127.0.0.1:6000/'\n" not in fp_lines:
                fp_lines.append("OFFICE_CONVERTOR_ROOT = 'http://127.0.0.1:6000/'\n")

        with open(join(topdir, 'conf', 'seahub_settings.py'), 'w') as fp:
            fp.writelines(fp_lines)

    # Modify seafdav config
    if os.path.exists(join(topdir, 'conf', 'seafdav.conf')):
        with open(join(topdir, 'conf', 'seafdav.conf'), 'r') as fp:
            fp_lines = fp.readlines()
            if 'share_name = /\n' in fp_lines:
               replace_index = fp_lines.index('share_name = /\n')
               replace_line = 'share_name = /seafdav\n'
               fp_lines[replace_index] = replace_line

        with open(join(topdir, 'conf', 'seafdav.conf'), 'w') as fp:
            fp.writelines(fp_lines)

    # After the setup script creates all the files inside the
    # container, we need to move them to the shared volume
    #
    # e.g move "/opt/seafile/seafile-data" to "/shared/seafile/seafile-data"
    files_to_copy = ['conf', 'ccnet', 'seafile-data', 'seahub-data', 'pro-data']
    for fn in files_to_copy:
        src = join(topdir, fn)
        dst = join(shared_seafiledir, fn)
        if not exists(dst) and exists(src):
            shutil.move(src, shared_seafiledir)
            call('ln -sf ' + join(shared_seafiledir, fn) + ' ' + src)

    loginfo('Updating version stamp')
    update_version_stamp(os.environ['SEAFILE_VERSION'])
