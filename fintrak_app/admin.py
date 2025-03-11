from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import User, Transaction, Budget, Report

admin.site.register(User)
admin.site.register(Transaction)
admin.site.register(Budget)
admin.site.register(Report)