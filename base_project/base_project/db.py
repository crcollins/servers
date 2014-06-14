import random

from django.conf import settings


class Router(object):
    def db_for_read(self, model, **hints):
        return random.choice(settings.DATABASES.keys())

    def db_for_write(self, model, **hints):
        return settings.DATABASES.get('master', 'default')

    def allow_relation(self, obj1, obj2, **hints):
        db_list = settings.DATABASES
        if obj1._state.db in db_list and obj2._state.db in db_list:
            return True
        return None

    def allow_syncdb(self, db, model):
        return True