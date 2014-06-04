from django.shortcuts import render
from django.template import Context

from models import Spam, SpamForm

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
