from django.conf.urls import patterns, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('spam.views',
    url(r'^$', "index", name="index"),
    url(r'^info/$', "info", name="info"),
)