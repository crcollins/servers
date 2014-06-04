from django.contrib import admin

from models import Spam


class SpamAdmin(admin.ModelAdmin):
    date_hierarchy = "created"
    list_display = ("name", "created")

admin.site.register(Spam, SpamAdmin)

