from django.db import models
from django import forms


class Spam(models.Model):
    name = models.CharField(max_length=40)
    text = models.CharField(max_length=400)
    created = models.DateTimeField(auto_now=True)


class SpamForm(forms.ModelForm):
    class Meta:
        model = Spam
        fields = ("name", "text")
