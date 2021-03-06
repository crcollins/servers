import socket

from django.shortcuts import render
from django.template import Context
from django.db import router

from models import Spam, SpamForm


def get_client_ip(request):
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def index(request):
    if request.method == "POST":
        form = SpamForm(request.POST)
        if form.is_valid():
            form.save()
    else:
        form = SpamForm()
    c = Context({
        "objects": Spam.objects.all(),
        "form": form,
        })
    return render(request, "spam/index.html", c)


def info(request):
    spam = Spam(name='', text='')
    c = Context({
        "hostname": socket.gethostname(),
        "ip": get_client_ip(request),
        "read_db": router.db_for_read(spam.__class__, instance=spam),
        "write_db": router.db_for_write(spam.__class__, instance=spam),
        })
    return render(request, "spam/info.html", c)


def lorem(request):
    return render(request, "spam/lorem.html")
