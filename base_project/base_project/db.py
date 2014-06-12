import random

from django.conf import settings


class Router(object):
    def db_for_read(self, model, **hints):
        keys = [x for x in settings.DATABASES.keys() if x.startswith('slave')]
        if keys:
            return random.choice(keys)
        return 'default'

    def db_for_write(self, model, **hints):
        if settings.DATABASES.get('master'):
            return 'master'
        return 'default'

    def allow_relation(self, obj1, obj2, **hints):
        db_list = settings.DATABASES
        if obj1._state.db in db_list and obj2._state.db in db_list:
            return True
        return None

    def allow_syncdb(self, db, model):
        return True